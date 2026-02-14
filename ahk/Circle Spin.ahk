#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetMouseDelay, -1

cx := 960
cy := 540
r := 200
a := 0
active := false
speed_multiplier := 1.0

F1::
    active := !active
    if (active)
        SetTimer, Spin, 1
    else
        SetTimer, Spin, Off
return

F2::
    speed_multiplier := speed_multiplier * 1.5
    ToolTip, Speed: %speed_multiplier%
    SetTimer, RemoveToolTip, 1000
return

F3::
    if (speed_multiplier > 0.001)
        speed_multiplier := speed_multiplier / 1.5
    ToolTip, Speed: %speed_multiplier%
    SetTimer, RemoveToolTip, 1000
return

F4::
    speed_multiplier := 1.0
    ToolTip, Speed reset to 1.0
    SetTimer, RemoveToolTip, 1000
return


NumpadAdd::
    speed_multiplier := speed_multiplier + 0.1
    ToolTip, Speed: %speed_multiplier%
    SetTimer, RemoveToolTip, 1000
return

NumpadSub::
    if (speed_multiplier > 0.1)
        speed_multiplier := speed_multiplier - 0.1
    ToolTip, Speed: %speed_multiplier%
    SetTimer, RemoveToolTip, 1000
return

Spin:
    new_x := 960 + r * Cos(a)
    new_y := 540 + r * Sin(a)
    
    MouseGetPos, current_x, current_y
    
    delta_x := new_x - current_x
    delta_y := new_y - current_y
    
    DllCall("mouse_event", "UInt", 0x0001, "Int", delta_x, "Int", delta_y, "UInt", 0, "UPtr", 0)
    
    a += speed_multiplier
    
    if (a > 100000000)
        a := 0
return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return