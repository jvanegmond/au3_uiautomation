#include-once
#include "UIAWrappers.au3"

; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 and up
; Description ...: UI automation for AutoIt.
; Author(s) .....: junkew, Manadar
; ===============================================================================================================================

Func _UIA_ControlGetHandle($hWnd, $controlID)
	If Not __UIA_IsControl($hWnd) Then
		$hWnd = __UIA_ControlGetFromHwnd($hWnd)
		If @error Then Return SetError(1, 0, 0)
	EndIf

	If Not __UIA_IsControl($controlID) Then
		$controlID = __UIA_ControlGet($hWnd, $controlID)
		If @error Then Return SetError(2, 0, 0)
	EndIf

	Return $controlID
EndFunc

Func _UIA_ControlSetText($hWnd, $controlID, $text, $flag = 0)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$tPattern = __UIA_GetPattern($controlID, $UIA_ValuePattern)
	$tPattern.SetValue($text)

	; TODO: Impl $flag <> 0 to refresh window
EndFunc

Func _UIA_ControlGetText($hWnd, $controlID)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$tPattern = __UIA_GetPattern($controlID, $UIA_ValuePattern)
	Local $sText = ""
	$tPattern.CurrentValue($sText)
	Return $sText
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

		$tPattern = __UIA_GetPattern($controlID, $UIA_InvokePattern)
		$tPattern.Invoke()
	Else
		WinActivate($hWnd)

		$sBoundingRectangle = _UIA_GetPropertyValue($controlID, $UIA_BoundingRectanglePropertyId)
		$t = StringSplit($sBoundingRectangle, "; ", 1)

		If $x = Default Then $x = $t[3] / 2
		If $y = Default Then $y = $t[4] / 2

		$x = $x + Int($t[1])
		$y = $y + Int($t[2])

		MouseClick($button, $x, $y, $clicks, 0)
	EndIf
EndFunc