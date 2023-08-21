# Anti-AFK
A lightweight AutoHotkey script to deal with AFK timers.<br>
Supports unfocused windows in addition to multiple processes!<br>

## Setup
Make sure to install [AutoHotkey](https://www.autohotkey.com/) if you haven't already.<br>
Open [Anti-AFK](Anti-AFK.ahk) in a text editor to access its config - each setting has a description.<br>
You will need to add your target process into the `PROCESS_LIST` for it to be monitored.<br>

## Functionality
Refer to the script's comments for a more detailed overview.<br>
- Windows belonging to monitored processes are identified.<br>
- These windows are tracked for `WINDOW_TIMEOUT` minutes of inactivity.<br>
- Keystrokes are sent to reset any potential AFK timers.<br>
  - This repeats every `TASK_INTERVAL` minutes for each inactive window.<br>
  - Background windows are briefly made transparent and foregrounded.<br>

## Locating Processes
You can use a utility called `Window Spy`, which is bundled with AutoHotkey.<br>
Right-click on the SysTray icon of any AutoHotKey script and select Window Spy.<br>
Then, hover over a window belonging to the process and note the `ahk_exe` value.<br>

## Bannable?
This heavily depends on the program you intend to use it on.<br>
AutoHotkey makes no attempt to hide itself: be careful if macros are blacklisted!<br>
