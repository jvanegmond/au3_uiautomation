#include <GuiEdit.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>
#include "UIAWrappers.au3"

AutoItSetOption("MustDeclareVars", 1)

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

const $AutoSpy=0 ;2000 ; SPY about every 2000 milliseconds automatically, 0 is turn of use only ctrl+w

global $oldUIElement ; To keep track of latest referenced element
global $frmSimpleSpy, $edtCtrlInfo , $lblCapture, $lblEscape, $lblRecord, $edtCtrlRecord, $msg, $x, $y, $oUIElement, $oTW, $objParent, $oldElement, $text1, $t
global $i ; Just a simple counter to measure time expired in main loop
global $UIA_CodeArray

;~ Some references for reading
;~ [url=http://support.microsoft.com/kb/138518/nl]http://support.microsoft.com/kb/138518/nl[/url]  tagpoint structures attention point
;~ [url=http://www.autoitscript.com/forum/topic/128406-interface-autoitobject-iuiautomation/]http://www.autoitscript.com/forum/topic/128406-interface-autoitobject-iuiautomation/[/url]
;~ [url=http://msdn.microsoft.com/en-us/library/windows/desktop/ff625914(v=vs.85).aspx]http://msdn.microsoft.com/en-us/library/windows/desktop/ff625914(v=vs.85).aspx[/url]

HotKeySet("{ESC}", "Close") ; Set ESC as a hotkey to exit the script.
HotKeySet("^w", "GetElementInfo") ; Set Hotkey Ctrl+M to get some basic information in the GUI
HotKeySet("^r", "GenCode") ; Set Hotkey Ctrl+R to generate some code line in a basic way

#Region ### START Koda GUI section ### Form=
$frmSimpleSpy = GUICreate("Simple UIA Spy", 801, 601, 181, 4)
$edtCtrlInfo = GUICtrlCreateEdit("", 18, 18, 512, 580)
GUICtrlSetData(-1, "")
$lblCapture = GUICtrlCreateLabel("Ctrl+W to capture information", 544, 10, 528, 17)
$lblEscape = GUICtrlCreateLabel("Escape to exit", 544, 53, 528, 17)
$edtCtrlRecord = GUICtrlCreateEdit("", 544, 72, 233, 520)
GUICtrlSetData(-1, "//TO DO edtCtrlRecord")
$lblRecord = GUICtrlCreateLabel("Ctrl + R to record code", 544, 32, 527, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

_UIA_Init()

loadCodeTemplates() ; To use templates per class/controltype

; Run the GUI until the dialog is closed
While true
	$msg = GUIGetMsg()
	sleep(100)
	;~ if _ispressed(01) Then
	;~ getelementinfo()
	;~ endif

	;Just to show anyway the information about every n ms so ctrl+w is not interfering / removing window as unwanted side effects
	$i=$i+100
	if ($autoSpy<>0) and ($i>= $autoSpy) then
		$i=0
		getelementinfo()
	EndIf

	If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd

Func GetElementInfo()
	Local $hWnd, $i, $parentCount
	Local $tStruct = DllStructCreate($tagPOINT) ; Create a structure that defines the point to be checked.
	;~ Local $tStruct = DllStructCreate("INT64,INT64")
	;~ 	ToolTip("")
	;~ Global $UIA_oUIAutomation			;The main library core CUI automation reference
	;~ Global $UIA_oDesktop, $UIA_pDesktop		 ;Desktop will be frequently the starting point

	;~ Global $UIA_oUIElement, $UIA_pUIElement  ;Used frequently to get an element
	;~ Global $UIA_oTW, $UIA_pTW		 ;Generic treewalker which is allways available

	$x=MouseGetPos(0)
	$y=MouseGetPos(1)
	DllStructSetData($tStruct, "x", $x)
	DllStructSetData($tStruct, "y", $y)
;~ 	consolewrite(DllStructGetData($tStruct,"x") & DllStructGetData($tStruct,"y"))

;~ consolewrite("Mouse position is retrieved " & @crlf)

	$UIA_oUIAutomation.ElementFromPoint($tStruct,$UIA_pUIElement )

	;~ consolewrite("Element from point is passed, trying to convert to object ")
	$oUIElement = objcreateinterface($UIA_pUIElement,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)

	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	$oTW=ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
    If IsObj($oTW) = 0 Then
        msgbox(1,"UI automation treewalker failed", "UI Automation failed failed",10)
    EndIf

	local $oParentHandle[10] ; Max 10 (grand)parents

;~ 	at least 1
	$i=0
	$oTW.getparentelement($oUIElement,$oparentHandle[$i])
	$oParentHandle[$i]=objcreateinterface($oparentHandle[$i],$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If IsObj($oParentHandle[$i]) = 0 Then
		msgbox(1,"No parent", "UI Automation failed",10)
	Else
		while ($i <=9) and (IsObj($oParentHandle[$i])=true)
			$i=$i+1
			$oTW.getparentelement($oparentHandle[$i-1],$oparentHandle[$i])
			$oParentHandle[$i]=objcreateinterface($oparentHandle[$i],$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		wend
		$parentCount=$i-1
		consolewrite($parentCount & " parents found" & @crlf)
	EndIf

	if isobj($oldUIElement) Then
		if $oldUIElement=$oUIElement then
			return
		endif
	endif
	_WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN) ; Clears Red outline graphics.

	GUICtrlSetData($edtCtrlInfo, "Mouse position is retrieved " & $x & "-" & $y & @CRLF)
	$oldElement=$oUIElement

If IsObj($oUIElement) Then
	local $title=_UIA_getPropertyValue($oUIElement,$UIA_NamePropertyId)
	local $class=_UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid)
	local $controltypeName=_UIA_getControlName(_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId))
	local $controltypeId=_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId)
	local $controlIDString=$title
	local $nativeWindow=_UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId)
	local $pos=stringinstr($controlIDString,"-")

	if $pos > 0 Then
		$controlIDString=stringleft($controlIDString,$pos)
	EndIf
	$controlIDString=_NiceString($controlIDString)

;~  ConsoleWrite("At least we have an element "  & "[" & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & "][" & _UIA_getPropertyValue($oUIElement, $UIA_ClassNamePropertyId) & "]" & @CRLF)
	GUICtrlSetData($edtCtrlInfo, "At least we have an element "  & "[" & $title & "][" & $class & "]" & @CRLF,1)
    $text1="Title is: <" &  $title &  ">" & @TAB _
			& "Class   := <" & $class &  ">" & @TAB _
			& "controltype:= " 	& "<" &  $controltypeName &  ">" & @TAB  _
			& ",<" &  $controltypeId &  ">" & @TAB & ", (" &  hex($controltypeId )&  ")" & @TAB & @CRLF


local $codeText1=""

if $nativeWindow <> 0 Then
		$codetext1=$codetext1 & "_UIA_setVar(""" & $controlIDString & ".mainwindow"",""title:=" & $title &";classname:=" & $class & """)" & @CRLF
		$codetext1=$codetext1 & "_UIA_action(""" & $controlIDString & ".mainwindow"",""setfocus"")" & @CRLF
Else
		$codetext1=$codetext1 & ";~ First find the object in the parent before you can do something" & @CRLF
		$codetext1=$codetext1 & ";~$oUIElement=_UIA_getObjectByFindAll(""" & $controlIDString & ".mainwindow"", ""title:=" & $title &";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
		$codetext1=$codetext1 & "Local $oUIElement=_UIA_getObjectByFindAll($oP0, ""title:=" & $title &";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
		$codetext1=$codetext1 & "_UIA_action($oUIElement,""click"")" & @CRLF
EndIf

    $text1=$text1 & "*** Parent Information top down ***" & @CRLF
    local $pText1=""
	local $pCodeText2=""

;~ parentcount-1 As thats the $UIA_oDesktop
    for $i=$parentcount to 0 step -1
			$objParent=$oParentHandle[$i]
			local $ptitle=_UIA_getPropertyValue($objParent,$UIA_NamePropertyId)
			local $pclass=_UIA_getPropertyValue($objParent,$uia_classnamepropertyid)
			local $pcontroltypeName=_UIA_getControlName(_UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId))
			local $pControltypeId=_UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId)
            local $pDefaultExpression="""Title:=" & $pTitle & ";" & "controltype:=" & $pControlTypeName & ";" & "class:=" & $pClass & """"
			local $pNativeWindow=_UIA_getPropertyValue($objParent, $UIA_NativeWindowHandlePropertyId)
			$ptext1=$pText1 & $I & ": Title is: <" &  $ptitle &  ">" & @TAB _
					& "Class   := <" & $pclass &  ">" & @TAB _
					& "controltype:= " & "<" &  $pcontroltypeName &  ">" & @TAB  _
					& ",<" &  $PcontroltypeId &  ">" & @TAB & ", (" &  hex($PcontroltypeId) &  ")" & @TAB & @CRLF
			$ptext1=$ptext1 &  $pdefaultExpression & @TAB & @CRLF
			if $i=$parentcount-1 Then
				$pCodeText2=$pCodeText2 & "Local $oP" &$i & "=_UIA_getObjectByFindAll($UIA_oDesktop, " & $pdefaultExpression & ", $treescope_children)" & @TAB & @CRLF
			Else
				if $i<=$parentcount-2 then
					$pCodeText2=$pCodeText2 & "Local $oP" &$i & "=_UIA_getObjectByFindAll($oP" & $i+1 & ", " & $pdefaultExpression & ", $treescope_children)" & @TAB & @CRLF

				endif

			endif
			if ($pnativeWindow <> 0) and ($i<>$ParentCount) Then
				$pCodeText2=$pCodeText2 & "_UIA_Action($oP" & $i & ",""setfocus"")"  & @CRLF
			endif
	Next

    $text1=$text1 & $ptext1

	$text1=$text1 & "*** Standard code ***" & @CRLF
	$text1=$text1 & "#include ""UIAWrappers.au3""" & @CRLF
	$text1=$text1 & "AutoItSetOption(""MustDeclareVars"", 1)" & @CRLF & @CRLF

	$text1=$text1 & $pCodeText2
	$text1=$text1 & $codetext1

	$text1=$text1 & "*** Detailed properties of the highlighted element ***"
	$text1= $text1 & @CRLF & _UIA_getAllPropertyValues($oUIElement)

	GUICtrlSetData($edtCtrlInfo, "Having the following values for all properties: " & @crlf & $text1 & @CRLF, 1)

	_GUICtrlEdit_LineScroll($edtCtrlInfo, 0, 0 - _GUICtrlEdit_GetLineCount($edtCtrlInfo))

	$t=stringsplit(_UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId),";")
	_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
