# GuildMute

Personal TBC Classic Anniversary addon (Interface 20505).

Hides whispers, party, and raid chat from members of a configured guild. Default target guild is `Dawnwalkers`.

## How it builds the mute list

You are not in the target guild, so `GetGuildRosterInfo` is unavailable. GuildMute populates the list three ways:

1. **Auto-learn (silent):** when you mouse over or target a player, GuildMute reads `GetGuildInfo(unit)`. If the guild matches the target, the name is added.
2. **`/gm refresh`:** runs `/who g-"GuildName"` and stores every match. Limited to 49 results per scan by the server; large guilds need multiple scans with level filters.
3. **`/gm add <Name>`:** manual addition.

The list is persisted per realm in `GuildMuteDB`.

## Slash commands

```
/gm guild <Name>      set the target guild (default: Dawnwalkers)
/gm refresh           run a /who scan now
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
