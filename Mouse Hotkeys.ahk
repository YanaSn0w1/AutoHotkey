#SingleInstance Force
SetWorkingDir(A_ScriptDir)

; Globals
global scrollState := 0 ; 0 = stopped, 1 = scrolling
global scrollDirection := 0 ; 0 = none, 1 = down, -1 = up
global lButtonPressed := false ; Track Left Click state
global copyPerformed := false
global rWheelUsed := false

; Toggle Suspend (F1)
F1:: {
    Suspend()
    ToolTip("Hotkeys " (A_IsSuspended ? "Suspended" : "Resumed"), 0, 0)
    SetTimer(() => ToolTip(), -2000)
}

; XButton1 + RButton = Select All (Ctrl+A)
XButton1 & RButton:: {
    Send("{Ctrl down}a{Ctrl up}")
}

; XButton1 + LButton = Enter
XButton1 & LButton:: Send("{Enter}")

; XButton1 + MButton (Wheel Click) = Do nothing
XButton1 & MButton:: return

; XButton1 solo release = Ctrl + `
XButton1 Up:: {
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P"))
        Send("{Ctrl down}{``}{Ctrl up}")
}

; ==================== MIDDLE MOUSE = PLAIN TEXT + NO EXTRA LINE ====================
MButton Up::
{
    ClipSaved := ClipboardAll()           ; backup full clipboard
    text := Trim(A_Clipboard, " `t`r`n")  ; force plain text + remove trailing blank lines
    A_Clipboard := text
    Send("{Ctrl down}v{Ctrl up}")
    Sleep(60)
    A_Clipboard := ClipSaved              ; restore original
}

; ==================== OPTIONAL Ctrl+V plain text (uncomment if you want) ====================
;^v:: {
;    ClipSaved := ClipboardAll()
;    text := Trim(A_Clipboard, " `t`r`n")
;    A_Clipboard := text
;    Send("{Ctrl down}v{Ctrl up}")
;    Sleep(60)
;    A_Clipboard := ClipSaved
;}

; XButton2 + LButton = Save (Ctrl+S)
XButton2 & LButton:: Send("{Ctrl down}s{Ctrl up}")

; XButton2 + RButton = Do nothing
XButton2 & RButton:: return

; XButton2 solo release = Windows Clipboard (Win+V)
XButton2 Up:: {
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P"))
        Send("#{v}")
}

; RButton + WheelDown = Send 'j'
RButton & WheelDown:: {
    global rWheelUsed
    rWheelUsed := true
    if (A_TimeSincePriorHotkey > 200 || A_PriorHotkey != "RButton & WheelDown") {
        Send("j")
    }
}

; RButton + WheelUp = Ctrl + Enter
RButton & WheelUp:: {
    global rWheelUsed
    rWheelUsed := true
    if (A_TimeSincePriorHotkey > 200 || A_PriorHotkey != "RButton & WheelUp") {
        Send("{Ctrl down}{Enter}{Ctrl up}")
    }
}

; Handle RButton
RButton:: {
    global lButtonPressed, copyPerformed, rWheelUsed
    if (lButtonPressed && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P")) {
        if WinExist("ahk_class #32768") {
            Send("{Esc}")
            Sleep(50)
        }
        Send("{Ctrl down}c{Ctrl up}")
        copyPerformed := true
        KeyWait("RButton")
        copyPerformed := false
        return
    }
    rWheelUsed := false
    KeyWait("RButton")
    if (rWheelUsed) {
        return
    }
    Send("{RButton}")
}

; Track LButton state
LButton:: {
    global lButtonPressed
    lButtonPressed := true
    Send("{LButton down}")
}

LButton Up:: {
    global lButtonPressed
    lButtonPressed := false
    Send("{LButton up}")
}

; Alt + PgDn / PgUp auto-scroll
!PgDn:: {
    global scrollState, scrollDirection
    if (scrollState = 0) {
        scrollState := 1
        scrollDirection := 1
        SetTimer(ScrollDown, 1)
    } else {
        scrollState := 0
        scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
    }
}

!PgUp:: {
    global scrollState, scrollDirection
    if (scrollState = 0) {
        scrollState := 1
        scrollDirection := -1
        SetTimer(ScrollUp, 1)
    } else {
        scrollState := 0
        scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
    }
}

; PgDn / PgUp cancel scroll
PgDn:: {
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0
        scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
        ToolTip("Scroll canceled", 0, 20)
        SetTimer(() => ToolTip(), -2000)
    } else {
        Send("{PgDn}")
    }
}

PgUp:: {
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0
        scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
        ToolTip("Scroll canceled", 0, 20)
        SetTimer(() => ToolTip(), -2000)
    } else {
        Send("{PgUp}")
    }
}

; Scroll functions
ScrollDown() {
    global scrollDirection
    if (scrollDirection = 1)
        Send("{WheelDown}")
}

ScrollUp() {
    global scrollDirection
    if (scrollDirection = -1)
        Send("{WheelUp}")
}
