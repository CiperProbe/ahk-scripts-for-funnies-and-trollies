#NoEnv
#SingleInstance Force
#Persistent
SendMode Input
SetWorkingDir %A_ScriptDir%

; Global compatibility settings
#WinActivateForce
SendMode Input
SetBatchLines, -1
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
DetectHiddenWindows, On
SetTitleMatchMode, 2
SetKeyDelay, -1, -1
SetMouseDelay, -1

; Global variables
global spamActive := false
global spamDelay := 10  ; Default delay in milliseconds
global adaptMode := true  ; Auto adapt mode always enabled
global lastSpamTime := 0
global spamCount := 0
global lagThreshold := 50  ; ms threshold for detecting lag (more sensitive)
global performanceHistory := ""  ; Track performance over time
global holdMode := true  ; Hold keys down for more power
global isHoldActive := false  ; Prevent timer conflicts during hold
global insaneMode := false  ; Ultra-fast mode for 0-9ms
global systemLagDetection := true  ; Monitor system-wide performance
global lastSystemCheck := 0
global systemLagCount := 0

; Show tooltip on startup
ShowTooltip("DFJK Spammer - INACTIVE - Delay: 10ms - Adapt: ON - Hold: ON")

; Hotkeys
F1::ToggleSpam()
F2::DecreaseDelay()
F3::IncreaseDelay()
F4::ResetDelay()

; Toggle spam on/off
ToggleSpam() {
    global spamActive
    spamActive := !spamActive
    ShowTooltip()
    
    if (spamActive) {
        SetTimer, SpamKeys, %spamDelay%
    } else {
        SetTimer, SpamKeys, Off
    }
}

; Spam the dfjk keys with enhanced performance
SpamKeys() {
    global spamDelay, lastSpamTime, spamCount, adaptMode, lagThreshold, performanceHistory
    
    ; Track timing for adapt mode (always enabled) + System-wide lag detection
    currentTime := A_TickCount
    
    ; System-wide performance monitoring every 50ms for real-time detection
    if (systemLagDetection && currentTime - lastSystemCheck > 50) {
        lastSystemCheck := currentTime
        
        ; Check system-wide indicators
        systemLoad := GetSystemLoad()
        memoryUsage := GetMemoryUsage()
        
        ; Real-time system lag detection
        if (systemLoad > 75 || memoryUsage > 80) {
            systemLagCount++
            ; Immediate response for severe lag
            if (systemLoad > 90 || memoryUsage > 90) {
                systemLagCount += 2  ; Accelerate detection for severe conditions
            }
            
            if (systemLagCount >= 2) {  ; Faster response: 2 instead of 3
                ; System lag detected - increase delay immediately
                oldDelay := spamDelay
                if (systemLoad > 90 || memoryUsage > 90) {
                    spamDelay += 30  ; Severe lag - aggressive increase
                } else {
                    spamDelay += 15  ; Moderate lag - standard increase
                }
                if (spamDelay > 500)
                    spamDelay := 500
                
                if (spamActive) {
                    SetTimer, SpamKeys, %spamDelay%
                }
                ShowTooltip("SYSTEM LAG: " . oldDelay . "ms -> " . spamDelay . "ms (Load: " . systemLoad . "%, Mem: " . memoryUsage . "%)")
                systemLagCount := 0
            }
        } else {
            ; Gradual recovery when system is healthy
            if (systemLagCount > 0)
                systemLagCount--
            
            ; Auto-optimize when system is very healthy
            if (systemLoad < 50 && memoryUsage < 60 && spamDelay > 15) {
                oldDelay := spamDelay
                spamDelay -= 1  ; Gradual optimization
                if (spamActive) {
                    SetTimer, SpamKeys, %spamDelay%
                }
                ShowTooltip("SYSTEM OPT: " . oldDelay . "ms -> " . spamDelay . "ms (Load: " . systemLoad . "%, Mem: " . memoryUsage . "%)")
            }
        }
    }
    
    if (lastSpamTime > 0) {
        actualDelay := currentTime - lastSpamTime
        
        ; Store performance data
        performanceHistory := performanceHistory . actualDelay . ","
        StringSplit, perfArray, performanceHistory, `, 
        if (perfArray0 > 10) {
            ; Keep only last 10 measurements
            StringSplit, perfArray, performanceHistory, `, 
            performanceHistory := ""
            Loop, % perfArray0-1
            {
                if (A_Index > 1)
                    performanceHistory := performanceHistory . perfArray%A_Index% . ","
            }
        }
        
        ; Adapt mode: auto-adjust if lag detected (always enabled)
        if (adaptMode && perfArray0 >= 3) {
            avgDelay := 0
            count := 0
            Loop, % perfArray0-1
            {
                if (A_Index > 1) {
                    avgDelay += perfArray%A_Index%
                    count++
                }
            }
            avgDelay := avgDelay / count
            
            ; More aggressive lag detection and compensation
            if (avgDelay > spamDelay + lagThreshold) {
                ; Increase more aggressively based on how bad the lag is
                lagAmount := avgDelay - spamDelay - lagThreshold
                oldDelay := spamDelay
                if (lagAmount > 100) {
                    spamDelay += 15  ; Heavy lag - big increase
                } else if (lagAmount > 50) {
                    spamDelay += 8   ; Medium lag - moderate increase
                } else {
                    spamDelay += 3   ; Light lag - small increase
                }
                if (spamDelay > 500)
                    spamDelay := 500  ; Cap at 500ms for stability
                ; Update timer with new delay
                if (spamActive) {
                    SetTimer, SpamKeys, %spamDelay%
                }
                ; Show adapt mode change
                ShowTooltip("Adapt: " . oldDelay . "ms -> " . spamDelay . "ms (LAG)")
            }
            ; More aggressive optimization when performing well
            else if (avgDelay < spamDelay - 15 && spamDelay > 10) {
                ; Decrease more conservatively to avoid oscillation
                oldDelay := spamDelay
                if (spamDelay > 100) {
                    spamDelay -= 5  ; Can decrease faster at higher delays
                } else if (spamDelay > 50) {
                    spamDelay -= 3  ; Moderate decrease at medium delays
                } else {
                    spamDelay -= 2  ; Slow decrease at low delays to avoid instability
                }
                ; Update timer with new delay
                if (spamActive) {
                    SetTimer, SpamKeys, %spamDelay%
                }
                ; Show adapt mode change
                ShowTooltip("Adapt: " . oldDelay . "ms -> " . spamDelay . "ms (OPT)")
            }
        }
    }
    
    lastSpamTime := currentTime
    spamCount++
    
    ; INSANE MODE SPAMMER - Exponential scaling for ultra-fast speeds
    if (isHoldActive)
        return  ; Skip if hold sequence is already running
    
    isHoldActive := true  ; Set flag to prevent conflicts
    
    if (spamDelay <= 9) {
        ; INSANE MODE: Exponential scaling (10ms = 100cps, 9ms = 200cps, 8ms = 400cps, etc.)
        insaneMode := true
        multiplier := 2 ^ (10 - spamDelay)  ; 2^(10-delay) = exponential multiplier
        
        Loop, %multiplier% {
            ; Maximum power techniques for each iteration
            SendPlay, dfjk
            SendInput, dfjk
            Send, dfjk
            SendPlay, {d down}{f down}{j down}{k down}
            Sleep, 1
            SendPlay, {d up}{f up}{j up}{k up}
            SendInput, {d down}{f down}{j down}{k down}
            Sleep, 1
            SendInput, {d up}{f up}{j up}{k up}
        }
        
        ; Final burst
        SendPlay, dfjkdfjkdfjkdfjk
        SendInput, dfjkdfjk
        
    } else if (spamDelay < 25) {
        ; Fast mode: Enhanced sequence
        SendInput, dfjk
        SendInput, {d down}{f down}{j down}{k down}
        Sleep, 8
        SendInput, {d up}{f up}{j up}{k up}
        SendInput, dfjk
        SendPlay, dfjk
    } else {
        ; Normal mode: Standard sequence
        Send, dfjk
        Send, {d down}{f down}{j down}{k down}
        Sleep, 8
        Send, {d up}{f up}{j up}{k up}
    }
    
    isHoldActive := false  ; Clear flag to allow next execution
}

