#include "..\UIAWrappers.au3"
#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 10)
$btn2 = GUICtrlCreateButton("Button 2", 10, 110)
$edit1 = GUICtrlCreateEdit("", 10, 200, 200, 100)

GUISetState()

ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]", "Hello World! 123")

$sText = _UIA_ControlGetText($hWnd, "[CLASS:Edit; INSTANCE:1]")

AssertAreEqual("Hello World! 123", $sText)

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe")
WEnd