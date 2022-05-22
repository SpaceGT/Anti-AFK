;     /$$$$$$              /$$     /$$          /$$$$$$  /$$$$$$$$ /$$   /$$
;    /$$__  $$            | $$    |__/         /$$__  $$| $$_____/| $$  /$$/
;   | $$  \ $$ /$$$$$$$  /$$$$$$   /$$        | $$  \ $$| $$      | $$ /$$/
;   | $$$$$$$$| $$__  $$|_  $$_/  | $$ /$$$$$$| $$$$$$$$| $$$$$   | $$$$$/
;   | $$__  $$| $$  \ $$  | $$    | $$|______/| $$__  $$| $$__/   | $$  $$
;   | $$  | $$| $$  | $$  | $$ /$$| $$        | $$  | $$| $$      | $$\  $$
;   | $$  | $$| $$  | $$  |  $$$$/| $$        | $$  | $$| $$      | $$ \  $$
;   |__/  |__/|__/  |__/   \___/  |__/        |__/  |__/|__/      |__/  \__/
;
;   Programs --> Executables that the target processes run under (array)
;   Timeout --> Idle time required for Anti-AFK to start (minutes)
;   Delay --> Time between Anti-AFK's actions (minutes)
;   Poll --> Time interval for polling whether the process is running (seconds)

Programs := ["RobloxPlayerBeta.exe"]
Timeout := 10
Delay := 15
Poll := 5

; Directives
#NoEnv
SendMode Input
#SingleInstance Force

; Script Variables
tray_icon := ""
Timeout := Timeout * 60
Delay := Delay * 60
poll_ms := Poll * 1000

; Tooltip Texts (Customisable)
disabled_tooltip := "No Windows Found`nPress END to exit"
idle_tooltip := "Anti-AFK Idle`nPress END to exit"
active_tooltip := "Anti-AFK Active`nPress END to exit"

; Prompt to Run as Admin
if not A_IsAdmin {
    admin_title := "Run as Admin?"
    admin_message := "
    (
        Anti-AFK has the option to temporarily block
        keystrokes when running as Admin.

        This is optional but be aware keystrokes may
        leak into the target window if you are typing
        whilst Anti-AFK is interacting with it.
    )"

    MsgBox, 4, %admin_title%, %admin_message%

    IfMsgBox Yes
        Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
}

; Start Anti-AFK
GoSub, UpdateOnPoll
SetTimer, UpdateOnPoll, %poll_ms%
return

; Reset AFK Timer (Customisable)
ResetTimer:
Send, {Space Down}
Sleep, 50
Send, {Space Up}
return

; Create Tray Icons
TrayScriptDisabled:
if tray_icon == "ScriptDisabled"
    return
tray_icon := "ScriptDisabled"

Menu, Tray, Tip, %disabled_tooltip%
Menu, Tray, Icon , %A_AhkPath%, 4, 1
return

TrayScriptIdle:
if tray_icon == "ScriptIdle"
    return
tray_icon := "ScriptIdle"

Menu, Tray, Tip, %idle_tooltip%
Menu, Tray, Icon , %A_AhkPath%, 1, 1
return

TrayScriptActive:
if tray_icon == "ScriptActive"
    return
tray_icon := "ScriptActive"

Menu, Tray, Tip, %active_tooltip%
Menu, Tray, Icon , %A_AhkPath%, 2, 1
return

; Update with Poll Frequency
UpdateOnPoll:
script_active_flag := False
script_idle_flag := False

for i, executable in Programs {
    WinGet, window_list, List, ahk_exe %executable%
    loop, %window_list% {
        window := % window_list%A_Index%

        if % loop_timeout_count%window% == ""
            loop_timeout_count%window% := Max(1, Round(Timeout / Poll))

        if % loop_delay_count%window% == ""
            loop_delay_count%window% := 1

        if WinActive("ahk_id" window) {
            if (A_TimeIdlePhysical > Timeout*1000) {
                loop_delay_count%window% -= 1
                script_active_flag := True
            } else {
                loop_timeout_count%window% := Max(1, Round(Timeout / Poll))
                loop_delay_count%window% := 1
                script_idle_flag := True
            }

            if % loop_delay_count%window% == 0 {
                loop_delay_count%window% := Max(1, Round(Delay / Poll))
                GoSub, ResetTimer
            }

        } else {
            if % loop_timeout_count%window% > 0
                loop_timeout_count%window% -= 1

            if % loop_timeout_count%window% == 0 {
                loop_delay_count%window% -= 1
                script_active_flag := True
            } else {
                loop_delay_count%window% := 1
                script_idle_flag := True
            }

            if % loop_delay_count%window% == 0 {
                loop_delay_count%window% := Max(1, Round(Delay / Poll))

                BlockInput, On
                WinGet, old_window, ID, A

                WinSet, Transparent, 0, ahk_id %window%
                WinActivate, ahk_id %window%

                GoSub, ResetTimer

                WinSet, Bottom,, ahk_id %window%
                WinSet, Transparent, OFF, ahk_id %window%

                WinActivate, ahk_id %old_window%
                BlockInput, Off
            }
        }
    }
}

if script_active_flag {
    GoSub, TrayScriptActive

} else if script_idle_flag {
    GoSub, TrayScriptIdle

} else {
    GoSub, TrayScriptDisabled
}
return

; Option to exit
End::ExitApp
