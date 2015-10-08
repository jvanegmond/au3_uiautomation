#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.6.1
	Author:         Yashied

	Script Function:
	(Control Viewer v1.1) AutoIt Window Information Tool

#ce ----------------------------------------------------------------------------

#Region Resources

#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_UseUpx=N
#AutoIt3Wrapper_OutFile=CV.exe
#AutoIt3Wrapper_Icon=Resources\CV.ico
#AutoIt3Wrapper_Icon=Resources\CV.ico
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete %out%, %out%, Dialog, 1000,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete %out%, %out%, Icon, 162,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete %out%, %out%, Icon, 164,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete %out%, %out%, Icon, 169,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete %out%, %out%, Menu, 166,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete %out%, %out%, VersionInfo, 1,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", 24, 1,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -add %out%, %out%, Resources\CV.res,,,
;~#AutoIt3Wrapper_Run_After=Utilities\Upx.exe "%out%" --best --no-backup --overlay=copy --compress-exports=1 --compress-resources=0 --strip-relocs=1
#AutoIt3Wrapper_Run_After=del CV_Obfuscated.au3
#AutoIt3Wrapper_Run_After=del Utilities\ResHacker.ini
#AutoIt3Wrapper_Run_After=del Utilities\ResHacker.log
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion Resources

#Region Initialization

#NoTrayIcon

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
#include "..\..\..\UIAutomation.au3"

Opt('GUIResizeMode', BitOR($GUI_DOCKLEFT, $GUI_DOCKTOP, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))
Opt('MustDeclareVars', 1)
Opt('WinTitleMatchMode', 3)
Opt('WinWaitDelay', 0)

Global Const $Style[31][2] = _
		[[0x00000004, 'DS_3DLOOK'], _
		[0x00000001, 'DS_ABSALIGN'], _
		[0x00000800, 'DS_CENTER'], _
		[0x00001000, 'DS_CENTERMOUSE'], _
		[0x00002000, 'DS_CONTEXTHELP'], _
		[0x00000400, 'DS_CONTROL'], _
		[0x00000008, 'DS_FIXEDSYS'], _
		[0x00000020, 'DS_LOCALEDIT'], _
		[0x00000080, 'DS_MODALFRAME'], _
		[0x00000010, 'DS_NOFAILCREATE'], _
		[0x00000100, 'DS_NOIDLEMSG'], _
		[0x00000040, 'DS_SETFONT'], _
		[0x00000200, 'DS_SETFOREGROUND'], _
		[0x00000002, 'DS_SYSMODAL'], _
		[0x00800000, 'WS_BORDER'], _
		[0x00C00000, 'WS_CAPTION'], _
		[0x40000000, 'WS_CHILD'], _
		[0x02000000, 'WS_CLIPCHILDREN'], _
		[0x04000000, 'WS_CLIPSIBLINGS'], _
		[0x08000000, 'WS_DISABLED'], _
		[0x00400000, 'WS_DLGFRAME'], _
		[0x00020000, 'WS_GROUP'], _
		[0x00100000, 'WS_HSCROLL'], _
		[0x01000000, 'WS_MAXIMIZE'], _
		[0x20000000, 'WS_MINIMIZE'], _
		[0x80000000, 'WS_POPUP'], _
		[0x00040000, 'WS_SIZEBOX'], _
		[0x00080000, 'WS_SYSMENU'], _
		[0x00010000, 'WS_TABSTOP'], _
		[0x10000000, 'WS_VISIBLE'], _
		[0x00200000, 'WS_VSCROLL']]

Global Const $ExStyle[21][2] = _
		[[0x00000010, 'WS_EX_ACCEPTFILES'], _
		[0x00040000, 'WS_EX_APPWINDOW'], _
		[0x00000200, 'WS_EX_CLIENTEDGE'], _
		[0x02000000, 'WS_EX_COMPOSITED'], _
		[0x00000400, 'WS_EX_CONTEXTHELP'], _
		[0x00010000, 'WS_EX_CONTROLPARENT'], _
		[0x00000001, 'WS_EX_DLGMODALFRAME'], _
		[0x00080000, 'WS_EX_LAYERED'], _
		[0x00400000, 'WS_EX_LAYOUTRTL'], _
		[0x00004000, 'WS_EX_LEFTSCROLLBAR'], _
		[0x00000040, 'WS_EX_MDICHILD'], _
		[0x08000000, 'WS_EX_NOACTIVATE'], _
		[0x00100000, 'WS_EX_NOINHERITLAYOUT'], _
		[0x00000004, 'WS_EX_NOPARENTNOTIFY'], _
		[0x00001000, 'WS_EX_RIGHT'], _
		[0x00002000, 'WS_EX_RTLREADING'], _
		[0x00020000, 'WS_EX_STATICEDGE'], _
		[0x00000080, 'WS_EX_TOOLWINDOW'], _
		[0x00000008, 'WS_EX_TOPMOST'], _
		[0x00000020, 'WS_EX_TRANSPARENT'], _
		[0x00000100, 'WS_EX_WINDOWEDGE']]

Local Const $GUI_NAME = 'Control Viewer'
Local Const $GUI_VERSION = '1.1'
Local Const $GUI_UNIQUE = $GUI_NAME & '_CvrXp'

Global Const $REG_KEY_NAME = 'HKCU\Software\Y''s\' & $GUI_NAME

Local $_XPos = 8 ; ((-1) - Default)
Local $_YPos = 8 ; ((-1) - Default)
Local $_Width = 421
Local $_Height = 653
Local $_Top = 1 ; (0/1)
Local $_Position = 0 ; (0 - Absolute; 1 - Window; 2 - Client; 3 - Control)
Local $_Color = 0 ; (0 - RGB; 1 - BGR)
Local $_Crosshair = 1 ; (0/1)
Local $_Highlight = 1 ; (0/1)
Local $_Frame = 0xFF0000
Local $_Alpha = 192
Local $_Fade = 1 ; (0/1)
Local $_Code = 1 ; (0 - ANSI; 1 - Unicode; 2 - Unicode (Big Endian); 3 - UTF8)
Local $_Icon = 1 ; (0/1)
Local $_Tab = 0 ; (0 - Window; 1 - Control; 2 - Capture; 3 - AutoIt)
Local $_Rgb[3] = [0x000000, 0x9C9C9C, 0xE00000] ; (Visible, Hidden, Missing)
Local $_Column[11] = [98 + 48 * @AutoItX64, 176 - 48 * @AutoItX64, 38, 44, 124, 44, 82 + 48 * @AutoItX64, 124, 140, 60, 267] ; (Handle, Class, NN, ID | Process, PID, Handle, Class, Title, Version, Path)
Local $_Crop[2] = [349, 223] ; (Width, Height)
Local $_Capture = 0 ; (0/1)
Local $_All = 0 ; (0/1)
Local $ghGDIPDll = DllOpen("gdiplus.dll")

_ApplicationCheck()
_ReadRegistry()

Local $hWnd[2], $hForm, $hFrame, $hPopup = 0
Local $hPic[2], $hHeader[2], $hTab, $hAutoIt, $hListView, $hIL, $Combo[2], $Dummy[7], $Group, $Icon[2], $Input[31], $Label[5], $Menu[21], $Pic, $Tab
Local $Accel[5][2] = [['^a'], ['^d'], ['^!t'], ['^!h'], ['{ENTER}']]
Local $Col[2] = [0xFF000000, 0]
Local $hCursor[8], $hBitmap, $hAbout = 0, $hRoot = 0, $hOver = 0, $hPrev = 0, $hRect = 0, $hDesktop = 0
Local $Browser = False, $Ctrl = False, $Enum = False, $Fade = False, $Hold = False, $Refresh = False
Local $Count, $Data, $ID, $Item, $PrimaryMouseButton, $List, $Msg, $Alpha = 0, $Area = 0, $Resize = -1
Local $dX, $dY, $Xi, $Yi, $Xk, $Yk, $Xn, $Yn, $Xp, $Yp, $Ci, $Cp, $Wp, $Hp
Local $hFile, $hInstance = _WinAPI_GetModuleHandle(0)
Local $PathDlg = @WorkingDir
Local $tPoint, $tRect

