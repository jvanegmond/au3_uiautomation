#include "..\UIAWrappers.au3"
#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 10)
$btn2 = GUICtrlCreateButton("Button 2", 10, 110)
$edit1 = GUICtrlCreateEdit("Test text", 10, 200, 200, 100)

GUISetState()

$oWindow = _UIA_ControlGetHandle($hWnd, "[INSTANCE:1]")

$sClassName = _UIA_GetPropertyValue($oWindow, $UIA_ClassNamePropertyId)

AssertAreEqual("Button", $sClassName)

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe")
WEnd