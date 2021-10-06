; Settings
#NoEnv
#Persistent
#UseHook, On
SendMode Input
#InstallKeybdHook
#InstallMouseHook
#SingleInstance, Force

; Options
; Time before Anti-AFK starts in minutes
timeout := 10

; Time between Anti-AFK actions in minutes
delay := 15

; Time between polling for changes (eg. roblox opened/closed) in seconds
pollDelay := 5

Gosub, PrepareVars

; Start Timers
SetTimer, GetRobloxState, %pollDelay%

; Activate Anti-AFK if needed
loop {
    if (AntiAFKActive) {
        BlockInput, On
        if (roblox_active) {
            Gosub, RobloxJump
        } else {
            Gosub, BringRobloxFront
            Sleep, 75
            Gosub, RobloxJump
            Sleep, 75
            Gosub, BringRobloxBack
        }
        BlockInput, Off 
        Sleep, %delay%
    } else {
        Sleep, %pollDelay%
    }
}

; Goto labels accordingly and decide if Anti-AFK is needed
GetRobloxState:
Gosub, CheckRobloxRunning
if (roblox_running) {
    Gosub, CheckRobloxActive
    if (roblox_active) {
        timer := delay
        if (A_TimeIdlePhysical > timeout) {
            Gosub, AntiAFKActiveTooltip
            AntiAFKActive := 1
        } else {
            Gosub, RobloxEnabledTooltip
            AntiAFKActive := 0
        }
    } else {
        if (timer > 0) {
            timer := timer - pollDelay
        }
        if (timer <= 0) {
            Gosub, AntiAFKActiveTooltip
            AntiAFKActive := 1
        } else {
            Gosub, RobloxEnabledTooltip
            AntiAFKActive := 0
        }
    }
} else {
    timer := delay
    Gosub, RobloxDisabledTooltip
}
return

; Declaring Tooltip Labels
RobloxDisabledTooltip:
if (systrayToolTip != 0) {
    Menu, Tray, Tip, Roblox Not Running`nPress END to exit
    Menu, Tray, Icon , %A_AhkPath%, 4, 1
    systrayToolTip := 0
}
return

RobloxEnabledTooltip:
if (systrayToolTip != 1) {
    Menu, Tray, Tip, Roblox Is Running`nPress END to exit
    Menu, Tray, Icon , %A_AhkPath%, 1, 1
    systrayToolTip := 1
}
return

AntiAFKActiveTooltip:
if (systrayToolTip != 2) {
    Menu, Tray, Tip, Anti-AFK Active`nPress END to exit
    Menu, Tray, Icon , %A_AhkPath%, 2, 1 
    systrayToolTip := 2
}
return

; Declaring other labels
RobloxJump:
Send, {Space Down}
sleep, 50
Send, {Space Up}
return

PrepareVars:
systrayToolTip := -1
delay := delay * 60 * 1000
pollDelay := pollDelay * 1000
timeout := timeout * 60 * 1000
timer := delay
return

BringRobloxFront:
; Give ROBLOX window focus and make it invisible
WinGetTitle, original_window_title, A
WinSet, Transparent, 0, ahk_exe RobloxPlayerBeta.exe
WinActivate, ahk_exe RobloxPlayerBeta.exe
return

BringRobloxBack:
; Hide the ROBLOX window and reactivate the original
WinSet, Bottom,, ahk_exe RobloxPlayerBeta.exe
WinSet, Transparent, OFF, ahk_exe RobloxPlayerBeta.exe
WinActivate, %original_window_title%
return

CheckRobloxRunning:
Process, Exist, RobloxPlayerBeta.exe
If (!ErrorLevel = 0) {
    ; Set Roblox Running Variable
    roblox_running = 1
} else {
    ; Set Roblox Running Variable
    roblox_running = 0
}
return

CheckRobloxActive:
WinGetTitle, active_window_title, A
If (active_window_title = "Roblox") {
    ; Set Roblox active variable
    roblox_active = 1

} else {
    ; Set Roblox active variable
    roblox_active = 0
}
return

; Option to exit
End::ExitApp
