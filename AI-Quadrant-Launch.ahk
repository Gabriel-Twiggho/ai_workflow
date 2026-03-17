#Requires AutoHotkey v2.0
#SingleInstance Force

; ═══════════════════════════════════════════════════════════
;  AI Quadrant Launch — Opens & tiles 4 AI browser windows
;  Retile hotkey: Win+Shift+A
; ═══════════════════════════════════════════════════════════

; ---- DPI Awareness (critical for 200 % scaling) ----
DllCall("Shcore.dll\SetProcessDpiAwareness", "int", 2)

; ---- URLs ----
urlClaude  := "https://claude.ai/new"
urlChatGPT := "https://chatgpt.com/"
urlGemini  := "https://aistudio.google.com/prompts/new_chat?model=gemini-2.5-pro"

; ---- EXE paths ----
braveExe  := "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
edgeExe   := "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
chromeExe := "C:\Program Files\Google\Chrome\Application\chrome.exe"
cometExe  := "C:\Users\gbspi\AppData\Local\Perplexity\Comet\Application\comet.exe"

; ---- Validate executables ----
for name, path in Map("Brave", braveExe, "Edge", edgeExe, "Chrome", chromeExe, "Comet", cometExe) {
    if !FileExist(path) {
        MsgBox("❌  Cannot find " name " at:`n" path "`n`nPlease edit AI-Quadrant-Launch.ahk and fix the path.", "AI Quadrant Launch — Missing EXE", 0x10)
        ExitApp
    }
}

; ---- Global window handles (used by Retile) ----
global Win1 := 0   ; Claude   — Brave     (top-left)
global Win2 := 0   ; ChatGPT  — Edge      (top-right)
global Win3 := 0   ; Gemini   — Chrome    (bottom-left)
global Win4 := 0   ; Comet                (bottom-right)

; ---- Tray menu ----
A_TrayMenu.Delete()                       ; remove default items
A_TrayMenu.Add("🔲  Retile Windows (Win+Shift+A)", (*) => RetileWindows())
A_TrayMenu.Add("🚀  Open All Again (Win+R -> ai)", (*) => LaunchAll())
A_TrayMenu.Add()                          ; separator
A_TrayMenu.Add("❌  Exit", (*) => ExitApp())
A_TrayMenu.Default := "🔲  Retile Windows (Win+Shift+A)"
A_IconTip := "AI Quadrant Launch`nRetile: Win+Shift+A`nOpen All: Win+R ➔ ai"
TraySetIcon("Shell32.dll", 16)            ; nice grid icon

; ---- Hotkey: Win+Shift+A → Retile ----
#+a::RetileWindows()

; ---- Launch on start ----
LaunchAll()

; ---- Auto-exit when all AI windows are closed ----
SetTimer(CheckAllClosed, 2000)
return   ; keep script resident (hotkey + tray)

CheckAllClosed() {
    global Win1, Win2, Win3, Win4
    ; If none of the 4 windows exist any more, clean up and exit
    if !IsWindowValid(Win1) && !IsWindowValid(Win2) && !IsWindowValid(Win3) && !IsWindowValid(Win4)
        ExitApp
}


; ═══════════════════════════════════════════════════════════
;  Core functions
; ═══════════════════════════════════════════════════════════

LaunchAll() {
    global Win1, Win2, Win3, Win4

    ; -- Work area (screen minus taskbar) --
    MonitorGetWorkArea(1, &waLeft, &waTop, &waRight, &waBottom)
    waW := waRight - waLeft
    waH := waBottom - waTop
    halfW := Floor(waW / 2)
    halfH := Floor(waH / 2)

    ; -- Top-left: Claude in Brave --
    Run('"' braveExe '" --new-window "' urlClaude '"')
    Win1 := WaitForNewWindow("ahk_exe brave.exe")

    Sleep 500

    ; -- Top-right: ChatGPT in Edge --
    Run('"' edgeExe '" --new-window "' urlChatGPT '"')
    Win2 := WaitForNewWindow("ahk_exe msedge.exe")

    Sleep 500

    ; -- Bottom-left: Gemini in Chrome --
    Run('"' chromeExe '" --new-window "' urlGemini '"')
    Win3 := WaitForNewWindow("ahk_exe chrome.exe")

    Sleep 500

    ; -- Bottom-right: Comet --
    Run('"' cometExe '"')
    Win4 := WaitForNewWindow("ahk_exe comet.exe")

    ; -- Position them (x, y, w, h) --
    PositionWindow(Win1, waLeft,         waTop,          halfW, halfH)
    PositionWindow(Win2, waLeft + halfW, waTop,          halfW, halfH)
    PositionWindow(Win3, waLeft,         waTop + halfH,  halfW, halfH)
    PositionWindow(Win4, waLeft + halfW, waTop + halfH,  halfW, halfH)

    ; Focus Claude last so it's on top
    try WinActivate(Win1)
}


