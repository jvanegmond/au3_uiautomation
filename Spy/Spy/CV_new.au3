#include <Array.au3>
#include <ComboConstants.au3>
#include <Constants.au3>
#include <GDIPlus.au3>
#include <GUIComboBox.au3>
#include <GUIConstantsEx.au3>
#include <GUIEdit.au3>
#include <GUIImageList.au3>
#include <GUIListView.au3>
#include <GUIMenu.au3>
#include <GUITab.au3>
#include <HeaderConstants.au3>
#include <Math.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIMisc.au3>
#include <WinAPIProc.au3>
#include <WinAPIRes.au3>
#include <WinAPIShellEx.au3>
#include <WinAPISys.au3>
#include <WinAPITheme.au3>
#include <WindowsConstants.au3>
#include "ColorChooser.au3"
#include "..\..\UIAutomation.au3"

#cs
GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')
GUIRegisterMsg($WM_GETMINMAXINFO, 'WM_GETMINMAXINFO')
GUIRegisterMsg($WM_LBUTTONDBLCLK, 'WM_LBUTTONDBLCLK')
GUIRegisterMsg($WM_LBUTTONDOWN, 'WM_LBUTTONDOWN')
GUIRegisterMsg($WM_NOTIFY, 'WM_NOTIFY')
GUIRegisterMsg($WM_SETCURSOR, 'WM_SETCURSOR')
GUIRegisterMsg($WM_MOVE, 'WM_MOVE')
GUIRegisterMsg($WM_SIZE, 'WM_SIZE')
#ce

#cs
$Area = WinGetPos($hForm)
If IsArray($Area) Then
	$Area[3] = $Area[3] - $_Height + 568
EndIf
#ce

Sleep(1000)

Local $Pos[4] = [50, 50, 200, 200]

_ShowFrame(True, $Pos)

Sleep(1000)

Local $Pos[4] = [150, 150, 200, 200]

_ShowFrame(True, $Pos)

Sleep(1000)



Func _ShowFrame($fShow, $Pos = 0)
	Local Static $hFrame
	Local Static $hRect
	Local Const $FrameAlpha = 192
	Local Const $FrameColor = 0xFF0000

	If Not $hFrame Then
		_GDIPlus_Startup()
		$hFrame = GUICreate('', 100, 100, -1, -1, $WS_POPUP, $WS_EX_LAYERED)
	EndIf

	If Not $fShow Then
		GUISetState(@SW_HIDE, $hFrame)
		Return
	EndIf

	If $hRect Then
		_WinAPI_UpdateLayeredWindowEx($hFrame, -1, -1, $hRect, 0, 1)
	EndIf
	$hRect = 0

	If UBound($Pos) <> 4 Then
		GUISetState(@SW_HIDE, $hFrame)
		Return
	EndIf

	WinMove($hFrame, '', $Pos[0], $Pos[1], $Pos[2], $Pos[3])

	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($Pos[2], $Pos[3])
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	Local $hPen = _GDIPlus_PenCreate(BitOR(BitShift($FrameAlpha, -24), $FrameColor), 3)
	_GDIPlus_GraphicsDrawRect($hGraphics, 1, 1, _Max($Pos[2] - 3, 1), _Max($Pos[3] - 3, 1), $hPen)
	$hRect = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_PenDispose($hPen)

	If $hRect Then
		GUISetState(@SW_SHOWNOACTIVATE, $hFrame)
	Else
		GUISetState(@SW_HIDE, $hFrame)
		Return
	EndIf

	If Not _WinAPI_UpdateLayeredWindowEx($hFrame, -1, -1, $hRect, $FrameAlpha) Then
		; Nothing
	EndIf
EndFunc   ;==>_ShowFrame