# VidMate Desktop

One `.exe` installer that bundles everything: the app, yt-dlp, and ffmpeg.
Users install and run — no manual dependency setup needed.

---

## For users: Install & run

1. Run `VidMate Desktop Setup 1.0.0.exe`
2. Follow the installer (choose folder, create shortcuts)
3. Done — open VidMate Desktop and start downloading

---

## For developers: Build the .exe

### Prerequisites
- Node.js 18+  →  https://nodejs.org
- Windows (to produce a .exe; use Mac/Linux for those targets)

### Steps

```bash
# 1. Install Node dependencies
npm install

# 2. Build the Windows installer
#    This automatically downloads yt-dlp.exe + ffmpeg.exe into bin/win/
#    then packages everything into dist/VidMate Desktop Setup 1.0.0.exe
npm run build:win

# macOS (.dmg)
npm run build:mac

# Linux (AppImage)
npm run build:linux
```

The built installer is in `dist/`.

---

## What gets bundled inside the .exe

| Component | Source | Purpose |
|-----------|--------|---------|
| Electron (Chromium + Node) | npm | The app runtime + embedded browser |
| yt-dlp.exe | GitHub releases (auto-downloaded) | Format detection + downloading |
| ffmpeg.exe | BtbN static build (auto-downloaded) | Merging video + audio streams |
| App code | src/ | UI, media detection, download manager |

The `scripts/download-binaries.js` script fetches yt-dlp and ffmpeg
automatically before the build — you never need to install them manually.

---

## Architecture

```
main.js                     ← Electron main process
  ├─ setup.js               ← Verifies bundled binaries on first run
  ├─ session.webRequest     ← System 2: intercepts media URLs from WebView
  ├─ ipcMain (getFormats)   ← System 4: spawns yt-dlp --dump-json
  └─ ipcMain (start/pause)  ← System 3: spawns yt-dlp download subprocess

preload.js                  ← Secure IPC bridge (contextBridge)

renderer/
  ├─ index.html             ← App shell + <webview> tag (System 1)
  ├─ style.css              ← Dark UI theme
  └─ renderer.js            ← All UI: tabs, media list, format modal, downloads

bin/
  ├─ win/  yt-dlp.exe  ffmpeg.exe    ← auto-downloaded before build
  ├─ mac/  yt-dlp      ffmpeg
  └─ linux/ yt-dlp     ffmpeg
```