If Not @Compiled Then
	For $i = 0 To 7
		$hCursor[$i] = _WinAPI_LoadCursorFromFile(@ScriptDir & '\..\Resources\' & (100 + $i) & '.cur')
	Next
Else
	For $i = 0 To 7
		$hCursor[$i] = _WinAPI_LoadCursor($hInstance, 100 + $i)
	Next
EndIf

If _WinAPI_IsThemeActive() Then
	$Col[0] = 0xFF3E60C5
	$Col[1] = 0x1E3E60C5
EndIf

If _WinAPI_GetSystemMetrics($SM_SWAPBUTTON) Then
	$PrimaryMouseButton = 0x02
Else
	$PrimaryMouseButton = 0x01
EndIf

_GDIPlus_Startup()
_GUICreate()

OnAutoItExitRegister('AutoItExit')

#EndRegion Initialization

#Region Body

While 1
	If (($hRoot) And (Not _WinAPI_IsWindowVisible($hRoot))) Then
		_ShowFrame(0)
		_Update(1)
		$hRoot = 0
		$hOver = 0
	EndIf
	If (($hOver) And (Not _WinAPI_IsWindowVisible($hOver))) Or (($hRect) And (Not WinActive($hForm))) Then
		_ShowFrame(0)
		$hOver = 0
	EndIf
	If _IsPressed(0x11) Then
		If Not $Ctrl Then
			_SendMessage($hForm, $WM_SETCURSOR)
		EndIf
		$Ctrl = 1
	Else
		If $Ctrl Then
			_SendMessage($hForm, $WM_SETCURSOR)
		EndIf
		$Ctrl = 0
	EndIf
	$Msg = GUIGetMsg()
	Switch $Msg
		Case 0
			ContinueLoop
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Icon[0]
			_ShowFrame(0)
			_WinAPI_SetFocus($hListView)
			If Not @Compiled Then
				GUICtrlSetImage($Icon[0], @ScriptDir & '\..\Resources\201.ico')
			Else
				GUICtrlSetImage($Icon[0], @ScriptFullPath, 201)
			EndIf
			$Browser = 1
			$Xp = -1
			$Yp = -1
			$Cp = -1
			$hRoot = 0
			$hOver = 0
			$hPrev = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, $IDI_APPLICATION))
			If $hPrev Then
				_WinAPI_SetSystemCursor($hCursor[0], $IDI_APPLICATION, 1)
			EndIf
			Opt('GUIOnEventMode', 1)
			GUISetState(@SW_DISABLE, $hForm)
			While _IsPressed($PrimaryMouseButton)
				$tPoint = _WinAPI_GetMousePos()
				$Xi = DllStructGetData($tPoint, 1)
				$Yi = DllStructGetData($tPoint, 2)

				; Capture image around the mouse region for display in the GUI (+color of pixel under mouse)
				If $Fade Then
					$Ci = -1
				EndIf
				If ($Xi <> $Xp) Or ($Yi <> $Yp) Or ($Ci <> $Cp) Then
					$hBitmap = _Capture_X3($Xi - 11, $Yi - 11, 23, 23, 69, 69)
					$Ci = @extended
					If $hBitmap Then
						If $Ci <> $Cp Then
							GUICtrlSetBkColor($Label[0], $Ci)
							Switch $_Color
								Case 0 ; RGB
									$Data = $Ci
								Case 1 ; BGR
									$Data = _WinAPI_SwitchColor($Ci)
							EndSwitch
							GUICtrlSetData($Input[2], '0x' & Hex($Data, 6))
						EndIf
					Else
						If $Ci <> $Cp Then
							GUICtrlSetBkColor($Label[0], _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
							GUICtrlSetData($Input[2], '')
						EndIf
					EndIf
					_SetBitmap($hPic[0], $hBitmap)
					If $_Capture Then
						_SetBitmap($hPic[1], _Capture_X1($Xi - Floor(($_Crop[0] - 10) / 2), $Yi - Floor(($_Crop[1] - 10) / 2), $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], 0, 1), 1)
						If BitAND(GUICtrlGetState($Label[4]), $GUI_SHOW) Then
							GUICtrlSetState($Label[4], $GUI_HIDE)
						EndIf
					EndIf
					$Xp = $Xi
					$Yp = $Yi
					$Cp = $Ci
				EndIf

				; Get element and window we are hovering over with our mouse
				Local $pos[] = [$Xi, $Yi]
				Local $oUIElement = _UIA_GetElementFromPoint($pos)
				$hWnd[0] = _WinAPI_GetAncestor(_WinAPI_WindowFromPoint($tPoint), $GA_ROOT)

				; Calculate coordinates for display in GUI
				Switch $_Position
					Case 0 ; Absolute
						For $i = 0 To 1
							_SetData($Input[$i], DllStructGetData($tPoint, $i + 1))
						Next
					Case 1, 2 ; Window, Client
						If ($hWnd[0] = $hForm) Or ($hWnd[0] = $hFrame) Then
							If _WinAPI_IsWindow($hRoot) Then
								$Data = $hRoot
							Else
								$Data = 0
							EndIf
						Else
							$Data = $hWnd[0]
						EndIf
						If $Data Then
							Switch $_Position
								Case 1 ; Window
									$tRect = _WinAPI_GetWindowRect($Data)
								Case 2 ; Client
									$tRect = _WinAPI_GetClientRect($Data)
									If _WinAPI_ScreenToClient($Data, $tRect) Then
										For $i = 1 To 2
											DllStructSetData($tRect, $i + 2, DllStructGetData($tRect, $i + 2) - DllStructGetData($tRect, $i))
											DllStructSetData($tRect, $i, -DllStructGetData($tRect, $i))
										Next
									Else
										$tRect = 0
									EndIf
							EndSwitch
						Else
							$tRect = 0
						EndIf
						If _PtInRect($tRect, $tPoint) Then
							For $i = 0 To 1
								_SetData($Input[$i], DllStructGetData($tPoint, $i + 1) - DllStructGetData($tRect, $i + 1))
							Next
						Else
							For $i = 0 To 1
								_SetData($Input[$i], '')
							Next
						EndIf
				EndSwitch

				If ($hWnd[0] = $hForm) Or ($hWnd[0] = $hFrame) Then
					If ($hOver) And (Not _WinAPI_IsWindowVisible($hOver)) Then
						If $hRect Then
							_ShowFrame(0)
						EndIf
						$Xp = -1
						$Yp = -1
						$Cp = -1
					EndIf
					ContinueLoop
				EndIf

				$hWnd[1] = 0
				$List = _WinAPI_EnumChildWindows($hWnd[0], 0)
				If @error Then
					$Count = 0
				Else
					$Count = $List[0][0]
					For $i = $Count To 1 Step -1
						If Not _WinAPI_IsWindowVisible($List[$i][0]) Then
							ContinueLoop
						EndIf
						$tRect = _WinAPI_GetWindowRect($List[$i][0])
						If _PtInRect($tRect, $tPoint) Then
							$hWnd[1] = $List[$i][0]
							ExitLoop
						EndIf
					Next
				EndIf
				Switch $_Position
					Case 0, 1, 2 ; Absolute, Window, Client

					Case 3 ; Control
						If $hWnd[1] Then
							For $i = 0 To 1
								_SetData($Input[$i], DllStructGetData($tPoint, $i + 1) - DllStructGetData($tRect, $i + 1))
							Next
						Else
							For $i = 0 To 1
								_SetData($Input[$i], '')
							Next
						EndIf
				EndSwitch

				Local $aBound = _UIA_GetPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId)
				$tRect = DllStructCreate($tagRECT)
				DllStructSetData($tRect, 1, $aBound[0])
				DllStructSetData($tRect, 2, $aBound[1])
				DllStructSetData($tRect, 3, $aBound[0] + $aBound[2])
				DllStructSetData($tRect, 4, $aBound[1] + $aBound[3])

				If ($hWnd[0] = $hRoot) And ($hWnd[1] = $hOver) Then
					ContinueLoop
				EndIf
				If ($hWnd[0] <> $hRoot) Then
					_SetWindowInfo($hWnd[0])
				EndIf
				_GUICtrlListView_BeginUpdate($hListView)
				If ($hWnd[0] = $hRoot) And (_GUICtrlListView_GetItemCount($hListView) = $Count) Then
					$Item = _GUICtrlListView_FindText($hListView, $hWnd[1], -1, 0)
				Else
					$Enum = 1
					_GUICtrlListView_DeleteAllItems($hListView)
					$Item = -1
					For $i = 1 To $Count
						_GUICtrlListView_AddItem($hListView, $List[$i][0])
						_GUICtrlListView_AddSubItem($hListView, $i - 1, $List[$i][1], 1)
						$ID = _WinAPI_GetDlgCtrlID($List[$i][0])
						If $ID > 0 Then
							_GUICtrlListView_AddSubItem($hListView, $i - 1, $ID, 3)
						EndIf
					Next
					For $i = 1 To $Count
						If ($List[$i][0] = $hWnd[1]) Then
							$Item = $i - 1
						EndIf
						If ($List[$i][1]) And (IsString($List[$i][1])) Then
							$ID = 1
							$Data = $List[$i][1]
							For $j = $i To UBound($List) - 1
								If $List[$j][1] = $Data Then
									$List[$j][1] = $ID
									$ID += 1
								EndIf
							Next
						EndIf
					Next
					For $i = 1 To $Count
						_GUICtrlListView_AddSubItem($hListView, $i - 1, $List[$i][1], 2)
						If _WinAPI_IsWindowVisible($List[$i][0]) Then
							_GUICtrlListView_SetItemChecked($hListView, $i - 1)
						EndIf
					Next
					$Enum = 0
				EndIf
				If $Item = -1 Then
					$Item = _GUICtrlListView_GetSelectedIndices($hListView)
					If $Item Then
						_GUICtrlListView_SetItemSelected($hListView, $Item, 0, 0)
						_GUICtrlListView_SetItemFocused($hListView, $Item, 0)
					EndIf
					_SetControlInfo(0)
				Else
					_GUICtrlListView_SetItemSelected($hListView, $Item, 1, 1)
					_GUICtrlListView_EnsureVisible($hListView, $Item, 1)
				EndIf
				_GUICtrlListView_EndUpdate($hListView)

				If $hWnd[1] Then
					_ShowFrame(1, $tRect, $hWnd[0])
				Else
					_ShowFrame(0)
				EndIf
				$hRoot = $hWnd[0]
				$hOver = $hWnd[1]
			WEnd
			If $hDesktop Then
				_WinAPI_DeleteObject($hDesktop)
			EndIf
			$hDesktop = _Capture_Desktop()
			If Not $_Capture Then
				_SetBitmap($hPic[1], _Capture_X1($Xp - Floor(($_Crop[0] - 10) / 2), $Yp - Floor(($_Crop[1] - 10) / 2), $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], 0, 1), 1)
				If BitAND(GUICtrlGetState($Label[4]), $GUI_SHOW) Then
					GUICtrlSetState($Label[4], $GUI_HIDE)
				EndIf
			EndIf
			_ShowFrame(0)
			If $hPrev Then
				_WinAPI_SetSystemCursor($hPrev, $IDI_APPLICATION, 1)
			EndIf
			$hPrev = 0
			$hOver = 0
			$Browser = 0
			If Not @Compiled Then
				GUICtrlSetImage($Icon[0], @ScriptDir & '\..\Resources\202.ico')
			Else
				GUICtrlSetImage($Icon[0], @ScriptFullPath, 202)
			EndIf
			GUISetState(@SW_ENABLE, $hForm)
			Opt('GUIOnEventMode', 0)
			WinActivate($hForm)
			If Not FileExists(GUICtrlRead($Input[15])) Then
				GUICtrlSetState($Icon[1], $GUI_DISABLE)
			Else
				GUICtrlSetState($Icon[1], $GUI_ENABLE)
			EndIf
			If Not $hRoot Then
				GUICtrlSetState($Menu[0], $GUI_DISABLE)
			Else
				GUICtrlSetState($Menu[0], $GUI_ENABLE)
			EndIf
		Case $Icon[1]
			$Data = GUICtrlRead($Input[15])
			If $Data Then
				_WinAPI_ShellOpenFolderAndSelectItems($Data)
			EndIf
		Case $Dummy[0]
			$Data = GUICtrlRead($Dummy[0])
			If Not _GUICtrlListView_GetSelectedIndices($hListView) Then
				_GUICtrlListView_SetItemSelected($hListView, $Data, 1, 1)
			EndIf
		Case $Dummy[1]
			$Data = GUICtrlRead($Dummy[1])
			$Data = Ptr(_GUICtrlListView_GetItemText($hListView, $Data))
			If ($Data) And (_WinAPI_IsWindow($Data)) Then
				_SetControlInfo($Data)
			EndIf
		Case $Dummy[2]
			If Not _GetCursor($Xi, $Yi, $hForm) Then
				ContinueLoop
			EndIf
			$ID = _IsCrop($Xi, $Yi, $dX, $dY)
			Switch $ID
				Case 0
					If (Not $hDesktop) Or (Not _IsPressed(0x11)) Then
						ContinueLoop
					EndIf
					$Xk = Default
					$Yk = Default
					$Xn = $Xp
					$Yn = $Yp
					$dX = $Xi
					$dY = $Yi
					$Resize = 2
				Case 1, 5
					$Resize = 3
				Case 2, 6
					$Resize = 4
				Case 3, 7
					$Resize = 5
				Case 4, 8
					$Resize = 6
				Case Else
					ContinueLoop
			EndSwitch
			$Wp = 0
			$Hp = 0
			Opt('GUIOnEventMode', 1)
			While _IsPressed($PrimaryMouseButton)
				If Not _GetCursor($Xi, $Yi, $hForm) Then
					ContinueLoop
				EndIf
				Switch $ID
					Case 0
						$Xp = $Xn - $Xi + $dX
						$Yp = $Yn - $Yi + $dY
					Case 1
						If $Xi - $dX < 38 Then
							$Xi = 38 + $dX
						EndIf
						If $Xi - $dX > 191 Then
							$Xi = 191 + $dX
						EndIf
						If $Yi - $dY < 173 Then
							$Yi = 173 + $dY
						EndIf
						If $Yi - $dY > 263 Then
							$Yi = 263 + $dY
						EndIf
						$_Crop[0] = 349 - 2 * ($Xi - $dX - 38)
						$_Crop[1] = 223 - 2 * ($Yi - $dY - 173)
					Case 2
						If $Yi - $dY < 173 Then
							$Yi = 173 + $dY
						EndIf
						If $Yi - $dY > 263 Then
							$Yi = 263 + $dY
						EndIf
						$_Crop[1] = 223 - 2 * ($Yi - $dY - 173)
					Case 3
						If $Xi - $dX < 229 Then
							$Xi = 229 + $dX
						EndIf
						If $Xi - $dX > 382 Then
							$Xi = 382 + $dX
						EndIf
						If $Yi - $dY < 173 Then
							$Yi = 173 + $dY
						EndIf
						If $Yi - $dY > 263 Then
							$Yi = 263 + $dY
						EndIf
						$_Crop[0] = 349 + 2 * ($Xi - $dX - 382)
						$_Crop[1] = 223 - 2 * ($Yi - $dY - 173)
					Case 4
						If $Xi - $dX < 229 Then
							$Xi = 229 + $dX
						EndIf
						If $Xi - $dX > 382 Then
							$Xi = 382 + $dX
						EndIf
						$_Crop[0] = 349 + 2 * ($Xi - $dX - 382)
					Case 5
						If $Xi - $dX < 229 Then
							$Xi = 229 + $dX
						EndIf
						If $Xi - $dX > 382 Then
							$Xi = 382 + $dX
						EndIf
						If $Yi - $dY < 301 Then
							$Yi = 301 + $dY
						EndIf
						If $Yi - $dY > 391 Then
							$Yi = 391 + $dY
						EndIf
						$_Crop[0] = 349 + 2 * ($Xi - $dX - 382)
						$_Crop[1] = 223 + 2 * ($Yi - $dY - 391)
					Case 6
						If $Yi - $dY < 301 Then
							$Yi = 301 + $dY
						EndIf
						If $Yi - $dY > 391 Then
							$Yi = 391 + $dY
						EndIf
						$_Crop[1] = 223 + 2 * ($Yi - $dY - 391)
					Case 7
						If $Xi - $dX < 38 Then
							$Xi = 38 + $dX
						EndIf
						If $Xi - $dX > 191 Then
							$Xi = 191 + $dX
						EndIf
						If $Yi - $dY < 301 Then
							$Yi = 301 + $dY
						EndIf
						If $Yi - $dY > 391 Then
							$Yi = 391 + $dY
						EndIf
						$_Crop[0] = 349 - 2 * ($Xi - $dX - 38)
						$_Crop[1] = 223 + 2 * ($Yi - $dY - 391)
					Case 8
						If $Xi - $dX < 38 Then
							$Xi = 38 + $dX
						EndIf
						If $Xi - $dX > 191 Then
							$Xi = 191 + $dX
						EndIf
						$_Crop[0] = 349 - 2 * ($Xi - $dX - 38)
				EndSwitch
				Switch $ID
					Case 0

					Case 1, 3, 5, 7
						If _IsPressed(0x10) Then
							If $_Crop[0] > $_Crop[1] Then
								$_Crop[0] = $_Crop[1]
							Else
								$_Crop[1] = $_Crop[0]
							EndIf
						EndIf
				EndSwitch
				If ($Xp <> $Xk) Or ($Yp <> $Yk) Or ($Wp <> $_Crop[0]) Or ($Hp <> $_Crop[1]) Then
					If $hDesktop Then
						$hBitmap = _Capture_X1($Xp - Floor(($_Crop[0] - 10) / 2), $Yp - Floor(($_Crop[1] - 10) / 2), $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], 0, 1, 0, $hDesktop)
					Else
						$hBitmap = _Capture_X1(0, 0, $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], $Col[1], 0, 0)
						If $_Crop[0] - 10 < 187 Then
							If BitAND(GUICtrlGetState($Label[4]), $GUI_SHOW) Then
								GUICtrlSetState($Label[4], $GUI_HIDE)
							EndIf
						Else
							If BitAND(GUICtrlGetState($Label[4]), $GUI_HIDE) Then
								GUICtrlSetState($Label[4], $GUI_SHOW)
							EndIf
						EndIf
					EndIf
					$tPoint = _WinAPI_CreatePoint(36 + Floor((349 - $_Crop[0]) / 2), 171 + Floor((223 - $_Crop[1]) / 2))
					_WinAPI_ClientToScreen($hForm, $tPoint)
					$Xi = DllStructGetData($tPoint, 1)
					$Yi = DllStructGetData($tPoint, 2)
					If Not $hPopup Then
						$hPopup = GUICreate('', 100, 100, $Xi, $Yi, BitOR($WS_DISABLED, $WS_POPUP), BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST), $hForm)
						GUISetState(@SW_SHOWNOACTIVATE, $hPopup)
						Switch $ID
							Case 0

							Case Else
								GUICtrlSetState($Pic, $GUI_HIDE)
						EndSwitch
					EndIf
					_WinAPI_UpdateLayeredWindowEx($hPopup, $Xi, $Yi, $hBitmap, 255, 1)
					$Wp = $_Crop[0]
					$Hp = $_Crop[1]
					$Xk = $Xp
					$Yk = $Yp
				EndIf
			WEnd
			Opt('GUIOnEventMode', 0)
			GUICtrlSetPos($Pic, 36 + Floor((349 - $_Crop[0]) / 2), 171 + Floor((223 - $_Crop[1]) / 2), $_Crop[0], $_Crop[1])
			If $hDesktop Then
				_SetBitmap($hPic[1], _Capture_X1($Xp - Floor(($_Crop[0] - 10) / 2), $Yp - Floor(($_Crop[1] - 10) / 2), $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], 0, 1, 0, $hDesktop), 1)
			Else
				_SetBitmap($hPic[1], _Capture_X1(0, 0, $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], $Col[1]), 1)
			EndIf
			Switch $ID
				Case 0

				Case Else
					GUICtrlSetState($Pic, $GUI_SHOW)
			EndSwitch
			GUIDelete($hPopup)
			$hPopup = 0
			$Resize = -1
			_SendMessage($hForm, $WM_SETCURSOR)
		Case $Dummy[3]
			If Not _ShellSaveDlg($hForm) Then
				MsgBox(16, $GUI_NAME, 'Unable to save image.', 0, $hForm)
			EndIf
		Case $Dummy[4]
			$Data = _GUICtrlListView_GetSelectedIndices($hAutoIt)
			If $Data Then
				$Data = _GUICtrlListView_GetItemText($hAutoIt, $Data, 6)
				If $Data Then
					_WinAPI_ShellOpenFolderAndSelectItems($Data)
				EndIf
			EndIf
		Case $Dummy[5]
			$Data = _GUICtrlListView_GetSelectedIndices($hAutoIt)
			If $Data Then
				$Data = _GUICtrlListView_GetItemText($hAutoIt, $Data, 1)
				If $Data Then
					If _ShellKillProcess($Data, $hForm) Then
						_SetAutoItInfo()
					EndIf
				EndIf
			EndIf
		Case $Dummy[6]
			_SetAutoItInfo()
		Case $Combo[0]
			$Data = _GUICtrlComboBox_GetCurSel($Combo[0])
			If $Data <> $_Position Then
				$_Position = $Data
				For $i = 0 To 1
					GUICtrlSetData($Input[$i], '')
				Next
			EndIf
		Case $Combo[1]
			$Data = _GUICtrlComboBox_GetCurSel($Combo[1])
			If $Data <> $_Color Then
				$_Color = $Data
				$Data = GUICtrlRead($Input[2])
				If $Data Then
					GUICtrlSetData($Input[2], '0x' & Hex(_WinAPI_SwitchColor(Number($Data)), 6))
				EndIf
			EndIf
		Case $Label[1]
			$Data = _ColorChooserDialog($_Rgb[0], $hForm, 0, 0, BitOR($CC_FLAG_SOLIDCOLOR, $CC_FLAG_CAPTURECOLOR))
			If ($Data <> -1) And ($Data <> $_Rgb[0]) Then
				$_Rgb[0] = $Data
				GUICtrlSetBkColor($Label[1], $Data)
				_WinAPI_InvalidateRect($hListView)
				If $_Tab = 3 Then
					_WinAPI_InvalidateRect($hAutoIt)
				EndIf
			EndIf
		Case $Label[2]
			$Data = _ColorChooserDialog($_Rgb[1], $hForm, 0, 0, BitOR($CC_FLAG_SOLIDCOLOR, $CC_FLAG_CAPTURECOLOR))
			If ($Data <> -1) And ($Data <> $_Rgb[1]) Then
				$_Rgb[1] = $Data
				GUICtrlSetBkColor($Label[2], $Data)
				_WinAPI_InvalidateRect($hListView)
				If $_Tab = 3 Then
					_WinAPI_InvalidateRect($hAutoIt)
				EndIf
			EndIf
		Case $Label[3]
			$Data = _ColorChooserDialog($_Rgb[2], $hForm, 0, 0, BitOR($CC_FLAG_SOLIDCOLOR, $CC_FLAG_CAPTURECOLOR))
			If ($Data <> -1) And ($Data <> $_Rgb[2]) Then
				$_Rgb[2] = $Data
				GUICtrlSetBkColor($Label[3], $Data)
				_WinAPI_InvalidateRect($hListView)
				If $_Tab = 3 Then
					_WinAPI_InvalidateRect($hAutoIt)
				EndIf
			EndIf
		Case $Menu[1] ; "Copy To Clipboard"
			$Data = _CreateReport()
			If $Data Then
				ClipPut($Data)
			EndIf
		Case $Menu[2] ; "Save As..."
			If Not _ShellReportDlg($hForm) Then
				MsgBox(16, $GUI_NAME, 'Unable to save report.', 0, $hForm)
			EndIf
		Case $Menu[3] ; "Exit"
			Exit
		Case $Menu[4] ; "Always On Top"
			$_Top = Not $_Top
			If $_Top Then
				GUICtrlSetState($Menu[4], $GUI_CHECKED)
			Else
				GUICtrlSetState($Menu[4], $GUI_UNCHECKED)
			EndIf
			WinSetOnTop($hForm, '', $_Top)
		Case $Menu[5] ; "Crosshair"
			$_Crosshair = Not $_Crosshair
			If $_Crosshair Then
				GUICtrlSetState($Menu[5], $GUI_CHECKED)
			Else
				GUICtrlSetState($Menu[5], $GUI_UNCHECKED)
			EndIf
			GUICtrlSetBkColor($Label[0], _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
			GUICtrlSetData($Input[2], '')
			_SetBitmap($hPic[0], 0)
		Case $Menu[6] ; "Capture While Tracking"
			$_Capture = Not $_Capture
			If $_Capture Then
				GUICtrlSetState($Menu[6], $GUI_CHECKED)
			Else
				GUICtrlSetState($Menu[6], $GUI_UNCHECKED)
			EndIf
		Case $Menu[20]
			$_All = Not $_All
			If $_All Then
				GUICtrlSetState($Menu[20], $GUI_CHECKED)
			Else
				GUICtrlSetState($Menu[20], $GUI_UNCHECKED)
			EndIf
			_SetAutoItInfo()
		Case $Menu[7], $Menu[8], $Menu[9], $Menu[10] ; "ANSI", "Unicode", "Unicode (Big Endian)", "UTF8"
			If BitAND(GUICtrlRead($Msg), $GUI_CHECKED) Then
				ContinueLoop
			EndIf
			_SetData($Input[30], '')
			For $i = 7 To 10
				GUICtrlSetState($Menu[$i], $GUI_UNCHECKED)
			Next
			Switch $Msg
				Case $Menu[7]
					$_Code = 0
				Case $Menu[8]
					$_Code = 1
				Case $Menu[9]
					$_Code = 2
				Case $Menu[10]
					$_Code = 3
			EndSwitch
			GUICtrlSetState($Msg, $GUI_CHECKED)
		Case $Menu[8] ; "Unicode"
			_SetData($Input[30], '')
			$_Code = 1
		Case $Menu[9] ; "Unicode (Big Endian)"
			_SetData($Input[30], '')
			$_Code = 2
		Case $Menu[10] ; "UTF8"
			_SetData($Input[30], '')
			$_Code = 3
		Case $Menu[11] ; "Highlight Controls"
			_ShowFrame(0)
			$_Highlight = Not $_Highlight
			If $_Highlight Then
				GUICtrlSetState($Menu[11], $GUI_CHECKED)
				GUICtrlSetState($Menu[12], $GUI_ENABLE)
				GUICtrlSetState($Menu[17], $GUI_ENABLE)
				GUICtrlSetState($Menu[18], $GUI_ENABLE)
			Else
				GUICtrlSetState($Menu[11], $GUI_UNCHECKED)
				GUICtrlSetState($Menu[12], $GUI_DISABLE)
				GUICtrlSetState($Menu[17], $GUI_DISABLE)
				GUICtrlSetState($Menu[18], $GUI_DISABLE)
			EndIf
		Case $Menu[13], $Menu[14], $Menu[15], $Menu[16] ; "25%", "50%", 75%", "100%"
			If BitAND(GUICtrlRead($Msg), $GUI_CHECKED) Then
				ContinueLoop
			EndIf
			_ShowFrame(0)
			For $i = 13 To 16
				GUICtrlSetState($Menu[$i], $GUI_UNCHECKED)
			Next
			Switch $Msg
				Case $Menu[13]
					$_Alpha = 64
				Case $Menu[14]
					$_Alpha = 128
				Case $Menu[15]
					$_Alpha = 192
				Case $Menu[16]
					$_Alpha = 255
			EndSwitch
			GUICtrlSetState($Msg, $GUI_CHECKED)
		Case $Menu[17] ; "Fade In"
			$_Fade = Not $_Fade
			If $_Fade Then
				GUICtrlSetState($Menu[17], $GUI_CHECKED)
			Else
				GUICtrlSetState($Menu[17], $GUI_UNCHECKED)
			EndIf
		Case $Menu[18] ; "Color..."
			_ShowFrame(0)
			$Data = _ColorChooserDialog($_Frame, $hForm, 0, 0, BitOR($CC_FLAG_SOLIDCOLOR, $CC_FLAG_CAPTURECOLOR))
			If ($Data <> -1) And ($Data <> $_Frame) Then
				$_Frame = $Data
			EndIf
		Case $Menu[19] ; "About..."
			_ShellAboutDlg($hForm)
		Case $Accel[0][1] ; Ctrl+A
			_HK_SelectAll()
		Case $Accel[2][1] ; Ctrl+Alt+T
			_SendMessage($hForm, $WM_COMMAND, $Menu[4], 0)
		Case $Accel[3][1] ; Ctrl+Alt+H
			_SendMessage($hForm, $WM_COMMAND, $Menu[11], 0)
		Case $Accel[4][1]
			_HK_Edit()
		Case $Tab
			GUICtrlSetState($Tab, $GUI_FOCUS)
	EndSwitch
WEnd

#EndRegion Body

#Region Additional Functions

Func _About()
	ConsoleWrite('@@ (911) :(' & @MIN & ':' & @SEC & ') _About()' & @CR) ;### Function Trace
	If Not RegRead($REG_KEY_NAME, 'About') Then
		RegWrite($REG_KEY_NAME, 'About', 'REG_DWORD', 1)
		_ShellAboutDlg()
	EndIf
EndFunc   ;==>_About

Func _ApplicationCheck()
	ConsoleWrite('@@ (919) :(' & @MIN & ':' & @SEC & ') _ApplicationCheck()' & @CR) ;### Function Trace
	Local $hWnd = WinGetHandle($GUI_UNIQUE)

	If Not $hWnd Then
		AutoItWinSetTitle($GUI_UNIQUE)
		Return
	EndIf

	Local $PID, $List

	$PID = WinGetProcess($hWnd)
	If $PID > -1 Then
		$List = _WinAPI_EnumProcessWindows($PID, 0)
		If Not IsArray($List) Then
			Exit
		EndIf
	EndIf
	For $i = 1 To $List[0][0]
		If WinGetTitle($List[$i][0]) = $GUI_NAME & ChrW(160) Then
			If BitAND(WinGetState($List[$i][0]), 4) Then
				WinActivate($List[$i][0])
			Else
				For $j = 1 To $List[0][0]
					If (WinGetTitle($List[$j][0])) And (_WinAPI_GetAncestor($List[$j][0], $GA_ROOTOWNER) = $List[$i][0]) Then
						WinActivate($List[$j][0])
						ExitLoop
					EndIf
				Next
			EndIf
			ExitLoop
		EndIf
	Next
	Exit
EndFunc   ;==>_ApplicationCheck

Func _Capture_X1($iX, $iY, $iWidth, $iHeight, $iColCrop, $iColFill = 0, $fCapture = 0, $fDib = 1, $hDesktop = 0)
	ConsoleWrite('@@ (955) :(' & @MIN & ':' & @SEC & ') _Capture_X1()' & @CR) ;### Function Trace
	Local $W = $iWidth + 10, $H = $iHeight + 10, $Xc = Floor($W / 2), $Yc = Floor($H / 2)

	Local $hBitmap, $hScreen
	If $fCapture Then
		If $hDesktop Then
			Local $hDC = _WinAPI_GetDC(0)
			Local $hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
			_WinAPI_SelectObject($hSrcDC, $hDesktop)
			Local $hDstDC = _WinAPI_CreateCompatibleDC($hDC)
			$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
			_WinAPI_SelectObject($hDstDC, $hBitmap)
			_WinAPI_BitBlt($hDstDC, 0, 0, $iWidth, $iHeight, $hSrcDC, $iX, $iY, $SRCCOPY)
			_WinAPI_ReleaseDC(0, $hDC)
			_WinAPI_DeleteDC($hSrcDC)
			_WinAPI_DeleteDC($hDstDC)
		Else
			$hDesktop = _WinAPI_GetDesktopWindow()
			Local $hDC = _WinAPI_GetDC($hDesktop)
			Local $hDstDC = _WinAPI_CreateCompatibleDC($hDC)
			$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
			_WinAPI_SelectObject($hDstDC, $hBitmap)
			_WinAPI_BitBlt($hDstDC, 0, 0, $iWidth, $iHeight, $hDC, $iX, $iY, $SRCCOPY)
			Local $hBrush = _WinAPI_CreateSolidBrush(0)
			$tRect = _WinAPI_GetWindowRect($hPic[0])
			_WinAPI_OffsetRect($tRect, -$iX, -$iY)
			_WinAPI_FillRect($hDstDC, DllStructGetPtr($tRect), $hBrush)
			If $_Tab = 2 Then
				$tRect = _WinAPI_GetWindowRect($hPic[1])
				_WinAPI_OffsetRect($tRect, -$iX, -$iY)
				_WinAPI_FillRect($hDstDC, DllStructGetPtr($tRect), $hBrush)
			EndIf
			_WinAPI_DeleteObject($hBrush)
			_WinAPI_ReleaseDC($hDesktop, $hDC)
			_WinAPI_DeleteDC($hDstDC)
		EndIf
		$hScreen = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
		_WinAPI_DeleteObject($hBitmap)
	EndIf
	$hBitmap = _GDIPlus_BitmapCreateFromScan0($W, $H)
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	Local $hPen = _GDIPlus_PenCreate($iColCrop)
	_GDIPlus_GraphicsDrawRect($hGraphics, 0, 0, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, $Xc - 2, 0, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, $W - 5, 0, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, $W - 5, $Yc - 2, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, $W - 5, $H - 5, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, $Xc - 2, $H - 5, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, 0, $H - 5, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawRect($hGraphics, 0, $Yc - 2, 4, 4, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, 5, 2, $Xc - 3, 2, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, $Xc + 3, 2, $W - 6, 2, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, $W - 3, 5, $W - 3, $Yc - 3, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, $W - 3, $Yc + 3, $W - 3, $H - 6, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, $W - 6, $H - 3, $Xc + 3, $H - 3, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, $Xc - 3, $H - 3, 5, $H - 3, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, 2, $H - 6, 2, $Yc + 3, $hPen)
	_GDIPlus_GraphicsDrawLine($hGraphics, 2, $Yc - 3, 2, 5, $hPen)
	_GDIPlus_PenDispose($hPen)
	If $fCapture Then
		_GDIPlus_GraphicsDrawImageRect($hGraphics, $hScreen, 5, 5, $iWidth, $iHeight)
		_GDIPlus_ImageDispose($hScreen)
	Else
		If $iColFill Then
			Local $hBrush = _GDIPlus_BrushCreateSolid($iColFill)
			_GDIPlus_GraphicsFillRect($hGraphics, 5, 5, $iWidth, $iHeight, $hBrush)
			_GDIPlus_BrushDispose($hBrush)
		EndIf
	EndIf
	_GDIPlus_GraphicsDispose($hGraphics)

	Local $hCrop
	If $fDib Then
		Local $tData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $W, $H, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
		$hCrop = _WinAPI_CreateDIB($W, $H)
		_WinAPI_SetBitmapBits($hCrop, $W * $H * 4, DllStructGetData($tData, 'Scan0'))
		_GDIPlus_BitmapUnlockBits($hBitmap, $tData)
	Else
		$hCrop = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
	EndIf
	_GDIPlus_ImageDispose($hBitmap)
	If $hCrop Then
		Return SetError(0, 0, $hCrop)
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_Capture_X1

Func _Capture_X3($iX, $iY, $iSrcWidth, $iSrcHeight, $iDstWidth, $iDstHeight)
	ConsoleWrite('@@ (1044) :(' & @MIN & ':' & @SEC & ') _Capture_X3()' & @CR) ;### Function Trace
	Local $hPen = 0, $Xc = Floor($iDstWidth / 2), $Yc = Floor($iDstHeight / 2)

	Local $hDesktop = _WinAPI_GetDesktopWindow()
	Local $hDC = _WinAPI_GetDC($hDesktop)
	Local $hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hScreen = _WinAPI_CreateCompatibleBitmap($hDC, $iSrcWidth, $iSrcHeight)
	_WinAPI_SelectObject($hSrcDC, $hScreen)
	_WinAPI_BitBlt($hSrcDC, 0, 0, $iSrcWidth, $iSrcHeight, $hDC, $iX, $iY, $SRCCOPY)
	Local $hBrush = _WinAPI_CreateSolidBrush(0)
	Local $tRect = _WinAPI_GetWindowRect($hPic[0])
	_WinAPI_OffsetRect($tRect, -$iX, -$iY)
	_WinAPI_FillRect($hSrcDC, DllStructGetPtr($tRect), $hBrush)
	If $_Tab = 2 Then
		$tRect = _WinAPI_GetWindowRect($hPic[1])
		_WinAPI_OffsetRect($tRect, -$iX, -$iY)
		_WinAPI_FillRect($hSrcDC, DllStructGetPtr($tRect), $hBrush)
	EndIf
	_WinAPI_DeleteObject($hBrush)
	Local $hDstDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $iDstWidth, $iDstHeight)
	_WinAPI_SelectObject($hDstDC, $hBitmap)
	_WinAPI_SetStretchBltMode($hDstDC, $STRETCH_DELETESCANS)
	_WinAPI_StretchBlt($hDstDC, 0, 0, $iDstWidth, $iDstHeight, $hSrcDC, 0, 0, $iSrcWidth, $iSrcHeight, $SRCCOPY)
	_WinAPI_ReleaseDC($hDesktop, $hDC)
	_WinAPI_DeleteDC($hDstDC)
	_WinAPI_DeleteDC($hSrcDC)
	_WinAPI_DeleteObject($hScreen)
	Local $hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	_WinAPI_DeleteObject($hBitmap)
	Local $Rgb = BitAND(_GDIPlus_BitmapGetPixel($hImage, $Xc, $Yc), 0x00FFFFFF)
	If $_Crosshair Then
		For $y = $Yc - 3 To $Yc + 3 Step 3
			For $x = $Xc - 3 To $Xc + 3 Step 3
				If (($Xc <> $x) Or ($Yc <> $y)) And (Not _IsDark(_GDIPlus_BitmapGetPixel($hImage, $x, $y))) Then
					$hPen = _GDIPlus_PenCreate()
					ExitLoop 2
				EndIf
			Next
		Next
		If Not $hPen Then
			$hPen = _GDIPlus_PenCreate(0xFFFFFFFF)
		EndIf
		Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hImage)
		_GDIPlus_GraphicsDrawLine($hGraphics, 0, $Yc, $Xc - 3, $Yc, $hPen)
		_GDIPlus_GraphicsDrawLine($hGraphics, $Xc + 3, $Yc, $iDstWidth, $Yc, $hPen)
		_GDIPlus_GraphicsDrawLine($hGraphics, $Xc, 0, $Xc, $Yc - 3, $hPen)
		_GDIPlus_GraphicsDrawLine($hGraphics, $Xc, $Yc + 3, $Xc, $iDstHeight, $hPen)
		_GDIPlus_GraphicsDrawRect($hGraphics, $Xc - 2, $Yc - 2, 4, 4, $hPen)
		_GDIPlus_PenDispose($hPen)
		_GDIPlus_GraphicsDispose($hGraphics)
	EndIf
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	_GDIPlus_ImageDispose($hImage)
	If $hBitmap Then
		Return SetError(0, $Rgb, $hBitmap)
	Else
		Return SetError(1, -1, 0)
	EndIf