RetileWindows() {
    global Win1, Win2, Win3, Win4

    MonitorGetWorkArea(1, &waLeft, &waTop, &waRight, &waBottom)
    waW := waRight - waLeft
    waH := waBottom - waTop
    halfW := Floor(waW / 2)
    halfH := Floor(waH / 2)

    ; Try to find existing windows first, then relaunch any that are missing
    if !IsWindowValid(Win1)
        Win1 := FindBrowserWindow("ahk_exe brave.exe", "Claude")
    if !IsWindowValid(Win1) {
        Run('"' braveExe '" --new-window "' urlClaude '"')
        Win1 := WaitForNewWindow("ahk_exe brave.exe")
        Sleep 300
    }

    if !IsWindowValid(Win2)
        Win2 := FindBrowserWindow("ahk_exe msedge.exe")    ; ChatGPT title changes, so just find Edge
    if !IsWindowValid(Win2) {
        Run('"' edgeExe '" --new-window "' urlChatGPT '"')
        Win2 := WaitForNewWindow("ahk_exe msedge.exe")
        Sleep 300
    }

    if !IsWindowValid(Win3)
        Win3 := FindBrowserWindow("ahk_exe chrome.exe", "Gemini")
    if !IsWindowValid(Win3) {
        Run('"' chromeExe '" --new-window "' urlGemini '"')
        Win3 := WaitForNewWindow("ahk_exe chrome.exe")
        Sleep 300
    }

    if !IsWindowValid(Win4)
        Win4 := FindBrowserWindow("ahk_exe comet.exe")
    if !IsWindowValid(Win4) {
        Run('"' cometExe '"')
        Win4 := WaitForNewWindow("ahk_exe comet.exe")
        Sleep 300
    }

    ; If a browser tab navigated away from the AI site, open the correct URL as a new tab
    ; The second parameter is a RegEx pattern to match any page on their site
    RestoreTabIfNeeded(Win1, "Claude",                      braveExe,  urlClaude)
    RestoreTabIfNeeded(Win2, "ChatGPT|OpenAI",              edgeExe,   urlChatGPT)
    RestoreTabIfNeeded(Win3, "Gemini|AI Studio|Google AI",  chromeExe, urlGemini)
    ; Comet is its own app, no tab recovery needed

    ; Position all windows
    PositionWindow(Win1, waLeft,         waTop,          halfW, halfH)
    PositionWindow(Win2, waLeft + halfW, waTop,          halfW, halfH)
    PositionWindow(Win3, waLeft,         waTop + halfH,  halfW, halfH)
    PositionWindow(Win4, waLeft + halfW, waTop + halfH,  halfW, halfH)

    ; Bring all 4 to front (activate in reverse so Claude ends up on top)
    for hwnd in [Win4, Win3, Win2, Win1] {
        if IsWindowValid(hwnd)
            try WinActivate(hwnd)
    }
}


; ═══════════════════════════════════════════════════════════
;  Helpers
; ═══════════════════════════════════════════════════════════

PositionWindow(hwnd, x, y, w, h) {
    if !hwnd
        return
    try {
        ; Restore if minimised or maximised so WinMove works
        WinRestore(hwnd)
        Sleep 50

        ; Compensate for Win11 invisible borders so windows tile seamlessly
        border := GetInvisibleBorder(hwnd)
        adjX := x - border.left
        adjY := y - border.top
        adjW := w + border.left + border.right
        adjH := h + border.top + border.bottom

        WinMove(adjX, adjY, adjW, adjH, hwnd)
    }
}

