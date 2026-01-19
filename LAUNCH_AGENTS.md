LaunchAgents (autostart)
========================

To auto-start components at login:

- Watcher (clipboard capture): already available as `com.my-father-mother.tmux.plist` (dual tmux) or `scripts/mfm-menu.sh`.
- Watcher (direct): `com.my-father-mother.watch.plist` runs `python3 main.py watch --cap 5000 --interval 1.0`.
- Serve (API/UI): `com.my-father-mother.serve.plist`.
- MCP bridge: `com.my-father-mother.mcp.plist` (runs `scripts/mcp_server.py` on port 39300).

Install any plist:
```bash
cp com.my-father-mother.mcp.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.my-father-mother.mcp.plist
```

Or use the helper to toggle multiple agents at once:
```bash
./scripts/mfm-launchagents.sh --on watch,serve,mcp --off tmux,menu
./scripts/mfm-launchagents.sh --status
```
Unload:
```bash
launchctl unload ~/Library/LaunchAgents/com.my-father-mother.mcp.plist
```

Notes
- `com.my-father-mother.mcp.plist` respects `MFM_MCP_HOST`/`MFM_MCP_PORT` env vars (defaults 127.0.0.1:39300).
- Watcher plist sets a PATH that includes Homebrew; adjust caps/interval if desired.
