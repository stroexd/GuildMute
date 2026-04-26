std = "lua51"
max_line_length = 120
codes = true

ignore = {
  "212/self", -- unused argument self (Ace3 methods)
  "212/_",    -- unused vararg names
  "431",      -- shadowing upvalue (common in Ace3)
}

globals = {
  "LibStub",
  "GuildMuteDB",
}

read_globals = {
  "UnitExists", "UnitIsPlayer", "UnitName", "GetGuildInfo",
  "GetTime", "time", "date", "wipe", "tonumber",
  "C_Timer", "C_FriendList",
  "SendWho", "GetNumWhoResults", "GetWhoInfo",
  "ChatFrame_AddMessageEventFilter",
  "DEFAULT_CHAT_FRAME",

  -- UI for export/import frame
  "CreateFrame", "UIParent", "ChatFontNormal",
}
