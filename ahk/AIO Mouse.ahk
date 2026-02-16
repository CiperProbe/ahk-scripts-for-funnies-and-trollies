#NoEnv
#SingleInstance Force
#Persistent
SendMode Input  ; Fastest input mode
SetBatchLines -1  ; Fastest batch processing
SetWinDelay -1
SetKeyDelay -1, -1
SetMouseDelay -1
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen
#InstallKeybdHook
#InstallMouseHook
#UseHook On
#MaxThreads 10
#MaxThreadsPerHotkey 2
DetectHiddenWindows, On
SetTitleMatchMode, 2

; High-precision timing
DllCall("QueryPerformanceFrequency", "Int64", freq)
if (!freq) {
    freq := 1000
}
tickInterval := 1000000 // freq

global CPS := 8
global SpeedIncrement := 4
global SpeedDecrement := 2
global LeftClickActive := true
global RightClickActive := false
global MiddleClickActive := false
global AutoclickerActive := false
global MaximumMode := false
global MouseHoldActive := false
global TooltipActive := false
global TooltipX := 0
global TooltipY := 0
global ClickInterval := 1000 // 8
global BaseInterval := 1000 // 8
global Variation := 0.10
global LastClickTime := 0
global ClickCount := 0
global MissedClicks := 0
global IsClicking := false
global MaxModeRunning := false

SetTimer, UpdateTooltip, 100
SetTimer, HideTooltip, 2000

^F1::ToggleMaximumMode()
*F1::ToggleAutoclicker()
*F2::IncreaseSpeed()
*F3::DecreaseSpeed()
*F4::ResetToDefault()
*F5::ToggleLeftClick()
*F6::ToggleRightClick()
*F7::ToggleMiddleClick()
*Esc::ExitApp

*^F2::ToggleMouseHold()

~!Tab::
    Return

~LAlt Up::
~RAlt Up::
    Return

ToggleAutoclicker() {
    global AutoclickerActive, TooltipActive, TooltipX, TooltipY, BaseInterval, IsClicking, MaximumMode, MaxModeRunning, CPS
    
    AutoclickerActive := !AutoclickerActive
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
    IsClicking := false
    
    if (AutoclickerActive) {
        if (MaximumMode) {
            MaxModeRunning := true
            SetTimer, MaxModeLoop, 1
        } else {
            BaseInterval := 1000 // CPS
            SetTimer, ClickLoop, 10
        }
    } else {
        if (MaximumMode) {
            MaxModeRunning := false
            SetTimer, MaxModeLoop, Off
        } else {
            SetTimer, ClickLoop, Off
        }
    }
}

IncreaseSpeed() {
    global CPS, SpeedIncrement, TooltipActive, TooltipX, TooltipY, AutoclickerActive, ClickInterval, BaseInterval, MaximumMode, MaxModeRunning
    if (!MaximumMode) {
        CPS += SpeedIncrement
        if (CPS > 20)
            CPS := 20
        BaseInterval := 1000 // CPS
        if (AutoclickerActive && !MaxModeRunning) {
            SetTimer, ClickLoop, Off
            SetTimer, ClickLoop, 10
        }
    }
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
}

DecreaseSpeed() {
    global CPS, SpeedDecrement, TooltipActive, TooltipX, TooltipY, AutoclickerActive, BaseInterval, MaximumMode, MaxModeRunning
    if (!MaximumMode) {
        CPS -= SpeedDecrement
        if (CPS < 1)
            CPS := 1
        BaseInterval := 1000 // CPS
        if (AutoclickerActive && !MaxModeRunning) {
            SetTimer, ClickLoop, Off
            SetTimer, ClickLoop, 10
        }
    }
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
}

ResetToDefault() {
    global CPS, TooltipActive, TooltipX, TooltipY, AutoclickerActive, BaseInterval, IsClicking, MaximumMode, MaxModeRunning
    if (!MaximumMode) {
        CPS := 8
        BaseInterval := 1000 // CPS
        if (AutoclickerActive && !MaxModeRunning) {
            SetTimer, ClickLoop, Off
            SetTimer, ClickLoop, 10
        }
    }
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
    IsClicking := false
}

ToggleLeftClick() {
    global LeftClickActive, TooltipActive, TooltipX, TooltipY
    LeftClickActive := !LeftClickActive
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
}

ToggleRightClick() {
    global RightClickActive, TooltipActive, TooltipX, TooltipY
    RightClickActive := !RightClickActive
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
}

ToggleMiddleClick() {
    global MiddleClickActive, TooltipActive, TooltipX, TooltipY
    MiddleClickActive := !MiddleClickActive
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
}

