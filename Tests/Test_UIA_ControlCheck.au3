#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateCheckbox("Toggle me!", 10, 10)

GUISetState()

; Not checked -> Check it, Control = Checked
_UIA_ControlCheck($hWnd, "[INSTANCE:1]", True)
AssertIsTrue(ControlCommand($hWnd, "", "[INSTANCE:1]", "IsChecked", ""))

; Checked -> Check it, Control = Checked
_UIA_ControlCheck($hWnd, "[INSTANCE:1]", True)
AssertIsTrue(ControlCommand($hWnd, "", "[INSTANCE:1]", "IsChecked", ""))

; Checked -> Uncheck it, Control = Unchecked
_UIA_ControlCheck($hWnd, "[INSTANCE:1]", False)
AssertIsFalse(ControlCommand($hWnd, "", "[INSTANCE:1]", "IsChecked", ""))

; Unchecked -> Uncheck it, Control = Unchecked
_UIA_ControlCheck($hWnd, "[INSTANCE:1]", False)
AssertIsFalse(ControlCommand($hWnd, "", "[INSTANCE:1]", "IsChecked", ""))
