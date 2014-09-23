#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 15, 80, 30)
$btn2 = GUICtrlCreateButton("Button 2", 10, 110)
$edit1 = GUICtrlCreateEdit("", 10, 200, 200, 100)

GUISetState()

$bound = _UIA_ControlGetPos($hWnd, "[CLASS:Button; INSTANCE:1]")

AssertIsType($bound, "Array")
AssertAreEqual(13, $bound[0])
AssertAreEqual(41, $bound[1])
AssertAreEqual(80, $bound[2])
AssertAreEqual(30, $bound[3])

Sleep(100)