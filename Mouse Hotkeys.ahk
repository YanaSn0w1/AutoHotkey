#SingleInstance Force
SetWorkingDir A_ScriptDir

; Globals
global scrollState := 0 ; 0 = stopped, 1 = scrolling
global scrollDirection := 0 ; 0 = none, 1 = down, -1 = up
global lButtonPressed := false ; Track Left Click state

; Toggle Suspend (F1)
F1:: {
    Suspend
    ToolTip "Hotkeys " (A_IsSuspended ? "Suspended" : "Resumed"), 0, 0
    SetTimer () => ToolTip(), -2000
}

; XButton1 + RButton = Select All (Ctrl+A), blocks default context menu
XButton1 & RButton:: {
    Send "{Ctrl down}a{Ctrl up}"
}

; XButton1 + LButton = Enter
XButton1 & LButton:: Send "{Enter}"

; XButton1 + WheelDown = Send 'j' (for next post on X/Twitter)
XButton1 & WheelDown:: Send "j"

; XButton1 + WheelUp = Ctrl + Enter (new per request)
XButton1 & WheelUp:: Send "{Ctrl down}{Enter}{Ctrl up}"

; XButton1 + MButton (Wheel Click) = Do nothing (updated per request)
XButton1 & MButton:: return

; XButton1 solo release = Ctrl + `
XButton1 Up:: {
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P"))
        Send "{Ctrl down}{``}{Ctrl up}"
}

; MButton solo release = Paste (Ctrl+V)
MButton Up:: Send "{Ctrl down}v{Ctrl up}"

; XButton2 + LButton = Save (Ctrl+S)
XButton2 & LButton:: Send "{Ctrl down}s{Ctrl up}"

; XButton2 + RButton = Do nothing
XButton2 & RButton:: return

; XButton2 solo release = Windows Clipboard (Win+V)
XButton2 Up:: {
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P"))
        Send "#{v}"
}

; LButton held + RButton = Copy (Ctrl+C)
RButton:: {
    global lButtonPressed
    if (lButtonPressed && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P")) {
        if WinExist("ahk_class #32768") {
            Send "{Esc}"
            Sleep 50
        }
        Send "{Ctrl down}c{Ctrl up}"
        KeyWait "RButton"
        return
    }
    Send "{RButton down}"
    KeyWait "RButton"
    Send "{RButton up}"
}

; Track LButton state
LButton:: {
    global lButtonPressed
    lButtonPressed := true
    Send "{LButton down}"
}

LButton Up:: {
    global lButtonPressed
    lButtonPressed := false
    Send "{LButton up}"
}

; Alt + PgDn = Toggle auto-scroll down
!PgDn:: {
    global scrollState, scrollDirection
    ; ToolTip "Alt + PgDn pressed, State: " scrollState, 0, 0  ; Uncomment for debug
    ; SetTimer () => ToolTip(), -2000
    if (scrollState = 0) {
        scrollState := 1
        scrollDirection := 1
        SetTimer ScrollDown, 1  ; 1ms as per notes
    } else {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
    }
}

; Alt + PgUp = Toggle auto-scroll up
!PgUp:: {
    global scrollState, scrollDirection
    ; ToolTip "Alt + PgUp pressed, State: " scrollState, 0, 0  ; Uncomment for debug
    ; SetTimer () => ToolTip(), -2000
    if (scrollState = 0) {
        scrollState := 1
        scrollDirection := -1
        SetTimer ScrollUp, 1  ; 1ms as per notes
    } else {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
    }
}

; PgDn = Cancel scroll if active, else normal
PgDn:: {
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
        ToolTip "Scroll canceled", 0, 20
        SetTimer () => ToolTip(), -2000
    } else {
        Send "{PgDn}"
    }
}

; PgUp = Cancel scroll if active, else normal
PgUp:: {
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
        ToolTip "Scroll canceled", 0, 20
        SetTimer () => ToolTip(), -2000
    } else {
        Send "{PgUp}"
    }
}

; Scroll functions
ScrollDown() {
    global scrollDirection
    if (scrollDirection = 1)
        Send "{WheelDown}"
}

ScrollUp() {
    global scrollDirection
    if (scrollDirection = -1)
        Send "{WheelUp}"
}
