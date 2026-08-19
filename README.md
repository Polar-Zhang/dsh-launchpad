# dsh-launchpad

**English** | [简体中文](README.zh-CN.md)

A [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) plugin that adds an **elegant splash / loading page** and a **readiness endpoint** to the web UI, plus **Windows desktop launcher scripts** — double-click to start DSH, close the browser tab and DSH stops by itself.

## What you get

| Piece | What it does |
|---|---|
| `GET /launchpad` | The splash page: official DeepSeek whale logo (auto dark/light via `prefers-color-scheme`), 4-stage progress bar (cleanup → boot → ready → enter), waiting timer. |
| `GET /launchpad/status` | JSON readiness probe the splash page polls; redirects into the app the moment the server is up. |
| `scripts/start-dsh.cmd` | Silent Windows launcher: kills port-3080 zombies, starts `dsh web` hidden, opens the splash page in the browser. |
| `scripts/watch-dsh-idle.cmd` | Hidden watcher: when the browser disconnects from port 3080 for ~10 s, it kills dsh. Close the tab → dsh stops. |
| `scripts/hide-run.vbs` | 3-line helper that runs a command with zero visible windows (Windows has no pure-cmd way to fully hide a background process). |
| `scripts/stop-dsh.cmd` | Emergency stop: kills whatever is listening on port 3080. |

## Install

As a plugin (requires DSH CLI):

```bash
dsh plugin --profile web add dsh-launchpad
```

Then deploy the launcher scripts and splash page to `~/.dsh`:

```cmd
:: from the package directory
scripts\install.cmd
```

Or copy `assets/loading.html` + `scripts/*` manually to `%USERPROFILE%\.dsh\`.

Create a desktop shortcut for a true double-click experience:

```cmd
wscript.exe "%USERPROFILE%\.dsh\hide-run.vbs" "cmd /c %USERPROFILE%\.dsh\start-dsh.cmd"
```

(Pick `%USERPROFILE%\.dsh\icons\whale-girl.ico` or any icon you like via the shortcut properties.)

## Usage

1. **Start**: double-click the shortcut (or run `start-dsh.cmd`). No windows appear — the browser opens the splash page instantly, the 4-stage bar fills, and you land in the DSH UI when it's ready.
2. **Stop**: just close the browser tab. ~10 s later dsh exits by itself.
3. **Emergency**: `stop-dsh.cmd`.

### Splash page preview

```cmd
start "" "%USERPROFILE%\.dsh\loading.html?p"
```

`?p` = preview mode (no polling, no redirect). Toggle Windows light/dark mode to see the theme switch.

## Endpoints

```
GET /launchpad           → splash page (text/html)
GET /launchpad/status    → {"ok":true,"service":"dsh","pid":...,"uptime":...,"time":...}
```

## Customize

The splash page is a single self-contained HTML file — edit `assets/loading.html` (logo, colors, stage labels, timeout) and redeploy. Everything is inline: no CDN, works offline.

## Why a plugin + scripts

- The **plugin** part runs inside DSH (Cordis bundle): it hosts the splash page and readiness endpoint through the DSH web server, so the page works over the same origin with zero CORS friction.
- The **scripts** part is inherently OS-level: a process cannot start itself, so starting/stopping dsh needs Windows shell bits. They ship in the same package for a one-stop install.

## License

MIT
