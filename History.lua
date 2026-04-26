local ADDON_NAME, ns = ...
local History = {}
ns.History = History

local MAX_ENTRIES = 200

-- Short channel labels for compact log display.
local CHANNEL_LABEL = {
  CHAT_MSG_WHISPER = "W",
  CHAT_MSG_PARTY = "P",
  CHAT_MSG_PARTY_LEADER = "P",
  CHAT_MSG_RAID = "R",
  CHAT_MSG_RAID_LEADER = "R",
  CHAT_MSG_RAID_WARNING = "RW",
  CHAT_MSG_INSTANCE_CHAT = "I",
  CHAT_MSG_INSTANCE_CHAT_LEADER = "I",
}

function History:Initialize(addon)
  self.addon = addon
  self.entries = {}
end

function History:Record(event, sender, msg)
  if not self.addon.db.realm.historyEnabled then
    return
  end
  table.insert(self.entries, {
    t = time(),
    ch = CHANNEL_LABEL[event] or "?",
    sender = sender or "?",
    msg = msg or "",
  })
  while #self.entries > MAX_ENTRIES do
    table.remove(self.entries, 1)
  end
end

function History:Count()
  return #self.entries
end

function History:Clear()
  wipe(self.entries)
end

local function formatEntry(e)
  return ("[%s] [%s] %s: %s"):format(date("%H:%M:%S", e.t), e.ch, e.sender, e.msg)
end

-- Print up to `n` most-recent entries to the chat (oldest first within the window).
function History:PrintRecent(n)
  n = n or 20
  local total = #self.entries
  if total == 0 then
    self.addon:Print("history is empty (this session)")
    return
  end
  local from = math.max(1, total - n + 1)
  self.addon:Print(("history: showing %d of %d (this session)"):format(total - from + 1, total))
  for i = from, total do
    self.addon:Print(formatEntry(self.entries[i]))
  end
end

-- Render the full buffer to a single string for the IO frame.
function History:BuildText()
  local lines = {}
  for _, e in ipairs(self.entries) do
    table.insert(lines, formatEntry(e))
  end
  return table.concat(lines, "\n")
end
