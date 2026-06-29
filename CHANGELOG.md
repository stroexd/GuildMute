# Changelog

All notable changes to **GuildMute** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.1] - 2026-06-29

### Fixed
- WIM compatibility: GuildMute's chat filter is now inserted at position 1 of
  `ChatFrame_MessageEventFilters` so it runs before WIM's filter. WIM redirects
  whispers to its popup windows via the same filter mechanism and stops the chain
  with `return true`; if WIM registered first, GuildMute's filter never ran.
- `/gm guild <Name>` now warns when the target guild is changed and the mute list
  still holds entries from the previous guild, with hints for `/gm scan` (add new
  members) or `/gm clear` (start fresh). Previously there was no feedback at all.

## [0.5.0] - 2026-06-03

### Fixed
- Removed the periodic `/who` auto-scan. `SendWho()`/`C_FriendList.SendWho()` is
  a protected function that only runs from a hardware event (keypress/click), so
  the timer-driven scan was blocked on Anniversary realms with
  `ADDON_ACTION_BLOCKED: GuildMute tried to call the protected function 'SendWho()'`.

### Changed
- The roster now fills passively (mouseover/target) plus manual `/gm scan`.
- Removed the `/gm interval` command and the `scanIntervalMin` setting; `/gm status`
  no longer shows an auto-scan field.

## [0.4.1] - 2026-04-26

### Added
- `X-Curse-Project-ID: 1526012` in the TOC. Tagged releases now upload
  to CurseForge in addition to creating a GitHub release.

## [0.4.0] - 2026-04-26

First public release.

### Changed
- Removed the hardcoded `Dawnwalkers` default. Users must set the target guild
  on first start with `/gm guild <Name>`. Until set, GuildMute idles silently.
- All places that read `targetGuild` now handle the unset case.
- Setting the guild now also (re)starts the auto-scan ticker.
- `.gitignore` aligned with HeyListen; `.idea/` and `dev-link.sh` are no longer
  tracked.

### Added
- `LICENSE` (MIT), `CHANGELOG.md`, `.pkgmeta`, GitHub Actions release workflow,
  `X-License` and `X-Website` TOC fields.

## [0.3.0] - 2026-04-26

### Added
- In-session history of filtered messages: a 200-entry ring buffer kept only in
  memory (never written to SavedVariables, cleared on `/reload`).
- `/gm history [N]` prints the last N filtered messages to chat (default 20).
- `/gm history all` opens a read-only viewer with the full buffer.
- `/gm history clear|on|off` controls the buffer.
- Generic read-only text viewer (`IO:ShowText`) reused for the history view.

## [0.2.0] - 2026-04-26

### Added
- Periodic `/who` scan with configurable interval. Configurable via
  `/gm interval <minutes>`; default 30, `0` disables.
- Auto-scan on login and `/reload` (via `PLAYER_ENTERING_WORLD`), fires roughly
  five seconds after world enter so the server is ready.
- Export/Import frame for sharing the muted-name list across characters or
  accounts: `/gm export` shows a copyable text block, `/gm import` merges a
  pasted payload.
- `auto-scan` field added to the `/gm status` summary.

### Changed
- Auto-scans only print to chat when new names are found, to avoid spam.

## [0.1.0] - 2026-04-26

### Added
- Initial implementation. Filters chat from members of a target guild on
  TBC Classic Anniversary (Interface 20505).
- Filtered events: `CHAT_MSG_WHISPER`, `CHAT_MSG_PARTY[_LEADER]`,
  `CHAT_MSG_RAID[_LEADER]`, `CHAT_MSG_RAID_WARNING`,
  `CHAT_MSG_INSTANCE_CHAT[_LEADER]`.
- Three ways to build the mute list:
  - silent auto-learn from `UPDATE_MOUSEOVER_UNIT` / `PLAYER_TARGET_CHANGED`
    via `GetGuildInfo(unit)`,
  - on-demand `/gm refresh` running `/who g-"<Guild>"`,
  - manual `/gm add <Charname>`.
- Per-realm `SavedVariables` (`GuildMuteDB`).
- Slash commands `/guildmute`, `/gm`: `guild`, `refresh`, `add`, `remove`,
  `list`, `clear`, `toggle`, `status`.

[0.5.1]: https://github.com/stroexd/GuildMute/releases/tag/v0.5.1
[0.4.1]: https://github.com/stroexd/GuildMute/releases/tag/v0.4.1
[0.4.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.4.0
[0.3.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.3.0
[0.2.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.2.0
[0.1.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.1.0