EndIf

EndFunc   ;==>GetElementInfo

Func Close()
Exit
EndFunc   ;==>Close



func genCode()
	local $i, $tLine
    $i=0
	while $i<>ubound($UIA_CodeArray)-1
		$i=$i+1

;~ 		["name",$UIA_NamePropertyId], _
;~ Global Const $UIA_RuntimeIdPropertyId=30000
		$tLine=$UIA_CodeArray[$i]
	WEnd


    ; Display the first line of the file.
;~     MsgBox($MB_SYSTEMMODAL, "", "First line of the file:" & @CRLF & $aArray[1])

EndFunc

func loadCodeTemplates()
    Local Const $sFilePath = @scriptdir & "\codeTemplates.txt"

    Local $hFileOpen = FileOpen($sFilePath, $FO_READ)
    If $hFileOpen = -1 Then
        consolewrite( "//TODO codetemplates.txt not available An error occurred when reading the file.")
        Return False
    EndIf

;~ 	Read the whole file straight into an array
	$UIA_CodeArray = FileReadToArray($hFileOpen)

    FileClose($hFileOpen)
EndFunc

func _NiceString($str)
	local $tStr=$str
	$tstr=stringreplace($tStr," ","")
	$tstr=stringreplace($tStr,"\","")
	return $tStr
EndFunc

; Draw rectangle on screen.
Func _DrawRect($tLeft, $tRight, $tTop, $tBottom, $color = 0xFF, $PenWidth = 4)
    Local $hDC, $hPen, $obj_orig, $x1, $x2, $y1, $y2
    $x1 = $tLeft
    $x2 = $tRight
    $y1 = $tTop
    $y2 = $tBottom
    $hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
    $hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color)
    $obj_orig = _WinAPI_SelectObject($hDC, $hPen)

    _WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1) ; horizontal to right
    _WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2) ; vertical down on right
    _WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2) ; horizontal to left right
    _WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1) ; vertical up on left

    ; clear resources
    _WinAPI_SelectObject($hDC, $obj_orig)
    _WinAPI_DeleteObject($hPen)
    _WinAPI_ReleaseDC(0, $hDC)
EndFunc   ;==>_DrawtRect


; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getAllPropertyValues($UIA_oUIElement)
; Description ...: Just return all properties as a string
; Syntax.........: _UIA_getPropertyValues
; Parameters ....: $obj - An UI Element object
; 				   $id - A reference to the property id
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; ===============================================================================================================================
; ~ Just get all available properties for desktop/should work on all IUIAutomationElements depending on ControlTypePropertyID they work yes/no
; ~ Just make it a very long string name:= value pairs
Func _UIA_getAllPropertyValues($UIA_oUIElement)
	Local $tStr, $tval, $tSeparator
	$tStr = ""
	$tSeparator = @CRLF ; To make sure its not a value you normally will get back for values
	For $i = 0 To UBound($UIA_propertiesSupportedArray) - 1
		$tval = _UIA_getPropertyValue($UIA_oUIElement, $UIA_propertiesSupportedArray[$i][1])
		If $tval <> "" Then
			$tStr = $tStr & "UIA_" & $UIA_propertiesSupportedArray[$i][0] & ":= <" & $tval & ">" & $tSeparator
		EndIf
	Next
	Return $tStr
EndFunc   ;==>_UIA_getAllPropertyValues