; Increase delay (make slower)
IncreaseDelay() {
    global spamDelay, spamActive, adaptMode
    spamDelay += 1
    ShowTooltip()
    
    if (spamActive) {
        SetTimer, SpamKeys, %spamDelay%
    }
}

; Decrease delay (make faster)
DecreaseDelay() {
    global spamDelay, spamActive, adaptMode
    spamDelay -= 1
    if (spamDelay < 0) {
        spamDelay := 0  ; Min 0ms for insane mode
    }
    
    ; Check if entering W.I.P range
    if (spamDelay <= 9) {
        ShowTooltip("Unaccessible (Can be edited.)")
        spamDelay := 10  ; Reset to 10ms
        return
    }
    
    ShowTooltip()
    
    if (spamActive) {
        SetTimer, SpamKeys, %spamDelay%
    }
}

; Reset delay to default
ResetDelay() {
    global spamDelay, spamActive, adaptMode, performanceHistory
    spamDelay := 10
    performanceHistory := ""  ; Reset performance tracking
    ShowTooltip()
    
    if (spamActive) {
        SetTimer, SpamKeys, %spamDelay%
    }
}

; Show tooltip with current status
ShowTooltip(message = "") {
    global spamActive, spamDelay, adaptMode, spamCount, holdMode
    
    if (message = "") {
        adaptStatus := adaptMode ? "ON" : "OFF"
        holdStatus := holdMode ? "ON" : "OFF"
        message := "DFJK Spammer - " . (spamActive ? "ACTIVE" : "INACTIVE") . " - Delay: " . spamDelay . "ms - Adapt: " . adaptStatus . " - Hold: " . holdStatus . " - Count: " . spamCount
    }
    
    ToolTip, %message%
    SetTimer, RemoveTooltip, -2000  ; Remove tooltip after 2 seconds
}

; Remove tooltip
RemoveTooltip() {
    ToolTip
}

; Get system CPU load percentage
GetSystemLoad() {
    ; Use WMI to get CPU usage
    try {
        objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2")
        colItems := objWMIService.ExecQuery("Select * from Win32_Processor")
        for item in colItems {
            return Round(item.LoadPercentage)
        }
    }
    return 0  ; Fallback
}

; Get memory usage percentage
GetMemoryUsage() {
    ; Use WMI to get memory usage
    try {
        objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2")
        colItems := objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
        for item in colItems {
            totalMem := item.TotalVisibleMemorySize
            freeMem := item.FreePhysicalMemory
            usedMem := totalMem - freeMem
            return Round((usedMem / totalMem) * 100)
        }
    }
    return 0  ; Fallback
}
