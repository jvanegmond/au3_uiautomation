#include "..\UIAWrappers.au3"
#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

AssertIsFalse(ProcessExists("notepad.exe"), "Please close notepad.exe before running tests")

$pid = Run("notepad.exe")
WinWait("Untitled - Notepad")
$hWnd = WinGetHandle("Untitled - Notepad")

$hControl = ControlGetHandle($hWnd, "", "[CLASS:Edit; INSTANCE:1]")

_UIA_ControlSetText($hWnd, $hControl, "Hello World!")

Sleep(200)

AssertAreEqual("Hello World!", ControlGetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]"))

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe")
WEnd