# Changelog

All notable changes to **GuildMute** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.4.1]: https://github.com/stroexd/GuildMute/releases/tag/v0.4.1
[0.4.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.4.0
[0.3.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.3.0
[0.2.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.2.0
[0.1.0]: https://github.com/stroexd/GuildMute/releases/tag/v0.1.0
