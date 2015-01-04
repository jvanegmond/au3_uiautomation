#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"
#include <Array.au3>

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 10)
$edit1 = GUICtrlCreateEdit("Test text", 20, 200, 200, 100)
$btn2 = GUICtrlCreateButton("Button 2", 30, 110)

GUISetState()

$oWindow = _UIA_ControlGetHandle($hWnd, "[Y:226]")

$sClassName = _UIA_GetPropertyValue($oWindow, $UIA_ClassNamePropertyId)

AssertAreEqual("Edit", $sClassName)