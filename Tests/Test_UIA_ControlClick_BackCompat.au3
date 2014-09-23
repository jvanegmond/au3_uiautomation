#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

$hWnd = GUICreate("Test window")
$btn1 = GUICtrlCreateButton("Button 1", 10, 10)
$btn2 = GUICtrlCreateButton("Button 2", 10, 110)
$edit1 = GUICtrlCreateEdit("", 10, 200, 200, 100)

GUISetState()

_UIA_ControlClick($hWnd, $btn1, "Primary", 2)

$btn1Clicked = 0

$t = TimerInit()
While TimerDiff($t) < 1000
	Switch GUIGetMsg()
		Case $btn1
			$btn1Clicked += 1
			If $btn1Clicked == 2 Then ExitLoop
	EndSwitch
WEnd

AssertIsTrue($btn1Clicked, "Button 1 was not clicked twice by _UIA_ControlClick")