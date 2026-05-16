; quote_beast.ahk   ← Fixed global variable error + 10-second clipboard
SetWorkingDir(A_ScriptDir)

; All globals declared at top level
global scrollState := 0
global scrollDirection := 0
global lButtonPressed := false
global rWheelUsed := false
global lastCopyTime := 0

; Toggle Suspend (F1)
F1:: {
    Suspend()
    ToolTip("Hotkeys " (A_IsSuspended ? "Suspended" : "Resumed"), 0, 0)
    SetTimer(() => ToolTip(), -2000)
}

; Other hotkeys
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

RButton & WheelDown:: Send("j")

; ==================== RIGHT CLICK + SCROLL UP = GENERATE QUOTE ====================
RButton & WheelUp:: {
    global lastCopyTime
    
    currentTime := A_TickCount
    timeSinceCopy := currentTime - lastCopyTime
    
    if (timeSinceCopy < 10000) {
        RunWait 'python.exe "' A_ScriptDir '\quote_beast.py" --last', , "Hide"
    } else {
        RunWait 'python.exe "' A_ScriptDir '\quote_beast.py" --last --blind', , "Hide"
    }
    
    lastCopyTime := 0   ; reset after use
    
    ToolTip("✅ Quote copied", 20, A_ScreenHeight - 40)
    SetTimer(() => ToolTip(), -900)
}

; ==================== LEFT CLICK + RIGHT CLICK = COPY ====================
RButton:: {
    global lButtonPressed, rWheelUsed, lastCopyTime

    if (lButtonPressed && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P")) {
        if WinExist("ahk_class #32768") {
            Send("{Esc}")
            Sleep(50)
        }
        Send("^c")
        lastCopyTime := A_TickCount
        ToolTip("📋 Copied", 20, A_ScreenHeight - 60)
        SetTimer(() => ToolTip(), -600)
        
        KeyWait("RButton")
        return
    }
    
    rWheelUsed := false
    KeyWait("RButton")
    if (rWheelUsed)
        return
    Send("{RButton}")
}

; Track Left Button
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
