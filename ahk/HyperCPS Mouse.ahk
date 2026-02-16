#NoEnv
#SingleInstance Force
#Persistent
SendMode Input  ; Fastest input mode
SetBatchLines -1  ; Fastest processing
SetWinDelay -1
SetKeyDelay -1, -1
SetMouseDelay -1
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen
#InstallKeybdHook
#InstallMouseHook
#UseHook
#MaxThreads 10
#MaxThreadsPerHotkey 2
DetectHiddenWindows, On
SetTitleMatchMode, 2

global AutoclickerActive := false
global MaxModeRunning := false
global ClickCount := 0
global TooltipActive := false
global TooltipX := 0
global TooltipY := 0
global LeftClickActive := true
global RightClickActive := false
global MiddleClickActive := false

SetTimer, UpdateTooltip, 100
SetTimer, HideTooltip, 2000

*F1::ToggleAutoclicker()
*F2::ToggleLeftClick()
*F3::ToggleRightClick()
*F4::ToggleMiddleClick()

ToggleAutoclicker() {
    global AutoclickerActive, MaxModeRunning, TooltipActive, TooltipX, TooltipY
    
    AutoclickerActive := !AutoclickerActive
    TooltipActive := true
    MouseGetPos, TooltipX, TooltipY
    
    if (AutoclickerActive) {
        MaxModeRunning := true
        SetTimer, MaxModeLoop, 0
    } else {
        MaxModeRunning := false
        SetTimer, MaxModeLoop, Off
    }
}

MaxModeLoop:
    global MaxModeRunning, LeftClickActive, RightClickActive, MiddleClickActive, ClickCount
    
    while (MaxModeRunning) {
        if (LeftClickActive) {
            MouseClick, Left
            ClickCount++
        }
        if (RightClickActive) {
            MouseClick, Right
            ClickCount++
        }
        if (MiddleClickActive) {
            MouseClick, Middle
            ClickCount++
        }
        
        Sleep, 0
    }
return

UpdateTooltip() {
    global AutoclickerActive, LeftClickActive, RightClickActive, MiddleClickActive, TooltipActive, TooltipX, TooltipY
    
    if (!TooltipActive)
        return
        
    Status := AutoclickerActive ? "ON" : "OFF"
    LStatus := LeftClickActive ? "ON" : "OFF"
    RStatus := RightClickActive ? "ON" : "OFF"
    MStatus := MiddleClickActive ? "ON" : "OFF"
    
    TooltipText := "200 CPS MOUSE: " Status "`nCPS: 200 (HYPER MODE)`nL:" LStatus " R:" RStatus " M:" MStatus
    ToolTip, %TooltipText%, TooltipX + 20, TooltipY + 20
}

HideTooltip() {
    global TooltipActive
    if (TooltipActive) {
        TooltipActive := false
        ToolTip
    }
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
