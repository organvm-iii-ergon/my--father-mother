my--father-mother
==================

Lightweight, local-only “long term memory” for your Mac clipboard. It listens to the system clipboard (same stream Paste sees), stores snippets in SQLite with full-text search, and lets you recall by keyword or recency. No cloud, no telemetry.

Personas and domains
- Mother (moon): runs the watcher, records metadata, dedups, prunes to cap.
- Father (sun): runs search, recent, delete, stats, blocklist management, and keeps the index healthy.

What it does
- Captures clipboard text with timestamp and frontmost app/window title metadata.
- Deduplicates identical clips and caps history size (configurable).
- SQLite store with FTS5 for fast keyword search, with filters by app/tag/substring.
- Tags and pins for organizing; copy a stored clip back to clipboard.
- Session notes: append per-clip notes (UI/CLI/API) and see them alongside results/topics.
- Helper transforms: configurable rewrite/shorten/extract helpers that shell out to your scripts (stdin=clip, stdout=result), saved as new tagged clips.
- Markdown journaling: export recent clips grouped by date/app/tags as an outline for your daily notes.
- Optional sync push/pull to a path (e.g., iCloud Drive) and a SwiftBar menubar stub for quick glance.
- Context bundles: `/context` + CLI `context` to dump recent clips for LLM sidecars by app/tag/time.
- Configurable safety: skips secrets by default; set `allow_secrets` true to store everything. Max clip size defaults to 16KB; configurable.
- Optional toasts: enable notifications to get a macOS banner when clips are saved or skipped.
- Capture history: repeat sightings are logged; view with `history`.
- Semantic search: hash-based by default; opt into `e5-small` embeddings (`config --set embedder e5-small`) for better meaning search.
- Light language detection: a per-clip language code is stored for display/tooling.
- Filters: date ranges (`--since/--since-hours/--until`), pin-only, app/tag filters in CLI/API/UI.
- Topic buckets: group recent clips by tag (or app when untagged) via CLI/API/UI.
- Caps: per-app/per-tag caps, tiered eviction (prefer non-pinned), DB cap with backpressure warnings.
- Medium ingest: optional PDF ingest (`pdftotext`), optional OCR image ingest (`tesseract`), manual backup/restore.
- Smart hooks: optional auto-summary/title and auto-tag via user-provided shell commands.
- File inbox: ingest individual files or watch an inbox directory for text/code drops.
- Meeting ingest: `ingest-transcript` tags meeting/transcript inputs automatically.
- Simple federation: export/import endpoints (`/federate_export`, `/federate_import`), CLI `federate-export`, `federate-import` (path/url), and `federate-push` to send to a peer.
- Recap: summarize last N minutes grouped by app (CLI `recap`, API `/recap`).
- Minimal web UI: `serve` now serves `/` with a simple search/recent page.
- Status indicator: the web UI calls `/status` to show paused/active + notify/secrets flags.
- Settings parity snapshot: `settings` summarizes account/cloud/copilot/ML/UI/telemetry/about, with focused commands for copilot/ML/about.
- Editor-friendly fetch: `scripts/mfm-fetch.sh` to grab latest/by-id/query to stdout or clipboard (use with IDE external tools).
- IDE integration: bind `mfm-fetch.sh` to a hotkey/command in your editor (examples below).
- Browser drop: POST `/ingest_url` (bookmarklet snippet below) to save the current page URL/title/selection into the store.
- Browser dropper endpoint `/dropper` for extensions/contexts (title/url/selection/html payloads). Sample Chrome MV3 extension lives in `scripts/extension-dropper/`.
- fzf palette: `scripts/mfm-fzf.sh` for an interactive picker in terminal.
- rofi palette: `scripts/mfm-rofi.sh` for a GUI-ish picker (needs `rofi`).
- Optional SwiftBar menubar snippet: `scripts/mfm-swiftbar.1s.sh` (reads `/status`, lists recent, copy/pin, pause/resume). If HTTP is blocked, set `MFM_FORCE_CLI=1` and `MFM_REPO_DIR=/Users/4jp/Workspace/my--father-mother`.
- Integrations cookbook: see `INTEGRATIONS.md` for JetBrains/VS Code/Sublime/Obsidian/JupyterLab/Raycast/Chrome wiring examples.
- MCP bridge: `scripts/mcp_server.py` exposes a minimal MCP-style server at `http://127.0.0.1:39300/model_context_protocol/2025-03-26/mcp` (resources: recent, context, search, SSE heartbeat).
- LaunchAgent for MCP: `com.my-father-mother.mcp.plist` — copy to `~/Library/LaunchAgents/` and `launchctl load ~/Library/LaunchAgents/com.my-father-mother.mcp.plist` to auto-start the MCP bridge at login.
- LaunchAgents summary: see `LAUNCH_AGENTS.md` for quick install/unload steps for watcher/serve/MCP.
- Simple CLI:
  - `init` to create the database
  - `watch` to run the capture loop (Moon)
  - `recent` to list latest items (Father)
  - `search` to query by keyword (Father)
  - `semantic-search` to query by meaning (hashed embeddings) (Father)
  - `delete` to remove entries by id (Father)
  - `stats` to show counts/db size (Father)
  - `status` to show paused/notify/limits/db size (Father)
  - `settings` to show settings parity snapshot (Father)
  - `copilot` to manage copilot settings/chats (Father)
  - `ml` to manage machine learning/LTM settings (Father)
  - `mcp-urls` to print MCP server URLs (SSE + MCP)
  - `about` to show app/runtime details (Father)
  - `pause` to pause/resume/toggle capture (Mother)
  - `blocklist` to add/remove/list blocked apps (Father)
  - `pin` to pin/unpin clips (Father)
  - `copy` to copy a stored clip back to clipboard (Father)
  - `history` to show capture history for a clip (Father)
  - `show` to print a specific clip (Father)
  - `export` to JSON (Father)
  - `export-md` to Markdown journal outline (Father)
  - `config` to get/set max_bytes, max_db_mb, allow_secrets, notify, embedder (Father)
  - `purge` to delete by age/app/keep-last/all (Father)
  - `tags` to add/remove/list tags (Father)
  - `note` to append/list session notes for a clip (Father)
  - `ingest-file` to ingest a specific file (Mother)
  - `ingest-transcript` to ingest a meeting transcript/text with meeting/transcript tags (Mother)
  - `watch-inbox` to watch a directory and ingest files (Mother)
  - `recap` to summarize recent clips by app over a window (Father)
  - `related` to find semantic neighbors of a clip (Father)
  - `palette` to interactively pick & copy a clip (Father)
  - `topics` to bucket recent clips by tag/app (Father)
  - `rewrite` / `shorten` / `extract` to run your helper scripts on a clip and save the result (Father)
  - `recall` / `fill` to run AI helper scripts over recent clips (opt-in, off by default)
  - `context` to dump a bundle of recent clips for external LLMs/sidecars (Father)
  - `sync` to push/pull DB to a configured path (Father)
  - `federate-export` / `federate-import` / `federate-push` for simple multi-device handoff (JSON-based)
  - `install-launchagent` to install/remove a login watcher (Father)
  - `serve` to run a local HTTP API (Father)
  - `personas` to print roles/domains