WaitForNewWindow(criteria, timeoutMs := 12000) {
    ; Snapshot existing windows
    existing := Map()
    try {
        for id in WinGetList(criteria)
            existing[id] := true
    }
    start := A_TickCount
    while (A_TickCount - start < timeoutMs) {
        try {
            for id in WinGetList(criteria) {
                if !existing.Has(id)
                    return id
            }
        }
        Sleep 150
    }
    ; Fallback: return most recent match
    try {
        hwnd := WinExist(criteria)
        if hwnd
            return hwnd
    }
    return 0
}

FindBrowserWindow(criteria, titleFragment := "") {
    try {
        for hwnd in WinGetList(criteria) {
            if (titleFragment = "")
                return hwnd
            title := WinGetTitle(hwnd)
            if InStr(title, titleFragment)
                return hwnd
        }
    }
    return 0
}

IsWindowValid(hwnd) {
    if !hwnd
        return false
    try return WinExist("ahk_id " hwnd) != 0
    return false
}

RestoreTabIfNeeded(hwnd, matchPattern, browserExe, urlToOpen) {
    if !IsWindowValid(hwnd)
        return
    try {
        ; Activate the window so we can send keys and read the active tab title
        WinActivate(hwnd)
        WinWaitActive(hwnd, , 1)

        startTitle := WinGetTitle(hwnd)
        ; Placed perfectly: if the current tab is already the AI, do nothing
        if RegExMatch(startTitle, "i)" matchPattern)
            return
            
        ; Fallback URL check if title doesn't match (e.g. ChatGPT drops name in chats)
        currentUrl := GetActiveURL()
        if InStr(currentUrl, "chatgpt.com") || InStr(currentUrl, "claude.ai") || InStr(currentUrl, "aistudio.google")
            return

        ; The AI tab might be in the background. Cycle through tabs quickly to find it.
        Loop 15 {
            prevTitle := WinGetTitle(hwnd)
            Send("^{Tab}")
            
            ; Wait up to 150ms for the browser to switch tabs and change the OS window title
            Loop 10 {
                Sleep 15
                currentTitle := WinGetTitle(hwnd)
                if (currentTitle != prevTitle)
                    break
            }

            ; Found it by title:
            if RegExMatch(currentTitle, "i)" matchPattern)
                return
                
            ; Found it by URL:
            currentUrl := GetActiveURL()
            if InStr(currentUrl, "chatgpt.com") || InStr(currentUrl, "claude.ai") || InStr(currentUrl, "aistudio.google")
                return

            ; If we've looped all the way back to the tab we started on, give up.
            if (currentTitle = startTitle)
                break
                
            ; If title hasn't changed at all, there's probably only 1 tab in the window.
            if (currentTitle = prevTitle)
                break
        }

        ; If we get here, the AI tab is truly gone. Open a new one.
        Run('"' browserExe '" "' urlToOpen '"')
        Sleep 500
    }
}

GetActiveURL() {
    savedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^{l}")
    Sleep(50)
    Send("^{c}")
    if ClipWait(0.3) {
        url := A_Clipboard
    } else {
        url := ""
    }
    Send("{Esc}")
    A_Clipboard := savedClip
    return url
}

GetInvisibleBorder(hwnd) {
    ; Use DwmGetWindowAttribute (DWMWA_EXTENDED_FRAME_BOUNDS = 9)
    ; to find the difference between the window rect and the visible rect.
    ; This difference is the invisible border Win11 adds around every window.
    result := {left: 0, top: 0, right: 0, bottom: 0}
    try {
        WinGetPos(&wx, &wy, &ww, &wh, hwnd)
        ; RECT struct: 4 x int32 = 16 bytes
        frameBuf := Buffer(16, 0)
        hr := DllCall("Dwmapi.dll\DwmGetWindowAttribute"
            , "Ptr", hwnd
            , "UInt", 9          ; DWMWA_EXTENDED_FRAME_BOUNDS
            , "Ptr", frameBuf
            , "UInt", 16
            , "Int")
        if (hr = 0) {
            fl := NumGet(frameBuf,  0, "Int")  ; visible left
            ft := NumGet(frameBuf,  4, "Int")  ; visible top
            fr := NumGet(frameBuf,  8, "Int")  ; visible right
            fb := NumGet(frameBuf, 12, "Int")  ; visible bottom
            result.left   := fl - wx
            result.top    := ft - wy
            result.right  := (wx + ww) - fr
            result.bottom := (wy + wh) - fb
        }
    }
    return result
}