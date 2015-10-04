#include <Array.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <Misc.au3>
#include <AutoItConstants.au3>
#include "..\..\UIAutomation.au3"

Const $KEY_ESC = "1B"
Local $lastKnownPos[4]

While Not _IsPressed($KEY_ESC)
	Local $mousePos = MouseGetPos()
	Local $oUIElement = _UIA_GetElementFromPoint($mousePos)
	Local $controlPos = _UIA_ControlGetPos(0, $oUIElement)
	If Not CoordEquals($lastKnownPos, $controlPos) Then
		$lastKnownPos = $controlPos
		_ShowFrame(True, $oUIElement, $controlPos)
	EndIf
	Sleep(10)
WEnd

Func CoordEquals($a, $b)
	If Not IsArray($a) Or Not IsArray($b) Then Return False

	For $i = 0 To 3
		If $a[$i] <> $b[$i] Then Return False
	Next

	Return True
EndFunc

Func _ShowFrame($fShow, $Element = Null, $Pos = 0)
	Local Const $FrameAlpha = 192
	Local Const $FrameColor = 0xFF0000
	Local Const $Thickness = 2

	Local Static $hFrame[4]

	If Not $hFrame[0] Then
		For $n = 0 To 3
			$hFrame[$n] = GUICreate('', 100, 100, -1, -1, $WS_POPUP, $WS_EX_APPWINDOW)
			GUISetBkColor($FrameColor, $hFrame[$n])
			WinSetTrans($hFrame[$n], '', $FrameAlpha)
		Next
	EndIf

	If Not $fShow Or UBound($Pos) <> 4 Then
		For $n = 0 To 3
			GUISetState(@SW_HIDE, $hFrame[$n])
		Next
		Return
	EndIf

	; If the given element is one of our frame windows, do not change the frame
	$hWnd = _UIA_GetPropertyValue($Element, $UIA_NativeWindowHandlePropertyId)
	For $n = 0 To 3
		If Int($hFrame[$n]) == Int($hWnd) Then Return
	Next

	WinMove($hFrame[0], '', $Pos[0], $Pos[1], $Thickness, $Pos[3]) ; Left
	WinMove($hFrame[1], '', $Pos[0], $Pos[1], $Pos[2], $Thickness) ; Top
	WinMove($hFrame[2], '', $Pos[0] + $Pos[2] - $Thickness, $Pos[1], $Thickness, $Pos[3]) ; Right
	WinMove($hFrame[3], '', $Pos[0], $Pos[1] + $Pos[3] - $Thickness, $Pos[2], $Thickness) ; Bottom

	For $n = 0 To 3
		GUISetState(@SW_SHOWNOACTIVATE, $hFrame[$n])
		WinSetOnTop($hFrame[$n], '', $WINDOWS_ONTOP)
	Next
EndFunc   ;==>_ShowFrame