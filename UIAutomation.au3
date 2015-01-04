#include-once
#include "UIAWrappers.au3"

; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 and up
; Description ...: UI automation for AutoIt.
; Author(s) .....: junkew, Manadar
; ===============================================================================================================================

Func _UIA_ControlGetHandle($hWnd, $controlID)
	If Not _UIA_IsElement($hWnd) Then
		$hWnd = __UIA_ControlGetFromHwnd($hWnd)
		If @error Then Return SetError(1, 0, 0)
	EndIf

	If Not _UIA_IsElement($controlID) Then
		$controlID = __UIA_ControlGet($hWnd, $controlID)
		If @error Then Return SetError(2, 0, 0)
	EndIf

	Return $controlID
EndFunc

Func _UIA_ControlSetText($hWnd, $controlID, $text, $flag = 0)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$tPattern = _UIA_CreateControlPattern($controlID, $UIA_ValuePattern)
	$tPattern.SetValue($text)

	; TODO: Impl $flag <> 0 to refresh window
EndFunc

Func _UIA_ControlGetText($hWnd, $controlID)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$tPattern = _UIA_CreateControlPattern($controlID, $UIA_ValuePattern)
	Local $sText = ""
	$tPattern.CurrentValue($sText)
	Return $sText
EndFunc

Func _UIA_ControlCheck($hWnd, $controlID, $checked = True)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$currentState = _UIA_GetPropertyValue($controlID, $UIA_ToggleToggleStatePropertyId)

	$tPattern = _UIA_CreateControlPattern($controlID, $UIA_TogglePattern)
	If $currentState <> $checked Then
		$tPattern.Toggle()
	EndIf
EndFunc

Func _UIA_ControlFocus($hWnd, $controlID)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$controlID.SetFocus()
EndFunc

Func _UIA_ControlClick($hWnd, $controlID, $button = "invoke", $clicks = 1, $x = Default, $y = Default)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	If $button = "invoke" Then
		$controlID.SetFocus()

		$tPattern = _UIA_CreateControlPattern($controlID, $UIA_InvokePattern)
		$tPattern.Invoke()
	Else
		WinActivate($hWnd)

		$aBound = _UIA_GetPropertyValue($controlID, $UIA_BoundingRectanglePropertyId)

		If $x = Default Then $x = $aBound[2] / 2
		If $y = Default Then $y = $aBound[3] / 2

		$x = $x + $aBound[0]
		$y = $y + $aBound[1]

		MouseClick($button, $x, $y, $clicks, 0)
	EndIf
EndFunc

Func _UIA_ControlGetPos($hWnd, $controlID)
	If Not _UIA_IsElement($hWnd) Then
		$hWnd = __UIA_ControlGetFromHwnd($hWnd)
		If @error Then Return SetError(1, 0, 0)
	EndIf

	If Not _UIA_IsElement($controlID) Then
		$controlID = __UIA_ControlGet($hWnd, $controlID)
		If @error Then Return SetError(2, 0, 0)
	EndIf

	$aWinBound = _UIA_GetPropertyValue($hWnd, $UIA_BoundingRectanglePropertyId)
	$aBound = _UIA_GetPropertyValue($controlID, $UIA_BoundingRectanglePropertyId)

	$aBound[0] = $aBound[0] - $aWinBound[0]
	$aBound[1] = $aBound[1] - $aWinBound[1]

	Return $aBound
EndFunc

Func _UIA_ControlSend($hWnd, $controlID, $string, $flag = 0)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	WinActivate($hWnd)

	$controlID.SetFocus()

	SendKeepActive($hWnd)
	Send($string, $flag)
EndFunc