EndFunc   ;==>_Capture_X3

Func _Capture_Desktop()
	ConsoleWrite('@@ (1106) :(' & @MIN & ':' & @SEC & ') _Capture_Desktop()' & @CR) ;### Function Trace
	Local $hDesktop = _WinAPI_GetDesktopWindow()
	Local $hDC = _WinAPI_GetDC($hDesktop)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, @DesktopWidth, @DesktopHeight)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_BitBlt($hMemDC, 0, 0, @DesktopWidth, @DesktopHeight, $hDC, 0, 0, $SRCCOPY)
	Local $hBrush = _WinAPI_CreateSolidBrush(0)
	Local $tRect = _WinAPI_GetWindowRect($hPic[0])
	_WinAPI_FillRect($hMemDC, DllStructGetPtr($tRect), $hBrush)
	If $_Tab = 2 Then
		$tRect = _WinAPI_GetWindowRect($hPic[1])
		_WinAPI_FillRect($hMemDC, DllStructGetPtr($tRect), $hBrush)
	EndIf
	_WinAPI_DeleteObject($hBrush)
	_WinAPI_ReleaseDC($hDesktop, $hDC)
	_WinAPI_DeleteDC($hMemDC)
	If $hBitmap Then
		Return SetError(0, 0, $hBitmap)
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_Capture_Desktop

