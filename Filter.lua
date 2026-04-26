local ADDON_NAME, ns = ...
local Filter = {}
ns.Filter = Filter

local FILTERED_EVENTS = {
  "CHAT_MSG_WHISPER",
  "CHAT_MSG_PARTY",
  "CHAT_MSG_PARTY_LEADER",
  "CHAT_MSG_RAID",
  "CHAT_MSG_RAID_LEADER",
  "CHAT_MSG_RAID_WARNING",
  "CHAT_MSG_INSTANCE_CHAT",
  "CHAT_MSG_INSTANCE_CHAT_LEADER",
}

function Filter:Initialize(addon)
  self.addon = addon
  for _, ev in ipairs(FILTERED_EVENTS) do
    ChatFrame_AddMessageEventFilter(ev, function(chatFrame, event, ...)
      return self:OnMessage(chatFrame, event, ...)
    end)
  end
end

function Filter:OnMessage(chatFrame, event, msg, sender)
  if not self.addon.db.realm.enabled then
    return false
  end
  if not sender or sender == "" then
    return false
  end
  if ns.Roster:Has(sender) then
    -- ChatFrame_AddMessageEventFilter calls this once per chat frame; only record
    -- on the first frame's pass so duplicates don't pile up in the history.
    if chatFrame == DEFAULT_CHAT_FRAME then
      ns.History:Record(event, sender, msg)
    end
    return true -- suppress the message in this chat frame
  end
  return false
end
