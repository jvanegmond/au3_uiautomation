#include "..\UIAWrappers.au3"
#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

AssertIsFalse(ProcessExists("notepad.exe"), "Please close notepad.exe before running tests")

$pid = Run("notepad.exe")
WinWait("Untitled - Notepad")
$hWnd = WinGetHandle("Untitled - Notepad")

ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]", "Hello World! 123")

Sleep(200)

$sText = _UIA_ControlGetText($hWnd, "[CLASS:Edit; INSTANCE:1]")

AssertAreEqual("Hello World! 123", $sText)

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe")
WEnd