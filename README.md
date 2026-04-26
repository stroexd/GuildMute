# GuildMute

**Hides whispers, party, and raid chat from members of a guild you choose**, so unwanted chatter never lands in your chat windows. The mute list builds itself in the background; you only tell it which guild to silence.

## Why

Some guilds talk a lot. If you regularly group with members of a guild whose chatter you'd rather not see — for raid focus, drama, language, or just personal preference — **GuildMute** silently filters their messages out of every chat frame.

- **Whisper (incoming)** → suppressed
- **Party** / party leader → suppressed
- **Raid** / raid leader / raid warning → suppressed
- **Instance chat** (LFG dungeon) → suppressed
- Guild membership is detected automatically via mouseover, target, and periodic `/who` scans

Pure Lua addon — no external tools, no companion app, no setup beyond installing it and naming the guild.

## Requirements

- TBC Classic / Anniversary (Interface `2.5.x`)
- A target guild — there is **no default**, GuildMute is idle until you set one

## Installation

Install via your addon manager (CurseForge app, etc.), or unpack into the AddOns folder:

```
World of Warcraft/_classic_/Interface/AddOns/GuildMute/
```

For Anniversary realms:

```
World of Warcraft/_anniversary_/Interface/AddOns/GuildMute/
```

## Setup

On first login, set the target guild:

```
/gm guild <GuildName>
```

For example, to silence the guild *test*:

```
/gm guild test
```

Until you set this, GuildMute idles silently and filters nothing.

The mute list then starts populating itself:

- Every time you mouse over or target a player from the target guild, they're **silently added** in the background.
- Every 30 minutes (and once a few seconds after login or `/reload`), GuildMute runs `/who g-"<Guild>"` and harvests the results.
- You can trigger a scan on demand with `/gm refresh`, or add names manually with `/gm add <Charname>`.

After a few raids or world sessions, the list typically covers most active members.

## Sharing the list across characters

Each character on each realm has its own SavedVariables, so the list does not auto-sync. Use the export/import flow:

- On the source character: `/gm export` → a window opens with the full list, ready to copy.
- On the destination character: `/gm import` → paste the text and click *Import*. Existing entries are kept; the target guild is overwritten if present in the payload.

This is useful for multi-boxing or playing alts on the same realm.

## Commands

All commands also work with `/guildmute` as a long-form alias.

| Command | What it does |
|---|---|
| `/gm guild <Name>` | Set the target guild (required) |
| `/gm refresh` | Run a `/who` scan now |
| `/gm interval <min>` | Auto-scan every N minutes (`0` = off; default: 30) |
| `/gm add <Charname>` | Add a name manually |
| `/gm remove <Charname>` | Remove a name |
| `/gm list` | Show all muted names on this realm |
| `/gm clear` | Empty the mute list |
| `/gm toggle` | Enable / disable filtering globally |
| `/gm status` | Show summary (guild, count, filter, autoscan interval) |
| `/gm export` | Open a window with the list, ready to copy |
| `/gm import` | Paste a list to merge into this character |
| `/gm history` | Show the last 20 filtered messages this session |
| `/gm history <N\|all>` | Show the last N, or open a viewer with everything |
| `/gm history clear` | Wipe the in-memory history buffer |
| `/gm history on\|off` | Enable / disable history recording |

## Limitations

- `/who` is rate-limited by the server (about a 5-second cooldown) and returns **at most 49 hits per query**. Large guilds need either multiple scans with level filters or patience while auto-learn fills in.
- Sender names are matched **without realm suffix**. On TBC Classic, where cross-realm chat in PUGs is rare, this is essentially a non-issue — but in theory a stranger on another realm sharing a name with a muted character would also be filtered.
- **History is in-memory only** and clears on `/reload`. This is intentional: whisper bodies never land on disk.
- Only **incoming** messages are filtered. Your own outgoing whispers and party/raid messages to muted characters are not blocked — you stay in control.
- Settings are stored **per realm**. Configure each realm separately (or use `/gm export` / `/gm import` to seed a new one).

## License

MIT — see [LICENSE](LICENSE).

## Author

Stroe-Spineshatter