- Dual-pane tmux helper: `scripts/mfm-dual.sh` (left: Mother watcher, right: Father shell).
- Menu helper: `scripts/mfm-menu.sh` to launch watcher/shell/serve/palette/recent/recap; LaunchAgent plist provided.
- Serve helper: `scripts/mfm-serve.sh` and LaunchAgent plist to auto-run the web UI/API.
- Serve will try up to 3 consecutive ports if the requested port is not bindable.
- Local-only: data is stored at `~/.my-father-mother/mfm.db`.

What it does not (yet)
- Heavy AI helpers, screenshots/OCR, sync/sharing, or polished IDE/browser extensions. Those can be layered later.

Requirements
- macOS with `pbpaste` and `osascript` available.
- Python 3.10+ (stdlib only).
- Optional: `pip install sentence-transformers langdetect` to enable e5-small embeddings + language codes.
- Optional: `brew install poppler tesseract` for PDF (`pdftotext`) and OCR ingest.

Usage
```bash
cd ~/Workspace/my--father-mother
python3 main.py init               # create DB at ~/.my-father-mother/mfm.db
python3 main.py watch --cap 5000   # start watcher (Mother/moon), keep last 5k clips
python3 main.py watch --notify     # watch with macOS toasts on save/skip
python3 main.py config --set max_bytes 32768  # optional: increase max clip size
python3 main.py config --set allow_secrets true  # allow secret-like clips
python3 main.py config --set notify true  # persistently enable toasts
python3 -m pip install --upgrade sentence-transformers langdetect  # optional: better semantics + language codes
python3 main.py config --set embedder e5-small  # switch to e5-small embeddings
python3 main.py config --set cap_by_app '{"terminal":1000,"chrome":2000}'  # optional per-app caps
python3 main.py config --set cap_by_tag '{"work":1500}'  # optional per-tag caps
python3 main.py config --set evict_mode tiered  # prefer evicting non-pinned when over DB cap
python3 main.py config --set allow_pdf true  # allow PDF ingest (requires pdftotext)
python3 main.py config --set allow_images true  # allow image OCR ingest (requires tesseract)
python3 main.py config --set auto_summary_cmd "your-cmd"  # optional summary hook (stdin=clip, stdout=summary)
python3 main.py config --set auto_tag_cmd "your-cmd"      # optional tag hook (stdin=clip, stdout=tags)
python3 main.py config --set helper_rewrite_cmd "your-cmd"  # set rewrite helper (stdin=clip, stdout=rewrite)
python3 main.py config --set helper_shorten_cmd "your-cmd"  # set shorten helper
python3 main.py config --set helper_extract_cmd "your-cmd"  # set extract helper
python3 main.py recent --limit 10  # show last 10 entries (Father/sun)
python3 main.py recent --since-hours 24 --pins-only  # last 24h pinned
python3 main.py search "docker env" --limit 5  # keyword FTS search (Father/sun)
python3 main.py search "docker env" --since "2025-01-01T00:00:00" --until "2025-01-07"  # date range
python3 main.py semantic-search "auth token reset" --limit 5  # semantic search (Father/sun)
python3 main.py stats              # count, db size, latest timestamp (Father/sun)
python3 main.py status             # paused/notify/limits/db size (Father/sun)
python3 main.py settings           # settings parity snapshot (Father/sun)
python3 main.py copilot --set-model gemini-2.5-flash  # set copilot model
python3 main.py ml --context-level medium             # set auto-context level
python3 main.py mcp-urls           # print MCP server URLs (SSE + MCP)
python3 main.py about              # app/runtime details
python3 main.py pause --on         # pause capture (Mother/moon)
python3 main.py pause --off        # resume capture (Mother/moon)
python3 main.py blocklist --add "Slack"   # block captures from Slack (Father/sun)
python3 main.py blocklist --list          # show blocked apps (Father/sun)
python3 main.py pin --id 12 --on   # pin a clip (Father/sun)
python3 main.py copy --id 12       # copy clip content back to clipboard (Father/sun)
python3 main.py history --id 12    # view capture history for clip #12
python3 main.py show --id 12       # print full clip (Father/sun)
python3 main.py export --limit 200 --path /tmp/clips.json  # export to JSON (Father/sun)
python3 main.py recent --app "Chrome" --contains "token"   # filter recent by app/substring
python3 main.py search "docker env" --app "Terminal"       # search within app
python3 main.py tags --id 12 --add projectx --add auth     # tag a clip
python3 main.py tags --list-all                            # list all tags
python3 main.py note --id 12 --text "important context"    # append a note to clip 12
python3 main.py purge --tag projectx --keep-last 100       # purge for a tag
python3 main.py purge --older-than-days 30                 # purge clips older than 30 days
python3 main.py purge --keep-last 500                      # keep newest 500, delete rest
python3 main.py ingest-file --path ~/Desktop/snippet.txt   # ingest a single file (Mother/moon)
python3 main.py ingest-transcript --path ~/meeting.txt     # ingest transcript and tag meeting/transcript
python3 main.py watch-inbox --dir ~/.my-father-mother/inbox --interval 5  # watch/drop folder (Mother/moon)
python3 main.py related --id 12 --limit 5                  # semantic neighbors of a clip (Father/sun)
python3 main.py recap --minutes 60                         # recap last hour grouped by app (Father/sun)
python3 main.py context --app "Slack" --limit 15           # dump recent Slack context for LLM sidecar
python3 main.py topics --limit 6 --per-group 3 --since-hours 24  # topic buckets by tag/app (Father/sun)
python3 main.py palette --limit 30 --query "auth"          # interactive picker + copy (Father/sun)
python3 main.py rewrite --id 12 --show                     # run rewrite helper on clip 12 (default latest if omitted)
python3 main.py shorten --show                             # run shorten helper on latest clip
python3 main.py extract --id 42 --timeout 12               # run extract helper with longer timeout
python3 main.py export-md --hours 24 --path /tmp/clips.md  # markdown journal outline by date/app/tags
python3 main.py recall --hours 6 --show                    # run recall helper over last 6h (needs ai_recall_cmd set)
python3 main.py fill --limit 80 --save                     # run fill-gaps helper on recent clips, save output
python3 main.py sync --mode push --target ~/Library/Mobile\\ Documents/com~apple~CloudDocs/mfm.db  # manual sync to iCloud
python3 main.py federate-export --limit 200 --since-hours 24 --path /tmp/mfm-peer.json  # export for another device
python3 main.py federate-import --url http://peer:8765/federate_export  # pull from peer’s serve endpoint
python3 main.py federate-push --url http://peer:8765/federate_import --limit 100  # push to peer
python3 main.py install-launchagent --cap 5000 --interval 1.0  # write LaunchAgent
python3 main.py install-launchagent --remove                   # remove LaunchAgent
python3 main.py serve --port 8765   # start local HTTP API
  # then open http://127.0.0.1:8765/ for a simple search/recent UI
python3 main.py personas           # show role map

# dual-pane tmux (needs tmux installed). Colors + tone:
# Mother|Moon (teal): “ever-watching; capturing clipboard”
# Father|Sun (gold): “awake; ask me for recent/search/export”
./scripts/mfm-dual.sh               # opens/attaches tmux with Mother (left) + Father (right)

# editor-friendly fetch (stdout/clipboard)
./scripts/mfm-fetch.sh --latest --copy
./scripts/mfm-fetch.sh --query "auth token" --semantic --copy
./scripts/mfm-fetch.sh --id 12 --copy
./scripts/mfm-fzf.sh --query "auth" --semantic    # fzf picker
./scripts/mfm-rofi.sh --query "auth"              # rofi picker (needs rofi)
# ingest helpers
python3 main.py ingest-file --path ~/doc.pdf --allow-pdf
python3 main.py ingest-image --path ~/pic.png --allow-images
python3 main.py backup --path ~/mfm-backup.db
python3 main.py restore --path ~/mfm-backup.db

# IDE integration (examples)
# VS Code tasks.json sample task (semantic fetch on selected text, copies to clipboard):
# {
#   "version": "2.0.0",
#   "tasks": [
#     {
#       "label": "mfm semantic fetch",
#       "type": "shell",
#       "command": "${workspaceFolder}/my--father-mother/scripts/mfm-fetch.sh",
#       "args": ["--query", "${selectedText}", "--semantic", "--copy"],
#       "problemMatcher": []
#     }
#   ]
# }
# Bind the task to a keybinding via command "workbench.action.tasks.runTask" args: "mfm semantic fetch".
#
# JetBrains (External Tool):
# Program: /bin/zsh
# Parameters: -lc "/Users/4jp/Workspace/my--father-mother/scripts/mfm-fetch.sh --query \"$SELECTION\" --semantic --copy"
# Working directory: /Users/4jp/Workspace/my--father-mother

# menu launcher (simple curses-less menu)
./scripts/mfm-menu.sh

# LaunchAgents (optional autostart): copy to ~/Library/LaunchAgents and load with launchctl
# - com.my-father-mother.tmux.plist   (dual tmux)
# - com.my-father-mother.menu.plist   (menu launcher)
# - com.my-father-mother.serve.plist  (serve UI/API)
# Optional SwiftBar: place scripts/mfm-swiftbar.1s.sh in your SwiftBar plugins directory (reads /status + latest clip).

Browser bookmarklet
- Run the API/UI: `python3 main.py serve --port 8765` (adjust port if needed).
- Create a bookmark whose URL is:
```
javascript:(()=>{fetch('http://127.0.0.1:8765/ingest_url',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({url:location.href,title:document.title,selection:window.getSelection().toString()})}).catch(()=>{});})();
```
- Clicking it saves the current page title + URL + selection into my--father-mother under app `bookmarklet`.
- Extension dropper: POST JSON `{url,title,selection,html,app}` to `/dropper` from a browser extension/context menu to save richer payloads.
- Chrome MV3 sample extension: see `scripts/extension-dropper/manifest.json` + `worker.js`; load as unpacked to send active tab to `/dropper`.

Semantic + language upgrades (optional)
- Install extras: `python3 -m pip install --upgrade sentence-transformers langdetect`.
- Select the embedder: `python3 main.py config --set embedder e5-small`.
- Existing clips keep their stored vectors (hash by default); new clips use the selected embedder.
- Language codes come from `langdetect`; if missing, `lang` is `unk`.

Progress checklist (v1 scope)
- [x] Polish UI: terminal palette (fzf/rofi), web UI with filters/tags/pin/copy, `/tags` + `/pin` endpoints.
- [x] Semantics: optional local embedder (`e5-small`) with semantic search, per-clip language detection; falls back to hash if deps missing.
- [x] Safety/limits: configurable byte cap, max DB MB with eviction, secret redaction or skip.
- [x] Integrations: IDE fetch helper scripts, tmux/menu helpers, bookmarklet endpoint (`/ingest_url`).
- [x] Presence/notifications: desktop toast on save/skip (configurable), `/status` endpoint + UI indicator.

Roadmap (toggleable by heaviness)
- Light (default on):
  - ✅ Current capture/search stack (done).
  - ✅ Per-tag/app caps and smarter eviction tiers (config flags).
  - ✅ Date-range filters + pin-only view in UI/API.
- Medium (opt-in):
  - ✅ Screenshot/OCR ingest (tesseract) and PDF ingest (pdftotext), toggled via config/flags.
  - ✅ Auto-tag/summary on save (optional hooks).
  - ✅ Topic grouping/threading views (UI “Topics” button + CLI `topics`).
  - ✅ Backup/restore to local archive (manual command; off otherwise).
- Heavy (off by default):
  - ☐ Cloud/sync/remote backup (explicit toggle; require creds).
  - ☐ Full browser extension/menubar mini UI (install separately).
  - ☐ Advanced AI helpers (rewrite/expand/RAG) run-on-demand only.
  - ☐ Multi-device federation (explicit opt-in).

Toggling guidance
- Keep light path on for speed/locality. Turn on Medium/Heavy per need; they should be behind explicit flags/env/config so the base loop stays small and private.
```

Run `python3 main.py --help` for all options.

Notes
- The watcher polls the clipboard every second. It skips empty clips and exact duplicates.
- Frontmost app/window is fetched via `osascript`; if that fails, it falls back to `unknown`.
- If you already use Paste, this runs alongside it; we’re not touching Paste’s data.
- By default, clips matching common secret patterns (AWS keys, GitHub PATs, private keys, Slack tokens) are skipped; use `--allow-secrets` to override. Max clip size defaults to 16KB; adjust via `config --set max_bytes ...`.
- To auto-start the dual tmux session on login, copy `com.my-father-mother.tmux.plist` to `~/Library/LaunchAgents/` and run `launchctl load ~/Library/LaunchAgents/com.my-father-mother.tmux.plist` (tmux required).
# IDE integration (examples)
# VS Code tasks/keybindings samples are in scripts/mfm-vscode-task.json and scripts/mfm-vscode-keybindings.json.
# JetBrains (External Tool):
# Program: /bin/zsh
# Parameters: -lc "/Users/4jp/Workspace/my--father-mother/scripts/mfm-fetch.sh --query \"$SELECTION\" --semantic --copy"
# Working directory: /Users/4jp/Workspace/my--father-mother
