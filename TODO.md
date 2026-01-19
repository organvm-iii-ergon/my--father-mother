my--father-mother TODO
======================

Light (keep on)
- Add small status badge in HTML for cap/backpressure warnings (pulls /status). ✅
- Quick keyboard shortcuts in web UI (Enter=search, Cmd/Ctrl+F focuses search input). ✅
- Auto-refresh recent/topics every N seconds when idle toggle in UI. ✅

Medium (opt-in helpers)
- Add “rewrite/shorten/extract” helper commands that shell out to user-provided scripts (stdin=clip, stdout=rewrite), with CLI/API endpoints. ✅
- Optional “session notes” capture: append manual notes to a clip id and surface in UI. ✅
- Export tags/topics as markdown outline grouped by app/time for daily journal. ✅

Heavy (explicit toggle)
- Menubar mini-UI (Electron/SwiftBar) for search/paste/pin with offline cache. (SwiftBar stub added)
- Sync/remote backup targets (S3-compatible, iCloud Drive folder) with manual “push/pull”. ✅ (local path push/pull)
- Multi-device federation (peer-to-peer or pull-only) with conflict-free merge of clips/tags. ✅ (JSON export/import endpoints + push/pull helpers; dedup by hash)
- Browser extension-level dropper (context menu + highlights) instead of bookmarklet. ✅ (dropper endpoint + sample MV3 extension)
- Advanced AI helpers: retrieval-based “recall summary” and “fill gaps” using local model if available or user-provided API key, strictly off by default. ✅ (recall/fill helpers via user commands)

Notes
- All heavies should remain behind config flags/env to avoid bloating the always-on watcher loop.
- When adding new helpers, surface toggles in `config` and `/status` and keep CLI/API symmetry.
- Login autostart helpers: copy desired plist(s) to ~/Library/LaunchAgents and load (serve, mcp, tmux/menu).
