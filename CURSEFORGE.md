# CurseForge listing copy

Use this when filling in the CurseForge project page. Summary goes in the
short-description field (visible in search results). The long description
goes in the project's About / Description tab; CurseForge accepts Markdown.

---

## Summary (pick one)

**Long (~190 chars):**

> Hide whispers, party, raid, and instance chat from members of a guild you choose. Builds the mute list automatically via /who scans and silent guild lookups. TBC Classic / Burning Crusade Classic.

**Short (~115 chars):**

> Mute every whisper, party, and raid message from members of a guild you pick. Auto-builds the list. TBC Classic.

---

## Long description

# GuildMute

Hide whispers and party/raid chatter from members of a specific guild on
TBC Classic Anniversary.

## Why?

Some guilds talk a lot. If you regularly end up grouped with members of a
guild whose chatter you'd rather not see — for raid focus, drama, language,
or just personal preference — GuildMute silently filters their messages out
of your chat frames.

## Features

- Filters incoming **whispers, party, raid, raid warnings, and instance
  chat** from members of a single guild you configure.
- Builds the muted-name list four ways:
  - **Silent auto-learn** when you mouse over or target a player whose
    guild matches the target.
  - **Periodic /who scan** every 30 minutes (configurable; also fires
    once on login and `/reload`).
  - **Manual `/gm refresh`** to scan on demand.
  - **Manual `/gm add <Name>`** for one-offs.
- **In-session history** of what got filtered so you can audit it. Kept
  in RAM only; whisper bodies are never written to SavedVariables.
- **Export / Import** the muted list between characters or accounts via
  a copyable text window — useful when multi-boxing or playing alts on
  the same realm.
- **Per-realm storage**: each realm has its own list and target guild.
- **Toggle on/off** without losing the list.

## First start

```
/gm guild <GuildName>
```

No default target is set — until you configure this, GuildMute idles
silently and filters nothing.

## Slash commands

```
/gm guild <Name>      set the target guild (required)
/gm refresh           run a /who scan now
/gm interval <min>    auto-scan every N minutes (0 = off; default: 30)
/gm export            open a window with the list, ready to copy
/gm import            paste a list to merge into this character
/gm history [N|all]   show what was filtered this session
/gm add <Charname>    add a name manually
/gm remove <Charname> remove a name
/gm list              show all muted names on this realm
/gm clear             empty the list
/gm toggle            enable/disable filtering
/gm status            summary
```

## Notes

- `/who` is rate-limited by the server (about five seconds) and returns
  at most 49 results per query. Large guilds are best learned organically
  over time through mouseover/target lookups plus repeated periodic scans.
- Sender names are matched without realm suffix. On TBC Classic, where
  cross-realm chat in PUGs is rare, this is essentially a non-issue.
- History recording is in-memory only by design.

## Source

[github.com/stroexd/GuildMute](https://github.com/stroexd/GuildMute) — MIT.
