#!/bin/zsh
# SwiftBar / BitBar plugin for my--father-mother
# Shows status, pause/resume, recent clips with copy/pin actions.
# Set MFM_HOST to override host:port (default 127.0.0.1:8765).
# Set MFM_REPO_DIR to point at the repo if HTTP is unavailable.
# Set MFM_FORCE_CLI=1 to skip HTTP and use CLI calls directly.

python3 - "$@" <<'PY'
import json, os, sys, subprocess, textwrap, urllib.request, urllib.error

HOST = os.environ.get("MFM_HOST", "127.0.0.1:8765")
BASE = f"http://{HOST}"
REPO_DIR = os.environ.get("MFM_REPO_DIR", "/Users/4jp/Workspace/my--father-mother")
MAIN = os.path.join(REPO_DIR, "main.py")
FORCE_CLI = os.environ.get("MFM_FORCE_CLI", "").lower() in ("1", "true", "yes", "on")

def fetch_json(path: str):
    try:
        with urllib.request.urlopen(BASE + path, timeout=2.5) as resp:
            return json.load(resp)
    except Exception:
        return None

def post_json(path: str, payload: dict):
    try:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(BASE + path, data=data, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=2.5) as resp:
            return resp.read()
    except Exception:
        return None

def pbcopy(text: str):
    try:
        p = subprocess.Popen(["pbcopy"], stdin=subprocess.PIPE)
        p.communicate(text.encode("utf-8"))
    except Exception:
        pass

def cli_json(args):
    try:
        out = subprocess.check_output(["python3", MAIN] + args, text=True)
        return json.loads(out)
    except Exception:
        return None

status = None
use_http = False
if not FORCE_CLI:
    status = fetch_json("/status")
    if status is not None:
        use_http = True
if status is None:
    status = cli_json(["status", "--json"]) or {}

paused = bool(status.get("paused"))
count = status.get("count", 0)
db_mb = status.get("db_size_mb", 0)
max_db_mb = status.get("max_db_mb", 0)
cap_hint = f"{db_mb:.1f}MB" + (f"/{max_db_mb}MB" if max_db_mb else "")
if paused:
    print(f"MFM ⏸ {count} | color=#ffd479")
else:
    warn = ""
    if max_db_mb and db_mb / max_db_mb >= 0.8:
        warn = " ⚠"
    print(f"MFM ☀ {count}{warn} | color=#9bffb5")

print("---")
print(f"Active: {not paused}  Clips: {count}  DB: {cap_hint}")
print(f"Notify: {status.get('notify')}  Secrets: {status.get('allow_secrets')}")
print(f"Embedder: {status.get('embedder')}  Sync: {status.get('sync_target') or 'off'}")
latest = status.get("latest") or "n/a"
print(f"Latest: {latest}")
if use_http:
    print(f"Open UI | href={BASE}/")
    print(f"Toggle Pause | bash='/usr/bin/env' param1=python3 param2=-c param3='import urllib.request, json; import sys; host=\"{BASE}\"; path=\"/pause\" if {str(not paused).lower()} else \"/resume\"; urllib.request.urlopen(host+path, data=b\"{}\")' terminal=false refresh=true")
else:
    pause_flag = "--on" if not paused else "--off"
    print("HTTP unavailable; using CLI | color=#ffd479")
    print(f"Toggle Pause | bash='/usr/bin/env' param1=python3 param2={MAIN} param3=pause param4={pause_flag} terminal=false refresh=true")
print("Reload | refresh=true")

recent = fetch_json("/recent?limit=5") if use_http else None
if recent is None:
    recent = cli_json(["recent", "--limit", "5", "--json"]) or {}
items = recent.get("items", [])
if items:
    print("---")
    print("Recent | color=#8ab4ff")
    for it in items:
        title = it.get("title") or it.get("window_title") or ""
        app = it.get("source_app") or "unknown"
        pid = it.get("id")
        pin_mark = "🔖" if it.get("pinned") else " "
        summary = textwrap.shorten((it.get("content") or "").strip().replace("\n", " "), width=80, placeholder="…")
        print(f"{pin_mark} #{pid} [{app}] {title} | length=80")
        if summary:
            print(f"--{summary}")
        if use_http:
            print(f"--Copy clip #{pid} | bash='/usr/bin/env' param1=python3 param2=-c param3='import urllib.request,json,subprocess;import sys;host=\"{BASE}\";cid={pid};data=json.load(urllib.request.urlopen(f\"{BASE}/clip?id={pid}\"));p=subprocess.Popen([\"pbcopy\"],stdin=subprocess.PIPE);p.communicate(data.get(\"content\",\"\" ).encode(\"utf-8\"))' terminal=false refresh=false")
            toggle_target = "true" if not it.get("pinned") else "false"
            print(f\"--Toggle pin #{pid} | bash='/usr/bin/env' param1=python3 param2=-c param3='import urllib.request,json;import sys;payload=json.dumps({{\"id\":{pid},\"pinned\":{toggle_target}}}).encode();req=urllib.request.Request(\"{BASE}/pin\",data=payload,headers={{\"Content-Type\":\"application/json\"}});urllib.request.urlopen(req)' terminal=false refresh=true")
        else:
            toggle_flag = "--on" if not it.get("pinned") else "--off"
            print(f"--Copy clip #{pid} | bash='/usr/bin/env' param1=python3 param2={MAIN} param3=copy param4=--id param5={pid} terminal=false refresh=false")
            print(f"--Toggle pin #{pid} | bash='/usr/bin/env' param1=python3 param2={MAIN} param3=pin param4=--id param5={pid} param6={toggle_flag} terminal=false refresh=true")
else:
    print("---")
    print("No recent clips found.")

PY
