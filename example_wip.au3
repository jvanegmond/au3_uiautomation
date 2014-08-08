#include "UIAWrappers.au3"

; Short test script for development purposes

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd

$pid = Run("notepad.exe")

$hWnd = WinGetHandle("Untitled - Notepad")

$hEdit1 = _UIA_ControlGetHandle($hWnd, "[CLASS:Edit; INSTANCE: 1]")

_UIA_ControlSetText($hWnd, $hEdit1, "It works!")