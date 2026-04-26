local ADDON_NAME, ns = ...
local IO = {}
ns.IO = IO

function IO:Initialize(addon)
  self.addon = addon
end

-- Export format (one item per line):
--   GuildMute v1
--   guild=<TargetGuildName>
--   <playername>
--   <playername>
--   ...
local function buildExportText(addon)
  local lines = { "GuildMute v1", "guild=" .. (addon.db.realm.targetGuild or "") }
  local names = {}
  for k in pairs(addon.db.realm.muted) do
    table.insert(names, k)
  end
  table.sort(names)
  for _, n in ipairs(names) do
    table.insert(lines, n)
  end
  return table.concat(lines, "\n"), #names
end

local function parseImport(text)
  local names, header, guild = {}, false, nil
  for raw in text:gmatch("[^\r\n]+") do
    local line = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if line ~= "" and not line:match("^#") then
      if not header and line:match("^GuildMute") then
        header = true
      elseif line:match("^guild=") then
        guild = line:sub(7):gsub("^%s+", ""):gsub("%s+$", "")
      else
        table.insert(names, line)
      end
    end
  end
  return names, guild
end

local frame
local function ensureFrame()
  if frame then
    return frame
  end
  local f = CreateFrame("Frame", "GuildMuteIOFrame", UIParent, "BasicFrameTemplateWithInset")
  f:SetSize(420, 360)
  f:SetPoint("CENTER")
  f:SetFrameStrata("DIALOG")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()

  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  f.title:SetPoint("TOP", 0, -5)

  f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  f.hint:SetPoint("TOPLEFT", 14, -28)
  f.hint:SetPoint("TOPRIGHT", -14, -28)
  f.hint:SetJustifyH("LEFT")

  local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 14, -50)
  scroll:SetPoint("BOTTOMRIGHT", -32, 44)
  f.scroll = scroll

  local edit = CreateFrame("EditBox", nil, scroll)
  edit:SetMultiLine(true)
  edit:SetMaxLetters(0)
  edit:SetFontObject(ChatFontNormal)
  edit:SetWidth(scroll:GetWidth())
  edit:SetAutoFocus(false)
  edit:SetScript("OnEscapePressed", function()
    f:Hide()
  end)
  scroll:SetScrollChild(edit)
  f.edit = edit

  local action = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  action:SetSize(110, 22)
  action:SetPoint("BOTTOMRIGHT", -10, 10)
  f.action = action

  local cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  cancel:SetSize(80, 22)
  cancel:SetPoint("RIGHT", action, "LEFT", -6, 0)
  cancel:SetText("Close")
  cancel:SetScript("OnClick", function()
    f:Hide()
  end)
  f.cancel = cancel

  frame = f
  return f
end

function IO:ShowExport()
  local f = ensureFrame()
  local text, count = buildExportText(self.addon)
  f.title:SetText("GuildMute — Export")
  f.hint:SetText(("Copy this text (Ctrl+A, Ctrl+C). %d name(s)."):format(count))
  f.edit:SetText(text)
  f.edit:HighlightText()
  f.edit:SetFocus()
  f.action:SetText("Close")
  f.action:SetScript("OnClick", function()
    f:Hide()
  end)
  f:Show()
end

function IO:ShowImport()
  local f = ensureFrame()
  f.title:SetText("GuildMute — Import")
  f.hint:SetText("Paste exported text (Ctrl+V) and press Import. Existing entries are kept.")
  f.edit:SetText("")
  f.edit:SetFocus()
  f.action:SetText("Import")
  f.action:SetScript("OnClick", function()
    local raw = f.edit:GetText() or ""
    local names, guild = parseImport(raw)
    if guild and guild ~= "" then
      self.addon.db.realm.targetGuild = guild
    end
    local added = 0
    for _, n in ipairs(names) do
      if ns.Roster:Add(n, "import") then
        added = added + 1
      end
    end
    self.addon:Print(
      ("import: +%d new (%d in payload). Guild: %s"):format(added, #names, self.addon.db.realm.targetGuild)
    )
    f:Hide()
  end)
  f:Show()
end