Func _CreateReport()
	ConsoleWrite('@@ (1131) :(' & @MIN & ':' & @SEC & ') _CreateReport()' & @CR) ;### Function Trace
	Local $Data[2], $Text = ''

	$Text &= '###AutoIt Control Viewer Report File###' & @CRLF
	$Text &= @CRLF
	$Text &= 'Environment' & @CRLF
	$Text &= '===========' & @CRLF
	$Text &= StringStripWS('System:   ' & _OSVersion(), 2) & @CRLF
	$Text &= 'Aero:     '
	If _WinAPI_GetVersion() >= 6.0 Then
		If _WinAPI_DwmIsCompositionEnabled() Then
			$Text &= 'Enabled'
		Else
			$Text &= 'Disabled'
		EndIf
	EndIf
	$Text &= @CRLF
	$Text &= @CRLF
	$Text &= 'Window' & @CRLF
	$Text &= '======' & @CRLF
	$Text &= StringStripWS('Title:    ' & GUICtrlRead($Input[3]), 2) & @CRLF
	$Text &= StringStripWS('Class:    ' & GUICtrlRead($Input[4]), 2) & @CRLF
	$Text &= StringStripWS('Style:    ' & GUICtrlRead($Input[5]), 2) & @CRLF
	$Text &= StringStripWS('ExStyle:  ' & GUICtrlRead($Input[7]), 2) & @CRLF
	$Text &= 'Position: '
	For $i = 0 To 1
		$Data[$i] = GUICtrlRead($Input[9 + $i])
	Next
	If ($Data[0]) And ($Data[1]) Then
		$Text &= $Data[0] & ', ' & $Data[1]
	EndIf
	$Text = StringStripWS($Text, 2)
	$Text &= @CRLF
	$Text &= 'Size:     '
	For $i = 0 To 1
		$Data[$i] = GUICtrlRead($Input[11 + $i])
	Next
	If ($Data[0]) And ($Data[1]) Then
		$Text &= $Data[0] & ', ' & $Data[1]
	EndIf
	$Text = StringStripWS($Text, 2)
	$Text &= @CRLF
	$Text &= StringStripWS('Handle:   ' & GUICtrlRead($Input[13]), 2) & @CRLF
	$Text &= StringStripWS('PID:      ' & GUICtrlRead($Input[14]), 2) & @CRLF
	$Text &= StringStripWS('Path:     ' & GUICtrlRead($Input[15]), 2) & @CRLF
	$Text &= @CRLF
	$Text &= 'Control' & @CRLF
	$Text &= '=======' & @CRLF
	$Text &= StringStripWS('Class:    ' & GUICtrlRead($Input[16]), 2) & @CRLF
	$Text &= StringStripWS('Instance: ' & GUICtrlRead($Input[17]), 2) & @CRLF
	$Text &= StringStripWS('ID:       ' & GUICtrlRead($Input[19]), 2) & @CRLF
	$Text &= StringStripWS('Style:    ' & GUICtrlRead($Input[21]), 2) & @CRLF
	$Text &= StringStripWS('ExStyle:  ' & GUICtrlRead($Input[23]), 2) & @CRLF
	$Text &= 'Position: '
	For $i = 0 To 1
		$Data[$i] = GUICtrlRead($Input[25 + $i])
	Next
	If ($Data[0]) And ($Data[1]) Then
		$Text &= $Data[0] & ', ' & $Data[1]
	EndIf
	$Text = StringStripWS($Text, 2)
	$Text &= @CRLF
	$Text &= 'Size:     '
	For $i = 0 To 1
		$Data[$i] = GUICtrlRead($Input[27 + $i])
	Next
	If ($Data[0]) And ($Data[1]) Then
		$Text &= $Data[0] & ', ' & $Data[1]
	EndIf
	$Text = StringStripWS($Text, 2)
	$Text &= @CRLF
	$Text &= StringStripWS('Handle:   ' & GUICtrlRead($Input[29]), 2) & @CRLF
	$Text &= StringStripWS('Text:     ' & GUICtrlRead($Input[30]), 2) & @CRLF

	Return $Text
EndFunc   ;==>_CreateReport

Func _GetCursor(ByRef $iX, ByRef $iY, $hWnd = 0)
	ConsoleWrite('@@ (1209) :(' & @MIN & ':' & @SEC & ') _GetCursor()' & @CR) ;### Function Trace
	Local $tPoint = _WinAPI_GetMousePos($hWnd, $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	$iX = DllStructGetData($tPoint, 1)
	$iY = DllStructGetData($tPoint, 2)

	Return 1
EndFunc   ;==>_GetCursor

Func _GetNN($hWnd)
	ConsoleWrite('@@ (1223) :(' & @MIN & ':' & @SEC & ') _GetNN()' & @CR) ;### Function Trace
	Local $ID = 0

	Local $Text = _WinAPI_GetClassName($hWnd)
	If Not $Text Then
		Return -1
	EndIf

	Local $List = _WinAPI_EnumChildWindows(_WinAPI_GetAncestor($hWnd, $GA_ROOT), 0)
	If @error Then
		Return -1
	EndIf

	For $i = 1 To $List[0][0]
		If $List[$i][1] = $Text Then
			$ID += 1
		EndIf
		If $List[$i][0] = $hWnd Then
			ExitLoop
		EndIf
	Next

	If Not $ID Then
		Return -1
	EndIf

	Return $ID
EndFunc   ;==>_GetNN

Func _GetStyleString($iStyle, $fDialog = 1, $fExStyle = 0)
	ConsoleWrite('@@ (1253) :(' & @MIN & ':' & @SEC & ') _GetStyleString()' & @CR) ;### Function Trace
	Local $Data, $Text = ''

	If $fExStyle Then
		$Data = $ExStyle
	Else
		$Data = $Style
	EndIf

	For $i = 0 To UBound($Data) - 1
		If BitAND($iStyle, $Data[$i][0]) Then
			If (Not BitAND($Data[$i][0], 0xFFFF)) Or ($fDialog) Or ($fExStyle) Then
				$iStyle = BitAND($iStyle, BitNOT($Data[$i][0]))
				$Text &= $Data[$i][1] & ', '
			EndIf
		EndIf
	Next

	If $iStyle Then
		$Text = '0x' & Hex($iStyle, 8) & ', ' & $Text
	EndIf

	Return StringRegExpReplace($Text, ',\s\z', '')
EndFunc   ;==>_GetStyleString

Func _GUICreate()
	ConsoleWrite('@@ (1279) :(' & @MIN & ':' & @SEC & ') _GUICreate()' & @CR) ;### Function Trace
	Local $Style = BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY, $WS_TABSTOP)
	Local $ID, $tData, $hIcon, $hImageList
	Local $Height = $_Height - 653

	; Main Window
	$hForm = GUICreate($GUI_NAME & ChrW(160), $_Width, $_Height + _WinAPI_GetSystemMetrics($SM_CYMENU), $_XPos, $_YPos, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX), $WS_EX_TOPMOST * $_Top)

	; Menu
	$ID = GUICtrlCreateMenu('&File')
	$Menu[0] = GUICtrlCreateMenu('&Report', $ID)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$Menu[1] = GUICtrlCreateMenuItem('&Copy To Clipboard', $Menu[0])
	$Menu[2] = GUICtrlCreateMenuItem('Save &As...', $Menu[0])
	GUICtrlCreateMenuItem('', $ID)
	$Menu[3] = GUICtrlCreateMenuItem('E&xit', $ID)
	$ID = GUICtrlCreateMenu('&Options')
	$Menu[4] = GUICtrlCreateMenuItem('&Always On Top' & @TAB & 'Ctrl+Alt+T', $ID)
	If $_Top Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlCreateMenuItem('', $ID)
	$Menu[5] = GUICtrlCreateMenuItem('C&rosshair', $ID)
	If $_Crosshair Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	$Menu[6] = GUICtrlCreateMenuItem('Capture While &Tracking', $ID)
	If $_Capture Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlCreateMenuItem('', $ID)
	$Menu[20] = GUICtrlCreateMenuItem('Show All', $ID)
	If $_All Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlCreateMenuItem('', $ID)
	$Menu[10] = GUICtrlCreateMenu('Text &Encoding', $ID)
	$Menu[7] = GUICtrlCreateMenuItem('ANSI', $Menu[10], Default, 1)
	$Menu[8] = GUICtrlCreateMenuItem('Unicode', $Menu[10], Default, 1)
	$Menu[9] = GUICtrlCreateMenuItem('Unicode (Big Endian)', $Menu[10], Default, 1)
	$Menu[10] = GUICtrlCreateMenuItem('UTF8', $Menu[10], Default, 1)
	Switch $_Code
		Case 0
			GUICtrlSetState($Menu[7], $GUI_CHECKED)
		Case 1
			GUICtrlSetState($Menu[8], $GUI_CHECKED)
		Case 2
			GUICtrlSetState($Menu[9], $GUI_CHECKED)
		Case 3
			GUICtrlSetState($Menu[10], $GUI_CHECKED)
	EndSwitch
	$Menu[18] = GUICtrlCreateMenu('&Highlight', $ID)
	$Menu[11] = GUICtrlCreateMenuItem('&Highlight Controls' & @TAB & 'Ctrl+Alt+H', $Menu[18])
	If $_Highlight Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlCreateMenuItem('', $Menu[18])
	$Menu[12] = GUICtrlCreateMenu('&Transparency', $Menu[18])
	If $_Highlight Then
		GUICtrlSetState(-1, $GUI_ENABLE)
	Else
		GUICtrlSetState(-1, $GUI_DISABLE)
	EndIf
	$Menu[13] = GUICtrlCreateMenuItem('25%', $Menu[12], Default, 1)
	$Menu[14] = GUICtrlCreateMenuItem('50%', $Menu[12], Default, 1)
	$Menu[15] = GUICtrlCreateMenuItem('75%', $Menu[12], Default, 1)
	$Menu[16] = GUICtrlCreateMenuItem('100%', $Menu[12], Default, 1)
	Switch $_Alpha
		Case 64
			GUICtrlSetState($Menu[13], $GUI_CHECKED)
		Case 128
			GUICtrlSetState($Menu[14], $GUI_CHECKED)
		Case 192
			GUICtrlSetState($Menu[15], $GUI_CHECKED)
		Case 255
			GUICtrlSetState($Menu[16], $GUI_CHECKED)
	EndSwitch
	$Menu[17] = GUICtrlCreateMenuItem('&Fade In', $Menu[18])
	If $_Highlight Then
		GUICtrlSetState(-1, BitOR($GUI_CHECKED * $_Fade, $GUI_UNCHECKED * (Not $_Fade), $GUI_ENABLE))
	Else
		GUICtrlSetState(-1, BitOR($GUI_CHECKED * $_Fade, $GUI_UNCHECKED * (Not $_Fade), $GUI_DISABLE))
	EndIf
	$Menu[18] = GUICtrlCreateMenuItem('&Color...', $Menu[18])
	If $_Highlight Then
		GUICtrlSetState(-1, $GUI_ENABLE)
	Else
		GUICtrlSetState(-1, $GUI_DISABLE)
	EndIf
	$ID = GUICtrlCreateMenu('&Help')
	$Menu[19] = GUICtrlCreateMenuItem('&About...', $ID)

	For $i = 0 To UBound($Dummy) - 1
		$Dummy[$i] = GUICtrlCreateDummy()
	Next

	; Color Picker Group
	GUICtrlCreateGroup('Color Picker', 10, 7, 293, 104)
	GUICtrlCreatePic('', 22, 28, 71, 71, BitOR($GUI_SS_DEFAULT_PIC, $SS_SUNKEN))
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreatePic('', 23, 29, 69, 69)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$hPic[0] = GUICtrlGetHandle(-1)
	GUICtrlCreateLabel('X, Y:', 103, 32, 29, 14)
	$Input[0] = GUICtrlCreateInput('', 133, 29, 36, 19, $Style)
	$Input[1] = GUICtrlCreateInput('', 177, 29, 36, 19, $Style)
	$Combo[0] = GUICtrlCreateCombo('', 223, 28, 68, 21, $CBS_DROPDOWNLIST)
	_GUICtrlComboBox_AddString(-1, 'Absolute')
	_GUICtrlComboBox_AddString(-1, 'Window')
	_GUICtrlComboBox_AddString(-1, 'Client')
	_GUICtrlComboBox_AddString(-1, 'Control')
	_GUICtrlComboBox_SetCurSel(-1, $_Position)
	GUICtrlCreateLabel('Color:', 103, 57, 29, 14)
	$Input[2] = GUICtrlCreateInput('', 133, 54, 80, 19, $Style)
	$Combo[1] = GUICtrlCreateCombo('', 223, 53, 50, 21, $CBS_DROPDOWNLIST)
	_GUICtrlComboBox_AddString(-1, 'RGB')
	_GUICtrlComboBox_AddString(-1, 'BGR')
	_GUICtrlComboBox_SetCurSel(-1, $_Color)
	GUICtrlCreateLabel('Solid:', 103, 82, 29, 14)
	$Label[0] = GUICtrlCreateLabel('', 133, 79, 19, 19, $SS_SUNKEN)

	; Browse Tool Group
	GUICtrlCreateGroup('Browse Tool', 313, 7, 98, 104)
	$Icon[0] = GUICtrlCreateIcon('', 0, 330, 30, 64, 64)
	_SetStyle(-1, $WS_TABSTOP, 0)
	If Not @Compiled Then
		GUICtrlSetImage(-1, @ScriptDir & '\..\Resources\202.ico')
	Else
		GUICtrlSetImage(-1, @ScriptFullPath, 202)
	EndIf

	; Info Group
	If $_Icon Then
		$Tab = GUICtrlCreateTab(22, 136, 379, 273)
		_GUICtrlTab_SetMinTabWidth(-1, 75)
	Else
		$Tab = GUICtrlCreateTab(22, 136, 379, 273, BitOR($GUI_SS_DEFAULT_TAB, $TCS_FIXEDWIDTH))
		_GUICtrlTab_SetItemSize(-1, 64, 19)
	EndIf
	GUICtrlSetState(-1, $GUI_FOCUS)
	$hTab = GUICtrlGetHandle(-1)

	GUICtrlCreateTabItem('Window')
	GUICtrlCreateLabel('Title:', 33, 176, 46, 14)
	$Input[3] = GUICtrlCreateInput('', 80, 173, 308, 19, $Style)
	GUICtrlCreateLabel('Class:', 33, 201, 46, 14)
	$Input[4] = GUICtrlCreateInput('', 80, 198, 308, 19, $Style)
	GUICtrlCreateLabel('Style:', 33, 226, 46, 14)
	$Input[5] = GUICtrlCreateInput('', 80, 223, 80, 19, $Style)
	$Input[6] = GUICtrlCreateInput('', 168, 223, 220, 19, $Style)
	GUICtrlCreateLabel('ExStyle:', 33, 251, 46, 14)
	$Input[7] = GUICtrlCreateInput('', 80, 248, 80, 19, $Style)
	$Input[8] = GUICtrlCreateInput('', 168, 248, 220, 19, $Style)
	GUICtrlCreateLabel('Position:', 33, 276, 46, 14)
	$Input[9] = GUICtrlCreateInput('', 80, 273, 80, 19, $Style)
	$Input[10] = GUICtrlCreateInput('', 168, 273, 80, 19, $Style)
	GUICtrlCreateLabel('Size:', 33, 301, 46, 14)
	$Input[11] = GUICtrlCreateInput('', 80, 298, 80, 19, $Style)
	$Input[12] = GUICtrlCreateInput('', 168, 298, 80, 19, $Style)
	GUICtrlCreateLabel('Handle:', 33, 326, 46, 14)
	$Input[13] = GUICtrlCreateInput('', 80, 323, 168, 19, $Style)
	GUICtrlCreateLabel('PID:', 33, 351, 46, 14)
	$Input[14] = GUICtrlCreateInput('', 80, 348, 80, 19, $Style)
	GUICtrlCreateLabel('Path:', 33, 376, 46, 14)
	$Input[15] = GUICtrlCreateInput('', 80, 373, 289, 19, $Style)
	$Icon[1] = GUICtrlCreateIcon('', 0, 373, 375, 15, 15)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, 'Open file location')
	GUICtrlSetCursor(-1, 0)
	_SetStyle(-1, $WS_TABSTOP, 0)
	If Not @Compiled Then
		GUICtrlSetImage(-1, @ScriptDir & '\..\Resources\210.ico')
	Else
		GUICtrlSetImage(-1, @ScriptFullPath, 210)
	EndIf

	GUICtrlCreateTabItem('Control')
	GUICtrlCreateLabel('Class:', 33, 176, 46, 14)
	$Input[16] = GUICtrlCreateInput('', 80, 173, 308, 19, $Style)
	GUICtrlCreateLabel('Instance:', 33, 201, 46, 14)
	$Input[17] = GUICtrlCreateInput('', 80, 198, 80, 19, $Style)
	$Input[18] = GUICtrlCreateInput('', 168, 198, 220, 19, $Style)
	GUICtrlCreateLabel('ID:', 33, 226, 42, 14)
	$Input[19] = GUICtrlCreateInput('', 80, 223, 80, 19, $Style)
	$Input[20] = GUICtrlCreateInput('', 168, 223, 220, 19, $Style)
	GUICtrlCreateLabel('Style:', 33, 251, 42, 14)
	$Input[21] = GUICtrlCreateInput('', 80, 248, 80, 19, $Style)
	$Input[22] = GUICtrlCreateInput('', 168, 248, 220, 19, $Style)
	GUICtrlCreateLabel('ExStyle:', 33, 276, 42, 14)
	$Input[23] = GUICtrlCreateInput('', 80, 273, 80, 19, $Style)
	$Input[24] = GUICtrlCreateInput('', 168, 273, 220, 19, $Style)
	GUICtrlCreateLabel('Position:', 33, 301, 42, 14)
	$Input[25] = GUICtrlCreateInput('', 80, 298, 80, 19, $Style)
	$Input[26] = GUICtrlCreateInput('', 168, 298, 80, 19, $Style)
	GUICtrlCreateLabel('Size:', 33, 326, 42, 14)
	$Input[27] = GUICtrlCreateInput('', 80, 323, 80, 19, $Style)
	$Input[28] = GUICtrlCreateInput('', 168, 323, 80, 19, $Style)
	GUICtrlCreateLabel('Handle:', 33, 351, 42, 14)
	$Input[29] = GUICtrlCreateInput('', 80, 348, 168, 19, $Style)
	GUICtrlCreateLabel('Text:', 33, 376, 42, 14)
	$Input[30] = GUICtrlCreateInput('', 80, 373, 308, 19, $Style)

	GUICtrlCreateTabItem('Capture')
	$Pic = GUICtrlCreatePic('', 36 + Floor((349 - $_Crop[0]) / 2), 171 + Floor((223 - $_Crop[1]) / 2), $_Crop[0], $_Crop[1], 0)
	$hPic[1] = GUICtrlGetHandle(-1)
	_SetBitmap($hPic[1], _Capture_X1(0, 0, $_Crop[0] - 10, $_Crop[1] - 10, $Col[0], $Col[1]), 1)
	$Label[4] = GUICtrlCreateLabel('Double click on the picture to save it', 117, 276, 187, 14, $SS_CENTER)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, BitAND($Col[0], 0xFFFFFF))
	If $_Crop[0] - 10 < 187 Then
		GUICtrlSetState(-1, $GUI_HIDE)
	EndIf

	GUICtrlCreateTabItem('AutoIt')
	GUICtrlCreateListView('Process|PID|Handle|Class|Title|Version|Path', 36, 171, 349, 223, BitOR($LVS_DEFAULT, $LVS_NOSORTHEADER), $WS_EX_CLIENTEDGE)
	GUICtrlSetFont(-1, 8.5, 400, 0, 'Tahoma')
	$hAutoIt = GUICtrlGetHandle(-1)
	_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_FULLROWSELECT))
	For $i = 4 To 10
		_GUICtrlListView_SetColumnWidth(-1, $i - 4, $_Column[$i])
	Next
	$hIL = _GUIImageList_Create(16, 16, 5, 1)
	If _WinAPI_GetVersion() >= '6.0' Then
		_WinAPI_SetWindowTheme($hAutoIt, 'Explorer')
		$tData = _WinAPI_ShellGetStockIconInfo($SIID_APPLICATION, BitOR($SHGSI_ICON, $SHGSI_SMALLICON))
		$hIcon = DllStructGetData($tData, 'hIcon')
	Else
		$hIcon = _WinAPI_ExtractIcon(@SystemDir & '\shell32.dll', 2, 1)
	EndIf
	_GUIImageList_ReplaceIcon($hIL, -1, $hIcon)
	$hIcon = _WinAPI_AddIconTransparency($hIcon, 50, 1)
	_GUIImageList_ReplaceIcon($hIL, -1, $hIcon)
	_WinAPI_DestroyIcon($hIcon)
	If Not @Compiled Then
		$hIcon = _WinAPI_ExtractIcon(@ScriptDir & '\..\Resources\214.ico', 0, 1)
	Else
		$hIcon = _WinAPI_ExtractIcon(@ScriptFullPath, -214, 1)
	EndIf
	_GUIImageList_ReplaceIcon($hIL, -1, $hIcon)
	$hIcon = _WinAPI_AddIconTransparency($hIcon, 50, 1)
	_GUIImageList_ReplaceIcon($hIL, -1, $hIcon)
	_WinAPI_DestroyIcon($hIcon)
	_GUICtrlListView_SetImageList($hAutoIt, $hIL, 1)
	$hHeader[1] = _GUICtrlListView_GetHeader(-1)

	GUICtrlCreateTabItem('')

	If _WinAPI_IsThemeActive() Then
		For $i = 3 To 30
			GUICtrlSetBkColor($Input[$i], 0xFFFFFF)
		Next
		GUICtrlSetColor($Input[6], 0xAA0000)
		GUICtrlSetColor($Input[8], 0xAA0000)
		GUICtrlSetColor($Input[18], 0x9999CC)
		GUICtrlSetColor($Input[20], 0x9999CC)
		GUICtrlSetColor($Input[22], 0xAA0000)
		GUICtrlSetColor($Input[24], 0xAA0000)
	EndIf

	If $_Icon Then
		$hImageList = _GUIImageList_Create(16, 16, 5, 1)
		If Not @Compiled Then
			For $i = 203 To 206
				_GUIImageList_AddIcon($hImageList, @ScriptDir & '\..\Resources\' & $i & '.ico')
			Next
		Else
			For $i = 203 To 206
				_GUIImageList_AddIcon($hImageList, @ScriptFullPath, -$i)
			Next
		EndIf
		_GUICtrlTab_SetImageList($hTab, $hImageList)
		For $i = 0 To 3
			_GUICtrlTab_SetItemImage($hTab, $i, $i)
		Next
	EndIf

	GUICtrlCreateGroup('Info', 10, 115, 401, 305)

	; Controls Group
	$Group = GUICtrlCreateGroup('Controls', 10, 424, 401, 219 + $Height)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKTOP, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH))
	GUICtrlCreateListView('Handle|Class|NN|ID', 22, 445, 377, 164 + $Height, BitOR($LVS_DEFAULT, $LVS_NOSORTHEADER), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKTOP, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH))
	GUICtrlSetFont(-1, 8.5, 400, 0, 'Tahoma')
	$hListView = GUICtrlGetHandle(-1)
	_GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER, $LVS_EX_FULLROWSELECT))
	For $i = 0 To 3
		_GUICtrlListView_SetColumnWidth(-1, $i, $_Column[$i])
	Next
	If _WinAPI_GetVersion() >= '6.0' Then
		_WinAPI_SetWindowTheme($hListView, 'Explorer')
	EndIf
	$hHeader[0] = _GUICtrlListView_GetHeader(-1)
	$Label[1] = GUICtrlCreateLabel('', 22, 619 + $Height, 12, 12, BitOR($SS_NOTIFY, $SS_SUNKEN))
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))
	GUICtrlSetBkColor(-1, $_Rgb[0])
	GUICtrlSetTip(-1, 'Change color')
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel('Visible', 38, 618 + $Height, 42, 14)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))
	$Label[2] = GUICtrlCreateLabel('', 92, 619 + $Height, 12, 12, BitOR($SS_NOTIFY, $SS_SUNKEN))
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))
	GUICtrlSetBkColor(-1, $_Rgb[1])
	GUICtrlSetTip(-1, 'Change color')
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel('Hidden', 108, 618 + $Height, 42, 14)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))
	$Label[3] = GUICtrlCreateLabel('', 162, 619 + $Height, 12, 12, BitOR($SS_NOTIFY, $SS_SUNKEN))
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))
	GUICtrlSetBkColor(-1, $_Rgb[2])
	GUICtrlSetTip(-1, 'Change color')
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel('Missing', 178, 618 + $Height, 42, 14)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT))

	For $i = 0 To UBound($Accel) - 1
		$Accel[$i][1] = GUICtrlCreateDummy()
	Next

	GUISetAccelerators($Accel)

	; Frame Window
	$hFrame = GUICreate('', 100, 100, -1, -1, $WS_POPUP, $WS_EX_LAYERED, WinGetHandle($GUI_UNIQUE))

	GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')
	GUIRegisterMsg($WM_GETMINMAXINFO, 'WM_GETMINMAXINFO')
	GUIRegisterMsg($WM_LBUTTONDBLCLK, 'WM_LBUTTONDBLCLK')
	GUIRegisterMsg($WM_LBUTTONDOWN, 'WM_LBUTTONDOWN')
	GUIRegisterMsg($WM_NOTIFY, 'WM_NOTIFY')
	GUIRegisterMsg($WM_SETCURSOR, 'WM_SETCURSOR')
	GUIRegisterMsg($WM_MOVE, 'WM_MOVE')
	GUIRegisterMsg($WM_SIZE, 'WM_SIZE')

	$Area = WinGetPos($hForm)
	If IsArray($Area) Then
		$Area[3] = $Area[3] - $_Height + 568
	EndIf

	GUISetState(@SW_SHOW, $hForm)

	GUISwitch($hForm)

	$Enum = 1

	_GUICtrlTab_SetCurFocus($hTab, $_Tab)

	$Enum = 0

	If $_Tab = 3 Then
		_SetAutoItInfo()
	EndIf

