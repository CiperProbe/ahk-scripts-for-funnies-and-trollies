#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetMouseDelay, -1

; Set coordinate mode relative to screen
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

active := false
baseSpeed := 5
currentSpeed := baseSpeed

F1::
    active := !active
    if (active) {
        ; Move mouse to center of screen (960, 540 for 1920x1080)
        MouseMove, 960, 540, 0
        
        ; Start the movement timer
        SetTimer, MoveMouse, 10
        ToolTip, ACTIVE - Moving RIGHT - Speed: %currentSpeed%
        SetTimer, RemoveToolTip, 1000
    } else {
        SetTimer, MoveMouse, Off
        ToolTip, INACTIVE
        SetTimer, RemoveToolTip, 1000
    }
return

F2::
    currentSpeed := currentSpeed + 1
    ToolTip, Speed: %currentSpeed%
    SetTimer, RemoveToolTip, 1000
return

F3::
    if (currentSpeed > 1)
        currentSpeed := currentSpeed - 1
    ToolTip, Speed: %currentSpeed%
    SetTimer, RemoveToolTip, 1000
return

F4::
    currentSpeed := baseSpeed
    ToolTip, Speed reset to %baseSpeed%
    SetTimer, RemoveToolTip, 1000
return

F5::
    currentSpeed := currentSpeed * 10
    ToolTip, ULTRA BOOST! Speed: %currentSpeed%
    SetTimer, RemoveToolTip, 1000
return

NumpadAdd::
    currentSpeed := currentSpeed + 1
    ToolTip, Speed: %currentSpeed%
    SetTimer, RemoveToolTip, 1000
return

NumpadSub::
    if (currentSpeed > 1)
        currentSpeed := currentSpeed - 1
    ToolTip, Speed: %currentSpeed%
    SetTimer, RemoveToolTip, 1000
return

MoveMouse:
    MouseGetPos, current_x, current_y
    
    ; First, ensure we're at the vertical center (540)
    if (current_y != 540) {
        DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", 540 - current_y, "UInt", 0, "UPtr", 0)
        return
    }
    
    ; Now handle horizontal movement
    if (current_x < 960) {
        delta_x := 960 - current_x
        DllCall("mouse_event", "UInt", 0x0001, "Int", delta_x, "Int", 0, "UInt", 0, "UPtr", 0)
    } else {
        DllCall("mouse_event", "UInt", 0x0001, "Int", currentSpeed, "Int", 0, "UInt", 0, "UPtr", 0)
    }
return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return