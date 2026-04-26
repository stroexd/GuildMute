# GuildMute

TBC Classic Anniversary addon (Interface 20505).

Hides whispers, party, and raid chat from members of a guild you choose. On first start, set the target guild with:

```
/gm guild <GuildName>
```

There is no default target — nothing is filtered until you set one.

## How it builds the mute list

You are not in the target guild, so `GetGuildRosterInfo` is unavailable. GuildMute populates the list four ways:

1. **Auto-learn (silent):** when you mouse over or target a player, GuildMute reads `GetGuildInfo(unit)`. If the guild matches the target, the name is added.
2. **Periodic `/who` scan:** every N minutes (default 30) and once on login/`/reload`, GuildMute runs `/who g-"GuildName"` and harvests results. Auto-scans only print when something new was found.
3. **`/gm refresh`:** runs the same scan on demand.
4. **`/gm add <Name>`:** manual addition.

The list is persisted per realm in `GuildMuteDB`.

## Sharing between characters

Multiboxing or playing alts on the same realm? Use export/import to copy the list across characters (each character has its own SavedVariables):

- `/gm export` — opens a window with the full list, ready to copy.
- `/gm import` — opens an empty window; paste an exported text and click Import. Existing entries are kept; the target guild is overwritten if present in the payload.

## Slash commands

```
/gm guild <Name>      set the target guild (required, no default)
/gm refresh           run a /who scan now
/gm interval <min>    auto-scan every N minutes (0 = off; default: 30)
/gm export            open a window with the list, ready to copy
/gm import            paste a list to merge into this character
/gm history [N]       show the last N filtered messages (default 20)
/gm history all       open a window with everything filtered this session
/gm history clear     wipe the in-memory buffer
/gm history on|off    enable/disable recording (in-memory only; never saved)
/gm add <Charname>    add a name manually
/gm remove <Charname> remove a name
/gm list              show all muted names on this realm
/gm clear             empty the list
/gm toggle            enable/disable filtering
/gm status            summary
```

## Filtered chat events

`CHAT_MSG_WHISPER`, `CHAT_MSG_PARTY`, `CHAT_MSG_PARTY_LEADER`, `CHAT_MSG_RAID`, `CHAT_MSG_RAID_LEADER`, `CHAT_MSG_RAID_WARNING`, `CHAT_MSG_INSTANCE_CHAT`, `CHAT_MSG_INSTANCE_CHAT_LEADER`.

## Dev

```
./dev-link.sh '/path/to/_classic_/Interface/AddOns'
# in-game:
/reload
```
