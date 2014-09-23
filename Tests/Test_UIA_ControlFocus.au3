#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 10)
$btn2 = GUICtrlCreateButton("Button 2", 10, 110)
$edit1 = GUICtrlCreateEdit("", 10, 200, 200, 100)

GUISetState()

$focus = ControlGetFocus($hWnd)
AssertAreEqual("Button1", $focus, "Focus not on Button1")

_UIA_ControlFocus($hWnd, "Button2")

$focus = ControlGetFocus($hWnd)
AssertAreEqual("Button2", $focus, "Focus not on Button2")