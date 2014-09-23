#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 10)
$btn2 = GUICtrlCreateButton("Button 2", 10, 110)
$edit1 = GUICtrlCreateEdit("Test text", 10, 200, 200, 100)

GUISetState()

_UIA_ControlSetText($hWnd, "[TEXT:Something not in the GUI]", "Hello World!")

AssertNotEqual(0, @error)
AssertAreEqual("Test text", ControlGetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]"))

_UIA_ControlSetText($hWnd, "[TEXT:Test text]", "Hello World!")

AssertAreEqual("Hello World!", ControlGetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]"))