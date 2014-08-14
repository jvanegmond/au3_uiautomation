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

Func _UIA_ControlSetText($hWnd, $controlID, $text)
	If Not __UIA_IsControl($hWnd) Then
		$hWnd = __UIA_ControlGetFromHwnd($hWnd)
		If @error Then Return SetError(1, 0, 0)
	EndIf

	If Not __UIA_IsControl($controlID) Then
		$controlID = __UIA_ControlGet($hWnd, $controlID)
		If @error Then Return SetError(2, 0, 0)
	EndIf

	$controlID.setfocus()
	Sleep(200)
	$tPattern = __UIA_getPattern($controlID, $UIA_ValuePattern)
	$tPattern.setvalue($text)
EndFunc