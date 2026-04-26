local ADDON_NAME, ns = ...
local Roster = {}
ns.Roster = Roster

-- Normalize "Player-Realm" -> "player" for stable keying.
local function normalize(name)
  if not name or name == "" then
    return nil
  end
  local n = name:match("^([^%-]+)") or name
  n = n:gsub("%s+$", ""):gsub("^%s+", "")
  if n == "" then
    return nil
  end
  return n:lower()
end
Roster.Normalize = normalize

function Roster:Initialize(addon)
  self.addon = addon
  self.pendingScan = false
  self.scanIsSilent = false
  self.lastScanAt = 0
  self.autoTicker = nil

  addon:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function()
    self:LearnFromUnit("mouseover")
  end)
  addon:RegisterEvent("PLAYER_TARGET_CHANGED", function()
    self:LearnFromUnit("target")
  end)
  addon:RegisterEvent("WHO_LIST_UPDATE", function()
    self:OnWhoListUpdate()
  end)
  addon:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
      self:StartAutoScan()
    end
  end)
end

-- Cancels any pending ticker and reschedules according to db.realm.scanIntervalMin.
-- Also fires one scan ~5s from now so a fresh login/reload populates promptly.
function Roster:StartAutoScan()
  if self.autoTicker then
    self.autoTicker:Cancel()
    self.autoTicker = nil
  end
  local mins = self.addon.db.realm.scanIntervalMin or 0
  if mins <= 0 then
    return
  end
  C_Timer.After(5, function()
    self:RequestWhoScan(true)
  end)
  self.autoTicker = C_Timer.NewTicker(mins * 60, function()
    self:RequestWhoScan(true)
  end)
end

-- GetGuildInfo() can return nil right after the unit becomes available; retry briefly.
function Roster:LearnFromUnit(unit, retries)
  if not UnitExists(unit) or not UnitIsPlayer(unit) then
    return
  end
  local guild = GetGuildInfo(unit)
  local target = self.addon.db.realm.targetGuild
  if not guild then
    retries = retries or 0
    if retries < 3 then
      C_Timer.After(0.25, function()
        self:LearnFromUnit(unit, retries + 1)
      end)
    end
    return
  end
  if not target or guild:lower() ~= target:lower() then
    return
  end
  local name = UnitName(unit)
  if name then
    self:Add(name, "auto")
  end
end

function Roster:Add(rawName, source)
  local key = normalize(rawName)
  if not key then
    return false
  end
  if self.addon.db.realm.muted[key] then
    return false
  end
  self.addon.db.realm.muted[key] = true
  self.addon.db.realm.learnedAt[key] = time()
  return true
end

function Roster:Remove(rawName)
  local key = normalize(rawName)
  if not key then
    return false
  end
  if not self.addon.db.realm.muted[key] then
    return false
  end
  self.addon.db.realm.muted[key] = nil
  self.addon.db.realm.learnedAt[key] = nil
  return true
end

function Roster:Has(rawName)
  local key = normalize(rawName)
  if not key then
    return false
  end
  return self.addon.db.realm.muted[key] == true
end

function Roster:Clear()
  wipe(self.addon.db.realm.muted)
  wipe(self.addon.db.realm.learnedAt)
end

function Roster:PrintList()
  local names = {}
  for k in pairs(self.addon.db.realm.muted) do
    table.insert(names, k)
  end
  if #names == 0 then
    self.addon:Print("mute list is empty")
    return
  end
  table.sort(names)
  self.addon:Print(("muted (%d):"):format(#names))
  for _, n in ipairs(names) do
    self.addon:Print("  - " .. n)
  end
end

local SCAN_COOLDOWN = 6 -- /who is rate-limited; ~5s server-side
function Roster:RequestWhoScan(silent)
  local guild = self.addon.db.realm.targetGuild
  if not guild or guild == "" then
    if not silent then
      self.addon:Print("no target guild set; use /gm guild <Name>")
    end
    return
  end
  local now = GetTime()
  local wait = SCAN_COOLDOWN - (now - self.lastScanAt)
  if wait > 0 then
    if not silent then
      self.addon:Print(("/who is rate-limited, retry in %ds"):format(math.ceil(wait)))
    end
    return
  end
  self.lastScanAt = now
  self.pendingScan = true
  self.scanIsSilent = silent and true or false
  if not silent then
    self.addon:Print(('scanning /who g-"%s" ...'):format(guild))
  end
  local query = 'g-"' .. guild .. '"'
  if C_FriendList and C_FriendList.SendWho then
    C_FriendList.SendWho(query)
  else
    SendWho(query)
  end
end

local function getNumWhoResults()
  if C_FriendList and C_FriendList.GetNumWhoResults then
    return C_FriendList.GetNumWhoResults()
  end
  return GetNumWhoResults()
end

local function getWhoInfo(i)
  if C_FriendList and C_FriendList.GetWhoInfo then
    local info = C_FriendList.GetWhoInfo(i)
    if info then
      return info.fullName, info.fullGuildName
    end
    return nil, nil
  end
  local name, guild = GetWhoInfo(i)
  return name, guild
end

function Roster:OnWhoListUpdate()
  if not self.pendingScan then
    return
  end
  self.pendingScan = false
  local silent = self.scanIsSilent
  self.scanIsSilent = false
  local count = getNumWhoResults() or 0
  local target = (self.addon.db.realm.targetGuild or ""):lower()
  local added = 0
  for i = 1, count do
    local name, guild = getWhoInfo(i)
    if name and guild and guild:lower() == target then
      if self:Add(name, "scan") then
        added = added + 1
      end
    end
  end
  if not silent or added > 0 then
    self.addon:Print(("scan: +%d new (%d /who results)"):format(added, count))
  end
  if count >= 49 and not silent then
    self.addon:Print("note: /who returns at most 49 hits; large guilds may need multiple scans with level filters")
  end
end
