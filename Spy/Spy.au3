#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <Misc.au3>
#include <AutoItConstants.au3>
#include <WinAPIRes.au3>
#include "..\UIAutomation.au3"

Const $MB_PRIMARY = "01"
Const $ICON_FOLDER = @ScriptDir & "\Spy\Resources\"
Const $ICON_PICKER = $ICON_FOLDER & "202.ico"
Const $ICON_PICKER_EMPTY = $ICON_FOLDER & "201.ico"

Local $hWnd = GUICreate("Spy", 140, 140)

GUICtrlCreateGroup('Browse Tool', 20, 20, 98, 104)

Local $Icon = GUICtrlCreateIcon($ICON_PICKER, -1, 36, 36, 64, 64)

GUISetState()

While True
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Icon
			StartCaptureUnderCursor()
	EndSwitch
WEnd

Exit

Func StartCaptureUnderCursor()
	Static $hCursor
	Static $hPrev

	If Not $hCursor Then
		$hCursor = _WinAPI_LoadCursorFromFile($ICON_FOLDER & '100.cur')
		$hPrev = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, $IDI_APPLICATION))
	EndIf

	_WinAPI_SetSystemCursor($hCursor, $IDI_APPLICATION, 1)

	GUICtrlSetImage($Icon, $ICON_PICKER_EMPTY)

	CaptureUnderCursor()

	GUICtrlSetImage($Icon, $ICON_PICKER)

	_WinAPI_SetSystemCursor($hPrev, $IDI_APPLICATION, 1)
EndFunc

Func CaptureUnderCursor()
	Local $lastKnownPos[4]
	While _IsPressed($MB_PRIMARY)
		Local $mousePos = MouseGetPos()
		Local $oUIElement = _UIA_GetElementFromPoint($mousePos)
		Local $controlPos = _UIA_ControlGetPos(0, $oUIElement)
		If Not @error And Not CoordEquals($lastKnownPos, $controlPos) Then
			$lastKnownPos = $controlPos
			_ShowFrame(True, $oUIElement, $controlPos)
		EndIf
		Sleep(20)
	WEnd

	_ShowFrame(False)
EndFunc

Func _ShowProperties($oUIElement)
	Local $text = _UIA_ControlGetText(Default, $oUIElement)
	If StringInStr($text, @CRLF) Then $text = StringLeft($text, StringInStr($text, @CRLF, 0, 4) - 2) & " ... "
	ConsoleWrite("Id: " & _UIA_GetPropertyValue($oUIElement, $UIA_AutomationIdPropertyId) & @CRLF)
	ConsoleWrite("Text: " & $text & @CRLF)
	ConsoleWrite("Class: " & _UIA_GetPropertyValue($oUIElement, $UIA_ClassNamePropertyId) & @CRLF)
	ConsoleWrite("Native handle: " & _UIA_GetPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId) & @CRLF)
	ConsoleWrite("Bounding box: " & _ArrayToString(_UIA_GetPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId), ", ") & @CRLF)
	ConsoleWrite(@CRLF)
EndFunc

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

	Local Static $hParent
	Local Static $hFrame[4]

	If Not $hParent Then
		$hParent = GUICreate("", 100, 100) ; Don't show this to avoid windows appearing in task bar
		For $n = 0 To 3
			$hFrame[$n] = GUICreate("", 100, 100, -1, -1, $WS_POPUP, -1, $hParent)
			GUISetBkColor($FrameColor, $hFrame[$n])
			WinSetTrans($hFrame[$n], "", $FrameAlpha)
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

	_ShowProperties($Element)

	WinMove($hFrame[0], "", $Pos[0], $Pos[1], $Thickness, $Pos[3]) ; Left
	WinMove($hFrame[1], "", $Pos[0], $Pos[1], $Pos[2], $Thickness) ; Top
	WinMove($hFrame[2], "", $Pos[0] + $Pos[2] - $Thickness, $Pos[1], $Thickness, $Pos[3]) ; Right
	WinMove($hFrame[3], "", $Pos[0], $Pos[1] + $Pos[3] - $Thickness, $Pos[2], $Thickness) ; Bottom

	For $n = 0 To 3
		GUISetState(@SW_SHOWNOACTIVATE, $hFrame[$n])
		WinSetOnTop($hFrame[$n], "", $WINDOWS_ONTOP)
	Next
EndFunc   ;==>_ShowFrame