MaxModeLoop:
    global MaxModeRunning, LeftClickActive, RightClickActive, MiddleClickActive
    
    if (!MaxModeRunning) {
        return
    }
    
    if (LeftClickActive) {
        MouseClick, Left
    }
    if (RightClickActive) {
        MouseClick, Right
    }
    if (MiddleClickActive) {
        MouseClick, Middle
    }
return

ClickLoop:
    global AutoclickerActive, LeftClickActive, RightClickActive, MiddleClickActive, BaseInterval, Variation, LastClickTime, ClickCount, MissedClicks, IsClicking, MaximumMode, MaxModeRunning
    
    if (MaxModeRunning) {
        return
    }
    
    if (!AutoclickerActive) {
        IsClicking := false
        return
    }
    
    if (IsClicking)
        return
    
    CurrentTime := A_TickCount
    TimeSinceLastClick := CurrentTime - LastClickTime
    
    Random, RandomFactor, 0.90, 1.10
    CurrentInterval := BaseInterval * RandomFactor
    
    if (TimeSinceLastClick >= CurrentInterval) {
        IsClicking := true
        
        try {
            if (LeftClickActive) {
                Click, Left
                ClickCount++
            }
            if (RightClickActive) {
                Click, Right
                ClickCount++
            }
            if (MiddleClickActive) {
                Click, Middle
                ClickCount++
            }
        } catch e {
            IsClicking := false
            return
        }
        
        LastClickTime := A_TickCount
        IsClicking := false
    }
return

UpdateTooltip() {
    global AutoclickerActive, CPS, LeftClickActive, RightClickActive, MiddleClickActive, TooltipActive, TooltipX, TooltipY, MaximumMode, MouseHoldActive
    
    if (!TooltipActive)
        return
        
    Status := AutoclickerActive ? "ON" : "OFF"
    LStatus := LeftClickActive ? "ON" : "OFF"
    RStatus := RightClickActive ? "ON" : "OFF"
    MStatus := MiddleClickActive ? "ON" : "OFF"
    MaxStatus := MaximumMode ? "MAX" : "NORMAL"
    HoldStatus := MouseHoldActive ? "HOLDING" : ""
    
    if (MouseHoldActive) {
        TooltipText := "Mouse Spammer: " Status "`nMode: INFINITE HOLD`nL:" LStatus " R:" RStatus " M:" MStatus
    } else if (MaximumMode) {
        TooltipText := "Mouse Spammer: " Status "`nCPS: 60 (MAX MODE)`nL:" LStatus " R:" RStatus " M:" MStatus
    } else {
        TooltipText := "Mouse Spammer: " Status "`nCPS: " CPS "`nL:" LStatus " R:" RStatus " M:" MStatus
    }
    ToolTip, %TooltipText%, TooltipX + 20, TooltipY + 20
}

HideTooltip() {
    global TooltipActive
    if (TooltipActive) {
        TooltipActive := false
        ToolTip
    }
}

ToggleMaximumMode() {
    global MaximumMode, AutoclickerActive, TooltipActive, TooltipX, TooltipY, BaseInterval, CPS, MouseHoldActive, MaxModeRunning
    
    if (MouseHoldActive) {
        ToggleMouseHold()
    }
    
    MaximumMode := !MaximumMode
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
    
    if (MaximumMode) {
        if (!AutoclickerActive) {
            AutoclickerActive := true
            BaseInterval := 17
        }
        SetTimer, ClickLoop, Off
        MaxModeRunning := true
        SetTimer, MaxModeLoop, 17
    } else {
        MaxModeRunning := false
        SetTimer, MaxModeLoop, Off
        BaseInterval := 1000 // CPS
        if (AutoclickerActive) {
            SetTimer, ClickLoop, 10
        }
    }
}

ToggleMouseHold() {
    global MouseHoldActive, AutoclickerActive, MaximumMode, TooltipActive, TooltipX, TooltipY, LeftClickActive, RightClickActive, MiddleClickActive
    
    if (MaximumMode) {
        ToggleMaximumMode()
    }
    
    if (AutoclickerActive) {
        AutoclickerActive := false
        SetTimer, ClickLoop, Off
    }
    
    MouseHoldActive := !MouseHoldActive
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
    
    if (MouseHoldActive) {
        if (LeftClickActive) {
            Click, Down, Left
        }
        if (RightClickActive) {
            Click, Down, Right
        }
        if (MiddleClickActive) {
            Click, Down, Middle
        }
    } else {
        if (LeftClickActive) {
            Click, Up, Left
        }
        if (RightClickActive) {
            Click, Up, Right
        }
        if (MiddleClickActive) {
            Click, Up, Middle
        }
    }
}