EndFunc   ;==>_GUICreate

Func _HWnd($CtrlID)
	ConsoleWrite('@@ (1634) :(' & @MIN & ':' & @SEC & ') _HWnd()' & @CR) ;### Function Trace
	If Not IsHWnd($CtrlID) Then
		$CtrlID = GUICtrlGetHandle($CtrlID)
		If Not $CtrlID Then
			Return 0
		EndIf
	EndIf

	Return $CtrlID
EndFunc   ;==>_HWnd

Func _IsCrop($iX, $iY, ByRef $iDX, ByRef $iDY)
	ConsoleWrite('@@ (1646) :(' & @MIN & ':' & @SEC & ') _IsCrop()' & @CR) ;### Function Trace
	Local $Xn = 36 + Floor((349 - $_Crop[0]) / 2)
	Local $Yn = 171 + Floor((223 - $_Crop[1]) / 2)
	Local $Xc = Floor($_Crop[0] / 2)
	Local $Yc = Floor($_Crop[1] / 2)

	Select
		Case ($iX > $Xn + 4) And ($iX < $Xn + $_Crop[0] - 5) And ($iY > $Yn + 4) And ($iY < $Yn + $_Crop[1] - 5)
			Return 0
		Case ($iX > $Xn - 1) And ($iX < $Xn + 5) And ($iY > $Yn - 1) And ($iY < $Yn + 5)
			$iDX = $Xi - $Xn - 2
			$iDY = $Yi - $Yn - 2
			Return 1
		Case ($iX > $Xn + $Xc - 3) And ($iX < $Xn + $Xc + 3) And ($iY > $Yn - 1) And ($iY < $Yn + 5)
			$iDX = $Xi - $Xn - $Xc
			$iDY = $Yi - $Yn - 2
			Return 2
		Case ($iX > $Xn + $_Crop[0] - 6) And ($iX < $Xn + $_Crop[0]) And ($iY > $Yn - 1) And ($iY < $Yn + 5)
			$iDX = $Xi - $Xn - $_Crop[0] + 3
			$iDY = $Yi - $Yn - 2
			Return 3
		Case ($iX > $Xn + $_Crop[0] - 6) And ($iX < $Xn + $_Crop[0]) And ($iY > $Yn + $Yc - 3) And ($iY < $Yn + $Yc + 3)
			$iDX = $Xi - $Xn - $_Crop[0] + 3
			$iDY = $Yi - $Yn - $Yc
			Return 4
		Case ($iX > $Xn + $_Crop[0] - 6) And ($iX < $Xn + $_Crop[0]) And ($iY > $Yn + $_Crop[1] - 6) And ($iY < $Yn + $_Crop[1])
			$iDX = $Xi - $Xn - $_Crop[0] + 3
			$iDY = $Yi - $Yn - $_Crop[1] + 3
			Return 5
		Case ($iX > $Xn + $Xc - 3) And ($iX < $Xn + $Xc + 3) And ($iY > $Yn + $_Crop[1] - 6) And ($iY < $Yn + $_Crop[1])
			$iDX = $Xi - $Xn - $Xc
			$iDY = $Yi - $Yn - $_Crop[1] + 3
			Return 6
		Case ($iX > $Xn - 1) And ($iX < $Xn + 5) And ($iY > $Yn + $_Crop[1] - 6) And ($iY < $Yn + $_Crop[1])
			$iDX = $Xi - $Xn - 2
			$iDY = $Yi - $Yn - $_Crop[1] + 3
			Return 7
		Case ($iX > $Xn - 1) And ($iX < $Xn + 5) And ($iY > $Yn + $Yc - 3) And ($iY < $Yn + $Yc + 3)
			$iDX = $Xi - $Xn - 2
			$iDY = $Yi - $Yn - $Yc
			Return 8
		Case Else
			Return -1
	EndSelect
EndFunc   ;==>_IsCrop

Func _IsDark($iRgb)
	ConsoleWrite('@@ (1693) :(' & @MIN & ':' & @SEC & ') _IsDark()' & @CR) ;### Function Trace
	If CC_GetRValue($iRgb) + CC_GetGValue($iRgb) + CC_GetBValue($iRgb) < 3 * 255 / 2 Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_IsDark

Func _LoadResourceImage($hInstance, $sResType, $sResName, $iResLanguage = 0)
	ConsoleWrite('@@ (1702) :(' & @MIN & ':' & @SEC & ') _LoadResourceImage()' & @CR) ;### Function Trace
	Local $hInfo
	If $iResLanguage Then
		$hInfo = _WinAPI_FindResourceEx($hInstance, $sResType, $sResName, $iResLanguage)
	Else
		$hInfo = _WinAPI_FindResource($hInstance, $sResType, $sResName)
	EndIf

	Local $hData = _WinAPI_LoadResource($hInstance, $hInfo)
	Local $iSize = _WinAPI_SizeOfResource($hInstance, $hInfo)
	Local $pData = _WinAPI_LockResource($hData)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hMem = DllCall("kernel32.dll", "ptr", "GlobalAlloc", "uint", 2, "ulong_ptr", $iSize)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $pMem = DllCall("kernel32.dll", "ptr", "GlobalLock", "ptr", $hMem[0])
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	DllCall("kernel32.dll", "none", "RtlMoveMemory", "ptr", $pMem[0], "ptr", $pData, "ulong_ptr", $iSize)
	DllCall("kernel32.dll", "int", "GlobalUnlock", "ptr", $hMem[0])
	Local $hStream = _WinAPI_CreateStreamOnHGlobal($hMem[0])
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	_GDIPlus_Startup()
	Local $hImage = DllCall("gdiplus.dll", "uint", "GdipCreateBitmapFromStream", "ptr", $hStream, "ptr*", 0)
	If (@error) Or ($hImage[0]) Or (Not $hImage[2]) Then
		$hImage = 0
	EndIf

	_GDIPlus_Shutdown()
	DllCall("kernel32.dll", "ptr", "GlobalFree", "ptr", $hMem[0])
	If Not IsArray($hImage) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $hImage[2]
EndFunc   ;==>_LoadResourceImage

Func _OSVersion()
	ConsoleWrite('@@ (1750) :(' & @MIN & ':' & @SEC & ') _OSVersion()' & @CR) ;### Function Trace
	Local $oService = ObjGet('winmgmts:\\.\root\cimv2')
	If Not IsObj($oService) Then
		Return ''
	EndIf

	Local $oItems = $oService.ExecQuery('SELECT Caption, OSArchitecture FROM Win32_OperatingSystem')
	If Not IsObj($oItems) Then
		Return ''
	EndIf

	Local $Version = ''
	For $Property In $oItems
		$Version = StringStripWS($Property.Caption & ' ' & $Property.OSArchitecture, 7)
	Next
	Return $Version
EndFunc   ;==>_OSVersion

Func _PtInRect($tRect, $tPoint)
	ConsoleWrite('@@ (1769) :(' & @MIN & ':' & @SEC & ') _PtInRect()' & @CR) ;### Function Trace
	Local $Ret = DllCall('user32.dll', 'int', 'PtInRect', 'ptr', DllStructGetPtr($tRect), 'uint64', DllStructGetData(DllStructCreate('uint64', DllStructGetPtr($tPoint)), 1))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_PtInRect

