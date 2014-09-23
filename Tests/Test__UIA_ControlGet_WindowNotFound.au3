#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

_UIA_ControlSetText(0, "[ID:1]", "Hello World!")
AssertNotEqual(0, @error)

_UIA_ControlSetText("Some window string which hopefully does not exist", "[ID:1]", "Hello World!")
AssertNotEqual(0, @error)

$hWnd = GUICreate("Some title")
GUISetState()

GUIDelete()

_UIA_ControlSetText($hWnd, "[ID:1]", "Hello World!")
AssertNotEqual(0, @error)