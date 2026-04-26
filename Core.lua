local ADDON_NAME, ns = ...

local GuildMute = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0")
ns.Addon = GuildMute

local DEFAULT_GUILD = "Dawnwalkers"

local defaults = {
  realm = {
    targetGuild = DEFAULT_GUILD,
    enabled = true,
    scanIntervalMin = 30, -- 0 disables periodic /who scans
    historyEnabled = true, -- in-memory only; cleared on /reload
    muted = {}, -- [normalizedName] = true
    learnedAt = {}, -- [normalizedName] = unix timestamp
  },
}

function GuildMute:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("GuildMuteDB", defaults, true)
  self:RegisterChatCommand("guildmute", "HandleSlashCommand")
  self:RegisterChatCommand("gm", "HandleSlashCommand")

  ns.Roster:Initialize(self)
  ns.History:Initialize(self)
  ns.Filter:Initialize(self)
  ns.IO:Initialize(self)
end

function GuildMute:OnEnable()
  local count = 0
  for _ in pairs(self.db.realm.muted) do
    count = count + 1
  end
  self:Print(
    ("ready. %d muted on this realm. Target guild: %s. /gm help for commands."):format(count, self.db.realm.targetGuild)
  )
  -- Start the auto-scan ticker; the PLAYER_ENTERING_WORLD handler also restarts it on /reload.
  ns.Roster:StartAutoScan()
end

local function help(self)
  self:Print("commands:")
  self:Print("  /gm guild <Name>      set guild to filter (default: Dawnwalkers)")
  self:Print("  /gm refresh           run a /who scan now to populate the list")
  self:Print("  /gm interval <min>    set auto-scan interval (0 = off; default: 30)")
  self:Print("  /gm export            open a window with the list, ready to copy")
  self:Print("  /gm import            paste a list from another character to merge")
  self:Print("  /gm history [N|all|clear|on|off]  show what was filtered this session")
  self:Print("  /gm add <Charname>    add a name manually")
  self:Print("  /gm remove <Charname> remove a name from the list")
  self:Print("  /gm list              show all muted names")
  self:Print("  /gm clear             empty the mute list")
  self:Print("  /gm toggle            enable/disable filtering")
  self:Print("  /gm status            show summary")
end

function GuildMute:HandleSlashCommand(input)
  input = (input or ""):trim()
  local cmd, rest = input:match("^(%S*)%s*(.-)$")
  cmd = (cmd or ""):lower()

  if cmd == "guild" then
    if rest == "" then
      self:Print("target guild: " .. self.db.realm.targetGuild)
      return
    end
    self.db.realm.targetGuild = rest
    self:Print("target guild set: " .. rest)
  elseif cmd == "refresh" or cmd == "scan" then
    ns.Roster:RequestWhoScan()
  elseif cmd == "interval" then
    if rest == "" then
      self:Print("auto-scan interval: " .. self.db.realm.scanIntervalMin .. " min (0 = off)")
      return
    end
    local n = tonumber(rest)
    if not n or n < 0 then
      self:Print("usage: /gm interval <minutes>  (0 disables)")
      return
    end
    self.db.realm.scanIntervalMin = math.floor(n)
    ns.Roster:StartAutoScan()
    self:Print("auto-scan interval: " .. self.db.realm.scanIntervalMin .. " min")
  elseif cmd == "export" then
    ns.IO:ShowExport()
  elseif cmd == "import" then
    ns.IO:ShowImport()
  elseif cmd == "history" or cmd == "log" then
    local arg = (rest or ""):lower()
    if arg == "" then
      ns.History:PrintRecent(20)
    elseif arg == "all" then
      ns.IO:ShowText(
        "GuildMute — History",
        ("Filtered this session: %d entries (cleared on /reload)."):format(ns.History:Count()),
        ns.History:BuildText()
      )
    elseif arg == "clear" then
      ns.History:Clear()
      self:Print("history cleared")
    elseif arg == "on" then
      self.db.realm.historyEnabled = true
      self:Print("history: ON")
    elseif arg == "off" then
      self.db.realm.historyEnabled = false
      ns.History:Clear()
      self:Print("history: OFF (buffer cleared)")
    else
      local n = tonumber(arg)
      if n and n > 0 then
        ns.History:PrintRecent(math.floor(n))
      else
        self:Print("usage: /gm history [N|all|clear|on|off]")
      end
    end
  elseif cmd == "add" then
    if rest == "" then
      self:Print("usage: /gm add <Charname>")
      return
    end
    if ns.Roster:Add(rest, "manual") then
      self:Print("added: " .. rest)
    else
      self:Print("already muted: " .. rest)
    end
  elseif cmd == "remove" or cmd == "rm" or cmd == "del" then
    if rest == "" then
      self:Print("usage: /gm remove <Charname>")
      return
    end
    if ns.Roster:Remove(rest) then
      self:Print("removed: " .. rest)
    else
      self:Print("not in list: " .. rest)
    end
  elseif cmd == "list" then
    ns.Roster:PrintList()
  elseif cmd == "clear" then
    ns.Roster:Clear()
    self:Print("mute list cleared")
  elseif cmd == "toggle" then
    self.db.realm.enabled = not self.db.realm.enabled
    self:Print("filtering: " .. (self.db.realm.enabled and "ON" or "OFF"))
  elseif cmd == "status" then
    local count = 0
    for _ in pairs(self.db.realm.muted) do
      count = count + 1
    end
    self:Print(
      ("guild=%s | muted=%d | filter=%s | autoscan=%s"):format(
        self.db.realm.targetGuild,
        count,
        self.db.realm.enabled and "ON" or "OFF",
        self.db.realm.scanIntervalMin > 0 and (self.db.realm.scanIntervalMin .. "min") or "off"
      )
    )
  else
    help(self)
  end
end
