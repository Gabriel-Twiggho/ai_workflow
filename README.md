# AI Quadrant Launch

Launch and tile 4 AI assistants into screen quadrants with a single command.

## Quick Start

Press **`Win+R`**, type **`ai`**, press **Enter**.

That's it — 4 AI windows open and snap into quadrants:

| Position | AI | Browser |
|---|---|---|
| Top-left | Claude | Brave |
| Top-right | ChatGPT | Edge |
| Bottom-left | Gemini (AI Studio) | Chrome |
| Bottom-right | Comet (Perplexity) | Comet app |

## Hotkeys

| Hotkey | Action |
|---|---|
| **`Win+Shift+A`** | Retile all 4 windows back to quadrants. Reopens any that were closed. Restores AI tabs if you navigated away. Brings all to front. |

## Tray Icon

The script stays in your system tray (bottom-right). Right-click it for:

- **Retile Windows** — same as `Win+Shift+A`
- **Open All Again** — launches a fresh set of 4 windows
- **Exit** — closes the script (not the browsers)

The tray icon auto-exits when you close all 4 AI browser windows.

## Files

```
C:\Users\gbspi\AIWorkflow\
├── AI-Quadrant-Launch.ahk   ← main script (edit this to change URLs/browsers)
├── ai.bat                   ← launcher (Win+R → ai runs this)
├── register-ai-command.ps1  ← registry setup (already ran, keep for reference)
└── README.md                ← this file
```

## How It Works

1. **`Win+R → ai`** — Windows looks up the registry (`App Paths\ai.exe`) → finds `ai.bat`
2. **`ai.bat`** — runs `AutoHotkey64.exe` with `AI-Quadrant-Launch.ahk`
3. **The script** — opens 4 browsers, tiles them into quadrants, stays resident for the retile hotkey
4. **`#SingleInstance Force`** — prevents duplicate instances; running `ai` again replaces the old one

## Requirements

- [AutoHotkey v2](https://www.autohotkey.com/) (installed at `%LocalAppData%\Programs\AutoHotkey\v2`)
- Brave, Edge, Chrome, and Comet browsers installed

## Customisation

Edit `AI-Quadrant-Launch.ahk` to change:

- **URLs** — lines 13-15 (`urlClaude`, `urlChatGPT`, `urlGemini`)
- **Browser paths** — lines 18-21
- **Retile hotkey** — line 47 (`#+a` = Win+Shift+A)

## Troubleshooting

| Problem | Fix |
|---|---|
| `ai` not recognised in Run | Re-run `register-ai-command.ps1` in PowerShell |
| Windows have gaps | Should be auto-fixed (DWM border compensation). File an issue if not. |
| Wrong window gets tiled | The script matches by exe name (brave, msedge, chrome, comet). Close conflicting windows. |
| Script won't start | Check AutoHotkey v2 is installed and the exe paths in the script are correct. |