Func _ReadRegistry()
	ConsoleWrite('@@ (1779) :(' & @MIN & ':' & @SEC & ') _ReadRegistry()' & @CR) ;### Function Trace
	$_XPos = _WinAPI_DWordToInt(_RegRead($REG_KEY_NAME, 'XPos', 'REG_DWORD', $_XPos))
	$_YPos = _WinAPI_DWordToInt(_RegRead($REG_KEY_NAME, 'YPos', 'REG_DWORD', $_YPos))
	$_Height = _ValueCheck(_RegRead($REG_KEY_NAME, 'ClientHeight', 'REG_DWORD', $_Height), 552)
	$_Top = _ValueCheck(_RegRead($REG_KEY_NAME, 'AlwaysOnTop', 'REG_DWORD', $_Top), 0, 1)
	$_Position = _ValueCheck(_RegRead($REG_KEY_NAME, 'CoordinateMode', 'REG_DWORD', $_Position), 0, 3)
	$_Color = _ValueCheck(_RegRead($REG_KEY_NAME, 'ColorMode', 'REG_DWORD', $_Color), 0, 1)
	$_Crosshair = _ValueCheck(_RegRead($REG_KEY_NAME, 'Crosshair', 'REG_DWORD', $_Crosshair), 0, 1)
	$_Highlight = _ValueCheck(_RegRead($REG_KEY_NAME, 'Highlight', 'REG_DWORD', $_Highlight), 0, 1)
	$_Frame = BitAND(_RegRead($REG_KEY_NAME, 'HighlightColor', 'REG_DWORD', $_Frame), 0x00FFFFFF)
	$_Alpha = _ValueCheck(_RegRead($REG_KEY_NAME, 'HighlightTransparency', 'REG_DWORD', $_Alpha), 0, 255)
	$_Fade = _ValueCheck(_RegRead($REG_KEY_NAME, 'HighlightFadeIn', 'REG_DWORD', $_Fade), 0, 1)
	$_Code = _ValueCheck(_RegRead($REG_KEY_NAME, 'Encoding', 'REG_DWORD', $_Code), 0, 3)
	$_Icon = _ValueCheck(_RegRead($REG_KEY_NAME, 'TabIcon', 'REG_DWORD', $_Icon), 0, 1)
	$_Tab = _ValueCheck(_RegRead($REG_KEY_NAME, 'Tab', 'REG_DWORD', $_Tab), 0, 3)
	$_Rgb[0] = BitAND(_RegRead($REG_KEY_NAME, 'ControlVisibleColor', 'REG_DWORD', $_Rgb[0]), 0x00FFFFFF)
	$_Rgb[1] = BitAND(_RegRead($REG_KEY_NAME, 'ControlHiddenColor', 'REG_DWORD', $_Rgb[1]), 0x00FFFFFF)
	$_Rgb[2] = BitAND(_RegRead($REG_KEY_NAME, 'ControlMissingColor', 'REG_DWORD', $_Rgb[2]), 0x00FFFFFF)
	$_Column[0] = _RegRead($REG_KEY_NAME, 'ColumnControlHandle', 'REG_DWORD', $_Column[0])
	$_Column[1] = _RegRead($REG_KEY_NAME, 'ColumnControlClass', 'REG_DWORD', $_Column[1])
	$_Column[2] = _RegRead($REG_KEY_NAME, 'ColumnControlNN', 'REG_DWORD', $_Column[2])
	$_Column[3] = _RegRead($REG_KEY_NAME, 'ColumnControlID', 'REG_DWORD', $_Column[3])
	$_Column[4] = _RegRead($REG_KEY_NAME, 'ColumnAutoItProcess', 'REG_DWORD', $_Column[4])
	$_Column[5] = _RegRead($REG_KEY_NAME, 'ColumnAutoItPID', 'REG_DWORD', $_Column[5])
	$_Column[6] = _RegRead($REG_KEY_NAME, 'ColumnAutoItHandle', 'REG_DWORD', $_Column[6])
	$_Column[7] = _RegRead($REG_KEY_NAME, 'ColumnAutoItClass', 'REG_DWORD', $_Column[7])
	$_Column[8] = _RegRead($REG_KEY_NAME, 'ColumnAutoItTitle', 'REG_DWORD', $_Column[8])
	$_Column[9] = _RegRead($REG_KEY_NAME, 'ColumnAutoItVersion', 'REG_DWORD', $_Column[9])
	$_Column[10] = _RegRead($REG_KEY_NAME, 'ColumnAutoItPath', 'REG_DWORD', $_Column[10])
	$_Crop[0] = _ValueCheck(_RegRead($REG_KEY_NAME, 'CaptureWidth', 'REG_DWORD', $_Crop[0]), 43, 349)
	$_Crop[1] = _ValueCheck(_RegRead($REG_KEY_NAME, 'CaptureHeight', 'REG_DWORD', $_Crop[0]), 43, 223)
	$_Capture = _ValueCheck(_RegRead($REG_KEY_NAME, 'LiveCapture', 'REG_DWORD', $_Capture), 0, 1)
	$_All = _ValueCheck(_RegRead($REG_KEY_NAME, 'AutoItVisible', 'REG_DWORD', $_All), 0, 1)
	For $i = 0 To 1
		If Not Mod($_Crop[$i], 2) Then
			$_Crop[$i] -= 1
		EndIf
	Next
EndFunc   ;==>_ReadRegistry

Func _RegRead($sKey, $sValue, $sType, $sDefault)
	ConsoleWrite('@@ (1820) :(' & @MIN & ':' & @SEC & ') _RegRead()' & @CR) ;### Function Trace
	Local $Val, $Error = 0

	$Val = RegRead($sKey, $sValue)
	If @error Then
		Switch @error
			Case -1, 1
				RegWrite($sKey, $sValue, $sType, $sDefault)
			Case Else

		EndSwitch
		Return SetError(@error, 0, $sDefault)
	EndIf
	Switch $sType
		Case 'REG_SZ', 'REG_MULTI_SZ', 'REG_EXPAND_SZ'
			If Not IsString($Val) Then
				$Error = -3
			EndIf
		Case 'REG_BINARY'
			If Not IsBinary($Val) Then
				$Error = -3
			EndIf
		Case 'REG_DWORD'
			If Not IsInt($Val) Then
				$Error = -3
			EndIf
		Case Else
			$Error = -2
	EndSwitch
	If $Error Then
		Return SetError($Error, 0, $sDefault)
	Else
		Return $Val
	EndIf
EndFunc   ;==>_RegRead

Func _SCAW()
	ConsoleWrite('@@ (1857) :(' & @MIN & ':' & @SEC & ') _SCAW()' & @CR) ;### Function Trace
	Local $tState = _WinAPI_GetKeyboardState()

	For $i = 0x5B To 0x5C
		If BitAND(DllStructGetData($tState, 1, $i + 1), 0xF0) Then
			Return 1
		EndIf
	Next
	For $i = 0xA0 To 0xA5
		If BitAND(DllStructGetData($tState, 1, $i + 1), 0xF0) Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_SCAW

