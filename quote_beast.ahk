; quote_beast.ahk — Full version (all popups consistent)
#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)

global scrollState := 0
global scrollDirection := 0
global lButtonPressed := false
global actionDuringLeftHold := false
global lastCopyTime := 0
global lastModeSwitch := 0
global currentModeGui := ""

; ==================== MODE POPUP ====================
setMode(newMode) {
    global lastModeSwitch, currentModeGui
    lastModeSwitch := A_TickCount

    if (currentModeGui != "") {
        try currentModeGui.Destroy()
        currentModeGui := ""
    }

    try {
        FileDelete("last_mode.txt")
        FileAppend(newMode, "last_mode.txt", "UTF-8")
    }

    text := StrUpper(newMode)

    modeGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    modeGui.BackColor := "202020"
    modeGui.MarginX := 14
    modeGui.MarginY := 8
    modeGui.SetFont("s22 bold cFFFFFF", "Segoe UI")

    modeGui.Add("Text", "Center", text)

    xPos := A_ScreenWidth - 200
    yPos := A_ScreenHeight - 105

    modeGui.Show("x" xPos " y" yPos " NoActivate AutoSize")

    currentModeGui := modeGui

    SetTimer(DestroyModeGui, -2000)
}

DestroyModeGui() {
    global currentModeGui
    try currentModeGui.Destroy()
    currentModeGui := ""
}
; ===================================================

; ==================== FEEDBACK POPUP ====================
ShowFeedbackPopup(text) {
    feedbackGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    feedbackGui.BackColor := "202020"
    feedbackGui.MarginX := 14
    feedbackGui.MarginY := 8
    feedbackGui.SetFont("s20 bold cFFFFFF", "Segoe UI")

    feedbackGui.Add("Text", "Center", text)

    xPos := A_ScreenWidth - 280
    yPos := A_ScreenHeight - 105

    feedbackGui.Show("x" xPos " y" yPos " NoActivate AutoSize")

    SetTimer(() => feedbackGui.Destroy(), -1800)
}
; =======================================================

F1:: {
    Suspend()
    ToolTip("Hotkeys " (A_IsSuspended ? "Suspended" : "Resumed"), 0, 0)
    SetTimer(() => ToolTip(), -2000)
}

XButton1 & RButton:: Send("^a")
XButton1 & LButton:: Send("{Enter}")
XButton1 & MButton:: return

XButton1 Up:: {
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P"))
        Send("^``")
}

MButton Up:: Send("^v")
XButton2 & LButton:: Send("^s")

XButton2 Up:: {
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P"))
        Send("#v")
}

modes := ["hot", "flirt", "boost", "stoic"]

getModeIndex(mode) {
    global modes
    Loop modes.Length {
        if (modes[A_Index] = mode)
            return A_Index
    }
    return 1
}

XButton1 & WheelUp:: {
    global lastModeSwitch
    if (A_TickCount - lastModeSwitch < 300)
        return

    current := FileExist("last_mode.txt") ? FileRead("last_mode.txt", "UTF-8") : "hot"
    idx := getModeIndex(current)
    idx := (idx = modes.Length) ? 1 : idx + 1
    setMode(modes[idx])
}

XButton1 & WheelDown:: {
    global lastModeSwitch
    if (A_TickCount - lastModeSwitch < 300)
        return

    current := FileExist("last_mode.txt") ? FileRead("last_mode.txt", "UTF-8") : "hot"
    idx := getModeIndex(current)
    idx := (idx = 1) ? modes.Length : idx - 1
    setMode(modes[idx])
}

; ==================== NORMAL MODE ====================
RButton & WheelUp:: {
    global lastCopyTime
    timeSinceCopy := A_TickCount - lastCopyTime
    useContext := (timeSinceCopy > 0 && timeSinceCopy < 10000)

    mode := FileExist("last_mode.txt") ? FileRead("last_mode.txt", "UTF-8") : "hot"

    if (useContext) {
        cmd := 'python.exe "' A_ScriptDir '\quote_beast.py" --mode ' mode
    } else {
        cmd := 'python.exe "' A_ScriptDir '\quote_beast.py" --mode ' mode ' --blind'
    }

    Sleep(80)
    RunWait cmd, A_ScriptDir, "Hide"

    ShowFeedbackPopup(StrUpper(mode) " Normal")

    lastCopyTime := 0
}

RButton & WheelDown:: {
    global lastCopyTime
    timeSinceCopy := A_TickCount - lastCopyTime
    useContext := (timeSinceCopy > 0 && timeSinceCopy < 10000)

    mode := FileExist("last_mode.txt") ? FileRead("last_mode.txt", "UTF-8") : "hot"

    if (useContext) {
        cmd := 'python.exe "' A_ScriptDir '\quote_beast.py" --mode ' mode
    } else {
        cmd := 'python.exe "' A_ScriptDir '\quote_beast.py" --mode ' mode ' --blind'
    }

    Sleep(80)
    RunWait cmd, A_ScriptDir, "Hide"

    ShowFeedbackPopup(StrUpper(mode) " Normal")

    lastCopyTime := 0
}

; ==================== SHORT MODE ====================
#HotIf GetKeyState("LButton", "P")

WheelUp:: {
    global actionDuringLeftHold
    actionDuringLeftHold := true
    mode := FileExist("last_mode.txt") ? FileRead("last_mode.txt", "UTF-8") : "flirt"
    cmd := 'python.exe "' A_ScriptDir '\quote_beast.py" --mode ' mode ' --short'
    RunWait cmd, A_ScriptDir, "Hide"
    ShowFeedbackPopup(StrUpper(mode) " Short")
}

WheelDown:: {
    global actionDuringLeftHold
    actionDuringLeftHold := true
    mode := FileExist("last_mode.txt") ? FileRead("last_mode.txt", "UTF-8") : "flirt"
    cmd := 'python.exe "' A_ScriptDir '\quote_beast.py" --mode ' mode ' --short'
    RunWait cmd, A_ScriptDir, "Hide"
    ShowFeedbackPopup(StrUpper(mode) " Short")
}

#HotIf

; ==================== COPY ====================
RButton:: {
    global lButtonPressed, lastCopyTime, actionDuringLeftHold

    if (GetKeyState("LButton", "P") && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P")) {
        actionDuringLeftHold := true

        if WinExist("ahk_class #32768") {
            Send("{Esc}")
            Sleep(50)
        }

        Clipboard := ""
        Send("^c")
        if !ClipWait(0.7)
            Sleep(120)

        lastCopyTime := A_TickCount

        ; Big popup on the right (consistent with others)
        ShowFeedbackPopup("📋 Copied")

        KeyWait("RButton")
        return
    }

    KeyWait("RButton")
    Send("{RButton}")
}
; ===============================================

LButton:: {
    global lButtonPressed, actionDuringLeftHold
    lButtonPressed := true
    actionDuringLeftHold := false
    Send("{LButton down}")
}

LButton Up:: {
    global lButtonPressed, actionDuringLeftHold
    lButtonPressed := false
    if (actionDuringLeftHold) {
        actionDuringLeftHold := false
        Send("{LButton up}")
    } else {
        Send("{LButton up}")
    }
}

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
