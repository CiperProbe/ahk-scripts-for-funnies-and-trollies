#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

global ClickCount := 0
global CPS := 0
global StartTime := 0
global LastClickTime := 0
global ClickTimes := []

Gui, Add, Text, x10 y10 w100 h30 vClickCountText, Clicks: 0
Gui, Add, Text, x120 y10 w100 h30 vCPSText, CPS: 0.00
Gui, Add, Button, x10 y50 w200 h30 gClickButton, Click
Gui, Add, Button, x10 y90 w200 h30 gResetClicks, Reset

Gui, +AlwaysOnTop +ToolWindow
Gui, Show, w220 h160, CPS Tester

SetTimer, UpdateCPS, 100

return

ClickButton:
    ClickCount++
    CurrentTime := A_TickCount
    
    ClickTimes.Push(CurrentTime)
    
    while (ClickTimes.Length() > 0 && CurrentTime - ClickTimes[1] > 1000)
        ClickTimes.RemoveAt(1)
    
    GuiControl,, ClickCountText, Clicks: %ClickCount%
return

ResetClicks:
    ClickCount := 0
    CPS := 0
    ClickTimes := []
    GuiControl,, ClickCountText, Clicks: 0
    GuiControl,, CPSText, CPS: 0.00
return

UpdateCPS:
    if (ClickTimes.Length() > 0)
    {
        CurrentTime := A_TickCount
        ValidClicks := 0
        for index, time in ClickTimes
        {
            if (CurrentTime - time <= 1000)
                ValidClicks++
        }
        CPS := ValidClicks
        GuiControl,, CPSText, CPS: %CPS%.00
    }
    else
    {
        CPS := 0
        GuiControl,, CPSText, CPS: 0.00
    }
return

GuiClose:
    ExitApp
return