Func _SetAutoItInfo()
	ConsoleWrite('@@ (1874) :(' & @MIN & ':' & @SEC & ') _SetAutoItInfo()' & @CR) ;### Function Trace
	Local $Data[101][6] = [[0]]

	_GUICtrlListView_BeginUpdate($hAutoIt)
	_GUICtrlListView_DeleteAllItems($hAutoIt)
	_GUIImageList_SetImageCount($hIL, 4)
	Local $List = WinList()
	If IsArray($List) Then
		Local $Flag = 0, $Index = 0
		For $i = 0 To $List[0][0]
			$ID = WinGetProcess($List[$i][1])
			If ($ID <> -1) And ($ID <> @AutoItPID) And (StringInStr(_WinAPI_GetClassName($List[$i][1]), 'AutoIt v3')) And (_ArraySearch($Data, $ID, 1) = -1) Then
				Local $Path = _WinAPI_GetProcessFileName($ID)
				If Not $Path Then
					ContinueLoop
				EndIf
				Local $Name = _WinAPI_GetProcessName($ID)
				If Not $Name Then
					ContinueLoop
				EndIf
				Local $File = ''
				Local $Version = ''
				If ($Name = 'AutoIt3.exe') And (FileGetVersion($Path, 'ProductName') = 'AutoIt v3 Script') Then
					Local $Argv = _WinAPI_CommandLineToArgv(_WinAPI_GetProcessCommandLine($ID))
					For $i = 1 To UBound($Argv) - 1
						If StringLeft($Argv[$i], 1) <> '/' Then
							If _WinAPI_PathIsRelative($Argv[$i]) Then
								$File = _WinAPI_PathSearchAndQualify(_WinAPI_GetProcessWorkingDirectory($ID) & '\' & $Argv[$i], 1)
							Else
								$File = _WinAPI_PathSearchAndQualify($Argv[$i], 1)
							EndIf
							ExitLoop
						EndIf
					Next
					If $File Then
						$Version = FileGetVersion($Path)
						If @error Then
							$Version = ''
						EndIf
					EndIf
					$Flag = 0
				Else
					$File = $Path
					$Flag = 1
				EndIf
				$Data[0][0] += 1
				If $Data[0][0] > UBound($Data) - 1 Then
					ReDim $Data[$Data[0][0] + 100][6]
				EndIf
				$Data[$Data[0][0]][0] = $ID
				$Data[$Data[0][0]][1] = $Name
				$Data[$Data[0][0]][2] = $Path
				$Data[$Data[0][0]][3] = $Version
				$Data[$Data[0][0]][4] = $File
				$Data[$Data[0][0]][5] = $Flag
			EndIf
		Next
		_ArraySort($Data, 0, 1, $Data[0][0], 1)
		$Enum += 1
		For $i = 1 To $Data[0][0]
			$List = _WinAPI_EnumProcessWindows($Data[$i][0], Not $_All)
			If Not IsArray($List) Then
				ContinueLoop
			EndIf
			For $j = 1 To $List[0][0]
				If $_All Then
					$Flag = _WinAPI_IsWindowVisible($List[$j][0])
				Else
					$Flag = 1
				EndIf
				Local $hIcon
				If $Data[$i][5] Then
					$hIcon = _WinAPI_ExtractIcon($Data[$i][2], 0, 1)
					If $hIcon Then
						If Not $Flag Then
							$hIcon = _WinAPI_AddIconTransparency($hIcon, 50, 1)
						EndIf
						$ID = _GUIImageList_ReplaceIcon($hIL, -1, $hIcon)
						If $hIcon Then
							_WinAPI_DestroyIcon($hIcon)
						EndIf
					EndIf
				Else
					$hIcon = 0
				EndIf
				If Not $hIcon Then
					If $Data[$i][5] Then
						If $Flag Then
							$ID = 0
						Else
							$ID = 1
						EndIf
					Else
						If $Flag Then
							$ID = 2
						Else
							$ID = 3
						EndIf
					EndIf
				EndIf
				_GUICtrlListView_AddItem($hAutoIt, $Data[$i][1], $ID)
				_GUICtrlListView_AddSubItem($hAutoIt, $Index, $Data[$i][0], 1)
				_GUICtrlListView_AddSubItem($hAutoIt, $Index, $List[$j][0], 2)
				_GUICtrlListView_AddSubItem($hAutoIt, $Index, $List[$j][1], 3)
				_GUICtrlListView_AddSubItem($hAutoIt, $Index, _WinAPI_GetWindowText($List[$j][0]), 4)
				_GUICtrlListView_AddSubItem($hAutoIt, $Index, $Data[$i][3], 5)
				_GUICtrlListView_AddSubItem($hAutoIt, $Index, $Data[$i][4], 6)
				If Not $Flag Then
					_GUICtrlListView_SetItemParam($hAutoIt, $Index, 0x7FFFFFFF)
				EndIf
				$Index += 1
			Next
		Next
		$Enum -= 1
	EndIf
	_GUICtrlListView_EndUpdate($hAutoIt)
EndFunc   ;==>_SetAutoItInfo

Func _SetBitmap($hWnd, $hBitmap, $fUpdate = 0)
	ConsoleWrite('@@ (1993) :(' & @MIN & ':' & @SEC & ') _SetBitmap()' & @CR) ;### Function Trace
	Local $Pos
	If Not $hBitmap Then
		$Pos = ControlGetPos($hWnd, '', 0)
	EndIf

	Local $hPrev = _SendMessage($hWnd, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
	If $hPrev Then
		_WinAPI_DeleteObject($hPrev)
	EndIf

	If Not $hBitmap Then
		_WinAPI_MoveWindow($hWnd, $Pos[0], $Pos[1], $Pos[2], $Pos[3], 0)
	Else
		$hPrev = _SendMessage($hWnd, $STM_GETIMAGE)
		If $hPrev <> $hBitmap Then
			_WinAPI_DeleteObject($hBitmap)
		EndIf
	EndIf

	If $fUpdate Then
		_WinAPI_UpdateWindow($hWnd)
	EndIf
	Return 1
EndFunc   ;==>_SetBitmap

Func _SetData($CtrlID, $sData)
	ConsoleWrite('@@ (2020) :(' & @MIN & ':' & @SEC & ') _SetData()' & @CR) ;### Function Trace
	If StringCompare(GUICtrlRead($CtrlID), $sData, 1) Then
		_GUICtrlEdit_SetText($CtrlID, $sData)
	EndIf
EndFunc   ;==>_SetData

Func _SetStyle($hWnd, $iStyle, $fSet, $fExStyle = 0, $fUpdate = 0)
	ConsoleWrite('@@ (2027) :(' & @MIN & ':' & @SEC & ') _SetStyle()' & @CR) ;### Function Trace
	$hWnd = _HWnd($hWnd)
	If Not $hWnd Then
		Return
	EndIf

	Local $Flag = $GWL_STYLE

	If $fExStyle Then
		$Flag = $GWL_EXSTYLE
	EndIf

	Local $Style = _WinAPI_GetWindowLong($hWnd, $Flag)

	If $fSet Then
		If BitAND($Style, $iStyle) <> $iStyle Then
			_WinAPI_SetWindowLong($hWnd, $Flag, BitOR($Style, $iStyle))
		EndIf
	Else
		If BitAND($Style, $iStyle) Then
			_WinAPI_SetWindowLong($hWnd, $Flag, BitAND($Style, BitNOT($iStyle)))
		EndIf
	EndIf
	If $fUpdate Then
		_WinAPI_InvalidateRect($hWnd)
	EndIf
EndFunc   ;==>_SetStyle

Func _SetControlInfo($hWnd)
	ConsoleWrite('@@ (2056) :(' & @MIN & ':' & @SEC & ') _SetControlInfo()' & @CR) ;### Function Trace
	If Not $hWnd Then
		For $i = 16 To 30
			_SetData($Input[$i], '')
		Next
		Return
	EndIf

	Local $Data, $Prev, $Index

	$Index = _GUICtrlListView_GetSelectedIndices($hListView)
	$Data = _WinAPI_GetClassName($hWnd)
	If ($Index) And (StringCompare(_GUICtrlListView_GetItemText($hListView, $Index, 1), $Data, 1)) Then
		_GUICtrlListView_SetItemText($hListView, $Index, $Data, 1)
	EndIf
	If $Data Then
		_SetData($Input[16], $Data)
	Else
		_SetData($Input[16], '')
	EndIf
	$Prev = $Data
	$Data = _GetNN($hWnd)
	If $Data <= 0 Then
		$Data = ''
	EndIf
	If ($Index) And (StringCompare(_GUICtrlListView_GetItemText($hListView, $Index, 2), $Data, 1)) Then
		_GUICtrlListView_SetItemText($hListView, $Index, $Data, 2)
	EndIf
	If $Data Then
		_SetData($Input[17], $Data)
		If $Prev Then
			_SetData($Input[18], '[CLASS:' & $Prev & '; INSTANCE:' & $Data & ']')
		Else
			_SetData($Input[18], '')
		EndIf
	Else
		For $i = 17 To 18
			_SetData($Input[$i], '')
		Next
	EndIf
	$Data = _WinAPI_GetDlgCtrlID($hWnd)
	If $Data <= 0 Then
		$Data = ''
	EndIf
	If ($Index) And (StringCompare(_GUICtrlListView_GetItemText($hListView, $Index, 3), $Data, 1)) Then
		_GUICtrlListView_SetItemText($hListView, $Index, $Data, 3)
	EndIf
	If $Data Then
		_SetData($Input[19], $Data)
		If $Prev Then
			_SetData($Input[20], '[CLASS:' & $Prev & '; ID:' & $Data & ']')
		Else
			_SetData($Input[20], '')
		EndIf
	Else
		For $i = 19 To 20
			_SetData($Input[$i], '')
		Next
	EndIf
	$Data = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	_SetData($Input[21], '0x' & Hex($Data, 8))
	_SetData($Input[22], _GetStyleString($Data, 0, 0))
	$Data = _WinAPI_GetWindowLong($hWnd, $GWL_EXSTYLE)
	_SetData($Input[23], '0x' & Hex($Data, 8))
	_SetData($Input[24], _GetStyleString($Data, 0, 1))
	$Data = _WinAPI_GetWindowRect($hWnd)
	For $i = 27 To 28
		_SetData($Input[$i], DllStructGetData($Data, $i - 24) - DllStructGetData($Data, $i - 26))
	Next
	If _WinAPI_ScreenToClient(_WinAPI_GetAncestor($hWnd, $GA_ROOT), $Data) Then
		For $i = 25 To 26
			_SetData($Input[$i], DllStructGetData($Data, $i - 24))
		Next
	Else
		For $i = 25 To 26
			_SetData($Input[$i], '')
		Next
	EndIf
	_SetData($Input[29], $hWnd)
	$Data = StringLeft(ControlGetText($hWnd, '', 0), 80)
	Switch $_Code
		Case 0 ; ANSI
			$Data = BinaryToString(StringToBinary($Data, 2), 1)
		Case 1 ; Unicode

		Case 2 ; Unicode (Big Endian)
			$Data = BinaryToString(StringToBinary($Data, 2), 3)
		Case 3 ; UTF8
			$Data = BinaryToString(StringToBinary($Data, 2), 4)
	EndSwitch
	If $Data Then
		_SetData($Input[30], StringStripWS(StringRegExpReplace($Data, '\n.*', ''), 2))
	Else
		_SetData($Input[30], '')
	EndIf
EndFunc   ;==>_SetControlInfo

Func _SetWindowInfo($hWnd)
	ConsoleWrite('@@ (2154) :(' & @MIN & ':' & @SEC & ') _SetWindowInfo()' & @CR) ;### Function Trace
	If Not $hWnd Then
		For $i = 3 To 15
			_SetData($Input[$i], '')
		Next
		Return
	EndIf

	Local $Data

	$Data = _WinAPI_GetWindowText($hWnd)
	If $Data Then
		_SetData($Input[3], $Data)
	Else
		_SetData($Input[3], '')
	EndIf
	$Data = _WinAPI_GetClassName($hWnd)
	If $Data Then
		_SetData($Input[4], $Data)
	Else
		_SetData($Input[4], '')
	EndIf
	$Data = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	_SetData($Input[5], '0x' & Hex($Data, 8))
	_SetData($Input[6], _GetStyleString($Data))
	$Data = _WinAPI_GetWindowLong($hWnd, $GWL_EXSTYLE)
	_SetData($Input[7], '0x' & Hex($Data, 8))
	_SetData($Input[8], _GetStyleString($Data, 1, 1))
	$Data = _WinAPI_GetWindowRect($hWnd)
	For $i = 9 To 10
		_SetData($Input[$i], DllStructGetData($Data, $i - 8))
	Next
	For $i = 11 To 12
		_SetData($Input[$i], DllStructGetData($Data, $i - 8) - DllStructGetData($Data, $i - 10))
	Next
	_SetData($Input[13], $hWnd)
	$Data = WinGetProcess($hWnd)
	If $Data > -1 Then
		_SetData($Input[14], $Data)
		$Data = _WinAPI_GetProcessFileName($Data)
		If Not @error Then
			_SetData($Input[15], FileGetLongName($Data))
		Else
			_SetData($Input[15], '')
		EndIf
	Else
		For $i = 14 To 15
			_SetData($Input[$i], '')
		Next
	EndIf
EndFunc   ;==>_SetWindowInfo

Func _SetFrameOrder($hOwner)
	ConsoleWrite('@@ (2207) :(' & @MIN & ':' & @SEC & ') _SetFrameOrder()' & @CR) ;### Function Trace
	If BitAND(_WinAPI_GetWindowLong($hOwner, $GWL_EXSTYLE), $WS_EX_TOPMOST) Then
		WinSetOnTop($hFrame, '', 1)
	Else
		WinSetOnTop($hFrame, '', 0)
	EndIf
	If _WinAPI_SetWindowPos($hFrame, _WinAPI_GetWindow($hOwner, $GW_HWNDPREV), 0, 0, 0, 0, BitOR($SWP_NOACTIVATE, $SWP_NOMOVE, $SWP_NOSIZE)) Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_SetFrameOrder

Func _ShellAboutDlg($hParent = 0)
	ConsoleWrite('@@ (2221) :(' & @MIN & ':' & @SEC & ') _ShellAboutDlg()' & @CR) ;### Function Trace
	If Not $hAbout Then
		_GDIPlus_Startup()
		Local $hPng
		If Not @Compiled Then
			$hPng = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\..\Resources\About.png')
		Else
			$hPng = _LoadResourceImage($hInstance, 'PNG', 'ABOUT')
		EndIf
		$hAbout = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hPng)
		_GDIPlus_ImageDispose($hPng)
		_GDIPlus_Shutdown()
	EndIf

	Local $tSize = _WinAPI_GetBitmapDimension($hAbout)
	If @error Then
		Return 0
	EndIf

	GUISetState(@SW_DISABLE, $hParent)

	Local $Top = 0
	If Not $hParent Then
		$Top = $WS_EX_TOPMOST
	EndIf

	Local $hDlg = GUICreate($GUI_NAME, DllStructGetData($tSize, 1), DllStructGetData($tSize, 2), -1, -1, $WS_POPUP, BitOR($WS_EX_LAYERED, $Top), $hParent)
	Local $Pos = WinGetPos($hDlg)
	Local $hLayer = GUICreate('', 70, 23, $Pos[0] + ($Pos[2] - 70) / 2, $Pos[1] + $Pos[3] - 50, $WS_POPUP, $WS_EX_LAYERED, $hDlg)
	GUISetBkColor(0x2B5280, $hLayer)
	Local $Button = GUICtrlCreateButton('OK', 0, 0, 70, 23)
	GUICtrlSetState(-1, $GUI_FOCUS)

	_WinAPI_SetLayeredWindowAttributes($hLayer, 0x2B5280, 0, $LWA_COLORKEY)
	_WinAPI_UpdateLayeredWindowEx($hDlg, -1, -1, $hAbout)

	GUISetState(@SW_SHOW, $hDlg)
	GUISetState(@SW_SHOW, $hLayer)

	While 1
		$Msg = GUIGetMsg()
		Switch $Msg
			Case $GUI_EVENT_CLOSE, $Button
				ExitLoop
		EndSwitch
	WEnd

	GUISetState(@SW_ENABLE, $hParent)
	GUIDelete($hLayer)
	GUIDelete($hDlg)

EndFunc   ;==>_ShellAboutDlg

Func _ShellKillProcess($PID, $hParent = 0)
	ConsoleWrite('@@ (2275) :(' & @MIN & ':' & @SEC & ') _ShellKillProcess()' & @CR) ;### Function Trace
	Local $Name = _WinAPI_GetProcessName($PID)

	If Not $Name Then
		Return 0
	EndIf
	If MsgBox(256 + 48 + 4, $GUI_NAME, 'Are you sure you want to close this prosess?', 0, $hParent) = 6 Then
		If Not ProcessClose($PID) Then
			MsgBox(16, $GUI_NAME, 'Unable to close the process.', 0, $hParent)
			Return 0
		Else
			Return 1
		EndIf
	EndIf
	Return 0
EndFunc   ;==>_ShellKillProcess

Func _ShellReportDlg($hParent = 0)
	ConsoleWrite('@@ (2293) :(' & @MIN & ':' & @SEC & ') _ShellReportDlg()' & @CR) ;### Function Trace
	Local $Path = FileSaveDialog('Save Report', StringRegExpReplace($PathDlg, '\\[^\\]*\Z', ''), 'Text Document (*.txt)|All Files (*.*)', 2 + 16, 'Report.txt', $hParent)
	If Not $Path Then
		Return 1
	EndIf
	$PathDlg = StringRegExpReplace($Path, '^.*\.', '')
	$Data = _CreateReport()
	If Not $Data Then
		Return 0
	EndIf
	$hFile = FileOpen($Path, 2)
	Local $Result = FileWrite($hFile, $Data)
	FileClose($hFile)
	Return $Result
EndFunc   ;==>_ShellReportDlg

Func _ShellSaveDlg($hParent = 0)
	ConsoleWrite('@@ (2310) :(' & @MIN & ':' & @SEC & ') _ShellSaveDlg()' & @CR) ;### Function Trace
	Local $Path = FileSaveDialog('Save Image', StringRegExpReplace($PathDlg, '\\[^\\]*\Z', ''), 'Portable Network Graphic (*.png)|All Files (*.*)', 2 + 16, 'Capture.png', $hParent)
	If Not $Path Then
		Return 1
	EndIf
	$PathDlg = StringRegExpReplace($Path, '^.*\.', '')
	$hBitmap = _SendMessage($hPic[1], $STM_GETIMAGE)
	If Not $hBitmap Then
		Return 0
	EndIf
	Local $hArea = _WinAPI_CreateBitmap($_Crop[0] - 10, $_Crop[1] - 10, 1, 32)
	If Not $hArea Then
		Return 0
	EndIf
	Local $hSrcDC = _WinAPI_CreateCompatibleDC(0)
	Local $hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBitmap)
	Local $hDstDC = _WinAPI_CreateCompatibleDC(0)
	$hSrcSv = _WinAPI_SelectObject($hDstDC, $hArea)
	_WinAPI_BitBlt($hDstDC, 0, 0, $_Crop[0] - 10, $_Crop[1] - 10, $hSrcDC, 5, 5, $SRCCOPY)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hSrcDC)
	$hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hArea)
	Local $Result = _GDIPlus_ImageSaveToFile($hBitmap, $Path)
	_GDIPlus_BitmapDispose($hBitmap)
	_WinAPI_DeleteObject($hArea)
	Return $Result
EndFunc   ;==>_ShellSaveDlg

Func _ShowFrame($fShow, $tRect = 0, $hOwner = 0)
	ConsoleWrite('@@ (2339) :(' & @MIN & ':' & @SEC & ') _ShowFrame()' & @CR) ;### Function Trace
	If (Not $_Alpha) Or (Not $_Highlight) Then
		Return
	EndIf

	Local $hGraphics, $hPen, $hBitmap, $Pos

	If $_Fade Then
		AdlibUnRegister('_ShowProc')
		$Fade = 0
		$Hold = 0
	EndIf
	If $hRect Then
		_WinAPI_UpdateLayeredWindowEx($hFrame, -1, -1, $hRect, 0, 1)
	EndIf
	$Alpha = 0
	$hRect = 0
	If Not $fShow Then
		GUISetState(@SW_HIDE, $hFrame)
		If $_Fade Then
			$Fade = 1
			$Hold = TimerInit()
			AdlibRegister('_ShowProc', 10)
		EndIf
		Return
	EndIf
	$Pos = _WinAPI_GetPosFromRect($tRect)
	If (Not IsArray($Pos)) Or (Not $Pos[2]) Or (Not $Pos[3]) Then
		GUISetState(@SW_HIDE, $hFrame)
		Return
	EndIf
	WinMove($hFrame, '', $Pos[0], $Pos[1], $Pos[2], $Pos[3])
	If $hOwner Then
		_SetFrameOrder($hOwner)
	EndIf
	$hBitmap = _GDIPlus_BitmapCreateFromScan0($Pos[2], $Pos[3])
	$hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	$hPen = _GDIPlus_PenCreate(BitOR(BitShift($_Alpha, -24), $_Frame), 3)
	_GDIPlus_GraphicsDrawRect($hGraphics, 1, 1, _Max($Pos[2] - 3, 1), _Max($Pos[3] - 3, 1), $hPen)
	$hRect = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_ImageDispose($hBitmap)
	_GDIPlus_PenDispose($hPen)
	If $hRect Then
		GUISetState(@SW_SHOWNOACTIVATE, $hFrame)
	Else
		GUISetState(@SW_HIDE, $hFrame)
		If $_Fade Then
			$Hold = TimerInit()
		Else
			Return
		EndIf
	EndIf
	If $_Fade Then
		$Fade = 1
		AdlibRegister('_ShowProc', 10)
	Else
		If Not _WinAPI_UpdateLayeredWindowEx($hFrame, -1, -1, $hRect, $_Alpha) Then
			; Nothing
		EndIf
	EndIf
EndFunc   ;==>_ShowFrame

Func _ShowProc()
	ConsoleWrite('@@ (2403) :(' & @MIN & ':' & @SEC & ') _ShowProc()' & @CR) ;### Function Trace
	If $Hold Then
		If TimerDiff($Hold) > 250 Then
			AdlibUnRegister('_ShowProc')
			$Fade = 0
			$Hold = 0
		EndIf
		Return
	EndIf
	$Alpha += $_Alpha / 8
	If $Alpha >= $_Alpha Then
		$Alpha = $_Alpha
		$Hold = TimerInit()
	EndIf
	If Not _WinAPI_UpdateLayeredWindowEx($hFrame, -1, -1, $hRect, $Alpha) Then
		; Nothing
	EndIf
EndFunc   ;==>_ShowProc

Func _Update($fDisable = 0)
	ConsoleWrite('@@ (2423) :(' & @MIN & ':' & @SEC & ') _Update()' & @CR) ;### Function Trace
	$Refresh += 1

	Opt('GUIOnEventMode', 1)

	Local $State, $Update = False
	Local $hItem

	For $i = 0 To _GUICtrlListView_GetItemCount($hListView) - 1
		$hItem = Ptr(_GUICtrlListView_GetItemText($hListView, $i))
		If (Not $fDisable) And (_WinAPI_IsWindow($hItem)) Then
			$State = _WinAPI_IsWindowVisible($hItem)
			If _GUICtrlListView_GetItemChecked($hListView, $i) <> $State Then
				If Not $Update Then
					$Update = _GUICtrlListView_BeginUpdate($hListView)
				EndIf
				_GUICtrlListView_SetItemChecked($hListView, $i, $State)
				If _GUICtrlListView_GetItemState($hListView, $i, $LVIS_SELECTED) Then
					_SetControlInfo($hItem)
				EndIf
			EndIf
		Else
			If Not $Update Then
				$Update = _GUICtrlListView_BeginUpdate($hListView)
			EndIf
			If _GUICtrlListView_GetItemChecked($hListView, $i) Then
				_GUICtrlListView_SetItemChecked($hListView, $i, 0)
			EndIf
			If $hItem Then
				_GUICtrlListView_SetItemText($hListView, $i, $hItem & ChrW(160))
			EndIf
			_GUICtrlListView_RedrawItems($hListView, $i, $i)
		EndIf
	Next
	If $Update Then
		_GUICtrlListView_EndUpdate($hListView)
	EndIf

	Opt('GUIOnEventMode', 0)

	$Refresh -= 1

EndFunc   ;==>_Update

Func _ValueCheck($iValue, $iMin, $iMax = Default)
	ConsoleWrite('@@ (2468) :(' & @MIN & ':' & @SEC & ') _ValueCheck()' & @CR) ;### Function Trace
	If ($iMin <> Default) And ($iValue < $iMin) Then
		Return $iMin
	EndIf
	If ($iMax <> Default) And ($iValue > $iMax) Then
		Return $iMax
	EndIf
	Return $iValue
EndFunc   ;==>_ValueCheck

