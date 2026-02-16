#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; GUI Variables
global ClickCount := 0
global CPS := 0
global StartTime := 0
global LastClickTime := 0
global ClickTimes := []

; Create GUI
Gui, Add, Text, x10 y10 w100 h30 vClickCountText, Clicks: 0
Gui, Add, Text, x120 y10 w100 h30 vCPSText, CPS: 0.00
Gui, Add, Button, x10 y50 w200 h30 gClickButton, Click
Gui, Add, Button, x10 y90 w200 h30 gResetClicks, Reset

; Set GUI properties
Gui, +AlwaysOnTop +ToolWindow
Gui, Show, w220 h160, CPS Tester

; Timer to update CPS display
SetTimer, UpdateCPS, 100

return

; Click button handler
ClickButton:
    ClickCount++
    CurrentTime := A_TickCount
    
    ; Store click time for CPS calculation
    ClickTimes.Push(CurrentTime)
    
    ; Remove clicks older than 1 second
    while (ClickTimes.Length() > 0 && CurrentTime - ClickTimes[1] > 1000)
        ClickTimes.RemoveAt(1)
    
    ; Update click count display
    GuiControl,, ClickCountText, Clicks: %ClickCount%
return

; Reset button handler
ResetClicks:
    ClickCount := 0
    CPS := 0
    ClickTimes := []
    GuiControl,, ClickCountText, Clicks: 0
    GuiControl,, CPSText, CPS: 0.00
return

; Update CPS display
UpdateCPS:
    if (ClickTimes.Length() > 0)
    {
        CurrentTime := A_TickCount
        ; Count clicks in the last second
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

; GUI close handler
GuiClose:
    ExitApp
return