Func _WriteRegistry()
	ConsoleWrite('@@ (2479) :(' & @MIN & ':' & @SEC & ') _WriteRegistry()' & @CR) ;### Function Trace
	RegWrite($REG_KEY_NAME, 'XPos', 'REG_DWORD', $_XPos)
	RegWrite($REG_KEY_NAME, 'YPos', 'REG_DWORD', $_YPos)
	RegWrite($REG_KEY_NAME, 'ClientWidth', 'REG_DWORD', $_Width)
	RegWrite($REG_KEY_NAME, 'ClientHeight', 'REG_DWORD', $_Height)
	RegWrite($REG_KEY_NAME, 'AlwaysOnTop', 'REG_DWORD', $_Top)
	RegWrite($REG_KEY_NAME, 'CoordinateMode', 'REG_DWORD', $_Position)
	RegWrite($REG_KEY_NAME, 'ColorMode', 'REG_DWORD', $_Color)
	RegWrite($REG_KEY_NAME, 'Crosshair', 'REG_DWORD', $_Crosshair)
	RegWrite($REG_KEY_NAME, 'Highlight', 'REG_DWORD', $_Highlight)
	RegWrite($REG_KEY_NAME, 'HighlightColor', 'REG_DWORD', $_Frame)
	RegWrite($REG_KEY_NAME, 'HighlightTransparency', 'REG_DWORD', $_Alpha)
	RegWrite($REG_KEY_NAME, 'HighlightFadeIn', 'REG_DWORD', $_Fade)
	RegWrite($REG_KEY_NAME, 'Encoding', 'REG_DWORD', $_Code)
	RegWrite($REG_KEY_NAME, 'Tab', 'REG_DWORD', $_Tab)
	RegWrite($REG_KEY_NAME, 'ControlVisibleColor', 'REG_DWORD', $_Rgb[0])
	RegWrite($REG_KEY_NAME, 'ControlHiddenColor', 'REG_DWORD', $_Rgb[1])
	RegWrite($REG_KEY_NAME, 'ControlMissingColor', 'REG_DWORD', $_Rgb[2])
	RegWrite($REG_KEY_NAME, 'ColumnControlHandle', 'REG_DWORD', $_Column[0])
	RegWrite($REG_KEY_NAME, 'ColumnControlClass', 'REG_DWORD', $_Column[1])
	RegWrite($REG_KEY_NAME, 'ColumnControlNN', 'REG_DWORD', $_Column[2])
	RegWrite($REG_KEY_NAME, 'ColumnControlID', 'REG_DWORD', $_Column[3])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItProcess', 'REG_DWORD', $_Column[4])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItPID', 'REG_DWORD', $_Column[5])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItHandle', 'REG_DWORD', $_Column[6])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItClass', 'REG_DWORD', $_Column[7])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItTitle', 'REG_DWORD', $_Column[8])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItVersion', 'REG_DWORD', $_Column[9])
	RegWrite($REG_KEY_NAME, 'ColumnAutoItPath', 'REG_DWORD', $_Column[10])
	RegWrite($REG_KEY_NAME, 'CaptureWidth', 'REG_DWORD', $_Crop[0])
	RegWrite($REG_KEY_NAME, 'CaptureHeight', 'REG_DWORD', $_Crop[1])
	RegWrite($REG_KEY_NAME, 'LiveCapture', 'REG_DWORD', $_Capture)
	RegWrite($REG_KEY_NAME, 'AutoItVisible', 'REG_DWORD', $_All)
	If @Compiled Then
		RegWrite($REG_KEY_NAME, 'Path', 'REG_SZ', @ScriptFullPath)
	EndIf
EndFunc   ;==>_WriteRegistry

#EndRegion Additional Functions

#Region Hotkey Assigned Functions

Func _HK_Edit()
	ConsoleWrite('@@ (2522) :(' & @MIN & ':' & @SEC & ') _HK_Edit()' & @CR) ;### Function Trace
	Switch _WinAPI_GetFocus()
		Case 0

		Case $hAutoIt
			If Not _SCAW() Then
				GUICtrlSendToDummy($Dummy[4])
			EndIf
			Return
	EndSwitch
	GUISetAccelerators(0, $hForm)
	Send('{ENTER}')
	GUISetAccelerators($Accel, $hForm)
EndFunc   ;==>_HK_Edit

Func _HK_SelectAll()
	ConsoleWrite('@@ (2538) :(' & @MIN & ':' & @SEC & ') _HK_SelectAll()' & @CR) ;### Function Trace
	Local $ID = _WinAPI_GetDlgCtrlID(_WinAPI_GetFocus())

	For $i = 0 To UBound($Input) - 1
		If $Input[$i] = $ID Then
			_GUICtrlEdit_SetSel($ID, 0, -1)
			Return
		EndIf
	Next
	GUISetAccelerators(0, $hForm)
	Send('^a')
	GUISetAccelerators($Accel, $hForm)
EndFunc   ;==>_HK_SelectAll

#EndRegion Hotkey Assigned Functions

#Region Windows Message Functions

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2557) :(' & @MIN & ':' & @SEC & ') WM_COMMAND()' & @CR) ;### Function Trace
	; Handler from ColorChooser.au3
	CC_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

	Switch $hWnd
		Case $hForm
			Switch _WinAPI_HiWord($wParam)
				Case $EN_KILLFOCUS
					_GUICtrlEdit_SetSel(_WinAPI_LoWord($wParam), 0, 0)
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func WM_GETMINMAXINFO($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2572) :(' & @MIN & ':' & @SEC & ') WM_GETMINMAXINFO()' & @CR) ;### Function Trace
	Local $tMMI = DllStructCreate('long Reserved[2];long MaxSize[2];long MaxPosition[2];long MinTrackSize[2];long MaxTrackSize[2]', $lParam)

	Switch $hWnd
		Case $hForm
			If IsArray($Area) Then
				DllStructSetData($tMMI, 'MinTrackSize', $Area[2], 1)
				DllStructSetData($tMMI, 'MinTrackSize', $Area[3], 2)
				DllStructSetData($tMMI, 'MaxTrackSize', $Area[2], 1)
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_GETMINMAXINFO

Func WM_LBUTTONDBLCLK($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2587) :(' & @MIN & ':' & @SEC & ') WM_LBUTTONDBLCLK()' & @CR) ;### Function Trace
	Switch $hWnd
		Case $hForm

			Local $Info = GUIGetCursorInfo($hForm)

			If (IsArray($Info)) And ($Info[4] = $Pic) And ($hDesktop) And (Not _SCAW()) Then
				GUICtrlSendToDummy($Dummy[3])
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_LBUTTONDBLCLK

Func WM_LBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2601) :(' & @MIN & ':' & @SEC & ') WM_LBUTTONDOWN()' & @CR) ;### Function Trace
	Switch $hWnd
		Case $hForm

			Local $Info = GUIGetCursorInfo($hForm)

			If (IsArray($Info)) And ($Info[4] = $Pic) Then
				GUICtrlSendToDummy($Dummy[2])
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_LBUTTONDOWN

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2615) :(' & @MIN & ':' & @SEC & ') WM_NOTIFY()' & @CR) ;### Function Trace
	If $Enum Then
		Return $GUI_RUNDEFMSG
	EndIf

	Local $tNMITEMACTIVATE = DllStructCreate($tagNMHDR & __Iif(@AutoItX64, ';int', '') & ';int Item;int SubItem;uint NewState;uint OldState;uint Changed;long X;long Y;lparam lParam;uint KeyFlags', $lParam)
	Local $hFrom = DllStructGetData($tNMITEMACTIVATE, 'hWndFrom')
	Local $Index = DllStructGetData($tNMITEMACTIVATE, 'Item')
	Local $ID = DllStructGetData($tNMITEMACTIVATE, 'Code')
	Local $hItem, $State = False

	Switch $hFrom
		Case $hHeader[0]
			Switch $ID
				Case $HDN_ITEMCHANGEDW
					$_Column[$Index + 0] = _GUICtrlListView_GetColumnWidth($hListView, $Index)
			EndSwitch
		Case $hHeader[1]
			Switch $ID
				Case $HDN_ITEMCHANGEDW
					$_Column[$Index + 4] = _GUICtrlListView_GetColumnWidth($hAutoIt, $Index)
			EndSwitch
		Case $hListView
			Switch $ID
				Case $LVN_BEGINDRAG
					Return 0
				Case $NM_CUSTOMDRAW

					Local $tNMLVCUSTOMDRAW = DllStructCreate($tagNMHDR & __Iif(@AutoItX64, ';int', '') & ';dword DrawStage;hwnd hDC;long Left;long Top;long Right;long Bottom;dword_ptr ItemSpec;uint ItemState;lparam ItemlParam;dword clrText;dword clrTextBk;int SubItem;dword ItemType;dword clrFace;int IconEffect;int IconPhase;int PartId;int StateId;long TextLeft;long TextTop;long TextRight;long TextBottom;uint Align', $lParam)
					Local $Stage = DllStructGetData($tNMLVCUSTOMDRAW, 'DrawStage')
					Local $Index = DllStructGetData($tNMLVCUSTOMDRAW, 'ItemSpec')
					Local $BGR = $_Rgb[0]

					Switch $Stage
						Case $CDDS_ITEMPREPAINT
							Return $CDRF_NOTIFYSUBITEMDRAW
						Case BitOR($CDDS_ITEMPREPAINT, $CDDS_SUBITEM)
							$hItem = Ptr(_GUICtrlListView_GetItemText($hListView, $Index))
							If _WinAPI_IsWindow($hItem) Then
								$State = _WinAPI_IsWindowVisible($hItem)
								If Not $State Then
									$BGR = $_Rgb[1]
								EndIf
							Else
								$BGR = $_Rgb[2]
								If $hItem Then
									_GUICtrlListView_SetItemText($hListView, $Index, $hItem & ChrW(160))
									$hItem = 0
								EndIf
							EndIf
							If _GUICtrlListView_GetItemChecked($hListView, $Index) <> $State Then
								_GUICtrlListView_SetItemChecked($hListView, $Index, $State)
								_GUICtrlListView_RedrawItems($hListView, $Index, $Index)
								If ($hItem) And (Not $Refresh) And (_GUICtrlListView_GetItemState($hListView, $Index, $LVIS_SELECTED)) Then
									GUICtrlSendToDummy($Dummy[1], $Index)
								EndIf
							EndIf
							If $BGR Then
								DllStructSetData($tNMLVCUSTOMDRAW, 'clrText', _WinAPI_SwitchColor($BGR))
							EndIf
					EndSwitch
				Case $LVN_ITEMCHANGING
					If Not _GUICtrlListView_GetItemChecked($hListView, $Index) Then
						_GUICtrlListView_SetItemParam($hListView, $Index, 0x7FFFFFFF)
					Else
						_GUICtrlListView_SetItemParam($hListView, $Index, 0)
					EndIf
				Case $LVN_ITEMCHANGED
					$hItem = Ptr(_GUICtrlListView_GetItemText($hListView, $Index))
					If _GUICtrlListView_GetItemParam($hListView, $Index) Then
						$State = 1
					EndIf
					If _GUICtrlListView_GetItemChecked($hListView, $Index) <> $State Then
						If (BitAND(DllStructGetData($tNMITEMACTIVATE, 'NewState'), $LVIS_SELECTED)) And (Not BitAND(DllStructGetData($tNMITEMACTIVATE, 'OldState'), $LVIS_FOCUSED)) Then
							If _WinAPI_IsWindow($hItem) Then
								If Not $Browser Then
									If _WinAPI_IsWindowVisible($hItem) Then
										_ShowFrame(1, _WinAPI_GetWindowRect($hItem), _WinAPI_GetParent($hItem))
										$hOver = $hItem
									Else
										_ShowFrame(0)
										$hOver = 0
									EndIf
								EndIf
								_SetControlInfo($hItem)
							Else
								_SetControlInfo(0)
							EndIf
						EndIf
						If Not $Browser Then
							GUICtrlSendToDummy($Dummy[0], $Index)
						EndIf
					Else
						If Not $Refresh Then
							If _WinAPI_IsWindow($hItem) Then
								If _WinAPI_IsWindowVisible($hItem) Then
									ControlHide($hItem, '', '')
									$State = 0
								Else
									ControlShow($hItem, '', '')
									$State = 1
								EndIf
								If (_WinAPI_IsWindow($hItem)) And (_WinAPI_IsWindowVisible($hItem) = $State) And (_GUICtrlListView_GetItemState($hListView, $Index, $LVIS_SELECTED)) Then
									_SetControlInfo($hItem)
								EndIf
								_Update()
							EndIf
						EndIf
					EndIf
			EndSwitch
		Case $hAutoIt
			Switch $ID
				Case $LVN_BEGINDRAG
					Return 0
				Case $NM_CUSTOMDRAW

					Local $tNMLVCUSTOMDRAW = DllStructCreate($tagNMHDR & __Iif(@AutoItX64, ';int', '') & ';dword DrawStage;hwnd hDC;long Left;long Top;long Right;long Bottom;dword_ptr ItemSpec;uint ItemState;lparam ItemlParam;dword clrText;dword clrTextBk;int SubItem;dword ItemType;dword clrFace;int IconEffect;int IconPhase;int PartId;int StateId;long TextLeft;long TextTop;long TextRight;long TextBottom;uint Align', $lParam)
					Local $Stage = DllStructGetData($tNMLVCUSTOMDRAW, 'DrawStage')
					Local $Index = DllStructGetData($tNMLVCUSTOMDRAW, 'ItemSpec')

					Switch $Stage
						Case $CDDS_ITEMPREPAINT
							Return $CDRF_NOTIFYSUBITEMDRAW
						Case BitOR($CDDS_ITEMPREPAINT, $CDDS_SUBITEM)
							If _GUICtrlListView_GetItemParam($hAutoIt, $Index) Then
								DllStructSetData($tNMLVCUSTOMDRAW, 'clrText', _WinAPI_SwitchColor($_Rgb[1]))
							Else
								DllStructSetData($tNMLVCUSTOMDRAW, 'clrText', _WinAPI_SwitchColor($_Rgb[0]))
							EndIf
					EndSwitch
				Case $LVN_ITEMACTIVATE
					GUICtrlSendToDummy($Dummy[4])
				Case $LVN_KEYDOWN
					If Not _SCAW() Then
						Switch BitAND($Index, 0xFF)
							Case 0x2E ; DEL
								GUICtrlSendToDummy($Dummy[5])
							Case 0x74 ; F5
								GUICtrlSendToDummy($Dummy[6])
						EndSwitch
					EndIf
			EndSwitch
		Case $hTab
			Switch $ID
				Case $TCN_SELCHANGE
					$_Tab = _GUICtrlTab_GetCurSel($hTab)
					If $_Tab = 3 Then
						_SetAutoItInfo()
					EndIf
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func WM_MOVE($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2770) :(' & @MIN & ':' & @SEC & ') WM_MOVE()' & @CR) ;### Function Trace
	Switch $hWnd
		Case $hForm
			If Not _WinAPI_IsIconic($hForm) Then
				Local $tPlacement = _WinAPI_GetWindowPlacement($hForm)
				$_XPos = DllStructGetData($tPlacement, 'rcNormalPosition', 1)
				$_YPos = DllStructGetData($tPlacement, 'rcNormalPosition', 2)
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_MOVE

Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2783) :(' & @MIN & ':' & @SEC & ') WM_SIZE()' & @CR) ;### Function Trace
	Switch $hWnd
		Case $hForm
			Switch $wParam
				Case 0 ; SIZE_RESTORED
					$_Width = _WinAPI_LoWord($lParam)
					$_Height = _WinAPI_HiWord($lParam)
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

Func WM_SETCURSOR($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite('@@ (2796) :(' & @MIN & ':' & @SEC & ') WM_SETCURSOR()' & @CR) ;### Function Trace
	If $Browser Then
		Return $GUI_RUNDEFMSG
	EndIf

	Local $dX, $dY, $ID = -1

	Switch $hWnd
		Case $hForm, $hPopup
			If $Resize = -1 Then
				Local $Info = GUIGetCursorInfo($hForm)
				If (IsArray($Info)) And ($Info[4] = $Pic) Then
					Switch _IsCrop($Info[0], $Info[1], $dX, $dY) ; TODO dX dY undeclared!
						Case 0
							If _IsPressed(0x11) Then
								If $hDesktop Then
									If _IsPressed($PrimaryMouseButton) Then
										$ID = 2
									Else
										$ID = 1
									EndIf
								EndIf
							EndIf
						Case 1, 5
							$ID = 3
						Case 2, 6
							$ID = 4
						Case 3, 7
							$ID = 5
						Case 4, 8
							$ID = 6
					EndSwitch
				EndIf
			Else
				$ID = $Resize
			EndIf

			If $ID <> -1 Then
				_WinAPI_SetCursor($hCursor[$ID])
				Return 1
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SETCURSOR

#EndRegion Windows Message Functions

#Region AutoIt Exit Functions

Func AutoItExit()
	ConsoleWrite('@@ (2846) :(' & @MIN & ':' & @SEC & ') AutoItExit()' & @CR) ;### Function Trace
	_WriteRegistry()

	If $hPrev Then
		_WinAPI_SetSystemCursor($hPrev, $IDI_APPLICATION, 1)
	EndIf

	If $hForm Then
		GUIDelete($hFrame)
		GUIDelete($hForm)
	EndIf

	_GDIPlus_Shutdown()
EndFunc   ;==>AutoItExit

#EndRegion AutoIt Exit Functions
