#include <GuiEdit.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>
#include <Array.au3>
#include "..\UIAutomation.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

Local Const $AutoSpy = 0 ;2000 ; SPY about every 2000 milliseconds automatically, 0 is turn of use only ctrl+w

Local $oldUIElement ; To keep track of latest referenced element
Local $frmSimpleSpy, $edtCtrlInfo, $lblCapture, $lblEscape, $msg, $x, $y, $oUIElement, $oTW, $objParent, $oldElement, $text1, $t
Local $i ; Just a simple counter to measure time expired in main loop
Local $UIA_CodeArray

Local $UIA_oTW ; Generic treewalker which is allways available
Local $UIA_oTRUECondition ; TRUE condition easy to be available for treewalking

HotKeySet("{ESC}", "Close") ; Set ESC as a hotkey to exit the script.
HotKeySet("^w", "GetElementInfo") ; Set Hotkey Ctrl+M to get some basic information in the GUI

#Region ### START Koda GUI section ### Form=
$frmSimpleSpy = GUICreate("Simple UIA Spy", 801, 601, 181, 4)
$edtCtrlInfo = GUICtrlCreateEdit("", 18, 18, 512, 580)
GUICtrlSetData(-1, "")
$lblCapture = GUICtrlCreateLabel("Ctrl+W to capture information", 544, 10, 528, 17)
$lblEscape = GUICtrlCreateLabel("Escape to exit", 544, 53, 528, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

$UIA_oUIAutomation = _UIA_Init()

Local $UIA_pTRUECondition

; Have a treewalker available to easily walk around the element trees
Local $UIA_pTW
$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
$UIA_oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
If Not IsObj($UIA_oTW) Then
	MsgBox(0, @ScriptName, "Error creating RawViewWalker")
	Exit 1
EndIf

; Create a true condition for easy reference in treewalkers
$UIA_oUIAutomation.CreateTrueCondition($UIA_pTRUECondition)
$UIA_oTRUECondition = ObjCreateInterface($UIA_pTRUECondition, $sIID_IUIAutomationCondition, $dtagIUIAutomationCondition)

; Run the GUI until the dialog is closed
While True
	$msg = GUIGetMsg()
	Sleep(100)

	;Just to show anyway the information about every n ms so ctrl+w is not interfering / removing window as unwanted side effects
	$i = $i + 100
	If ($AutoSpy <> 0) And ($i >= $AutoSpy) Then
		$i = 0
		GetElementInfo()
	EndIf

	If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd

Func GetElementInfo()
	Local $hWnd, $i, $parentCount
	Local $tStruct = DllStructCreate($tagPOINT) ; Create a structure that defines the point to be checked.

	$x = MouseGetPos(0)
	$y = MouseGetPos(1)
	DllStructSetData($tStruct, "x", $x)
	DllStructSetData($tStruct, "y", $y)
	; 	consolewrite(DllStructGetData($tStruct,"x") & DllStructGetData($tStruct,"y"))

	; consolewrite("Mouse position is retrieved " & @crlf)

	Local $UIA_pUIElement
	$UIA_oUIAutomation.ElementFromPoint($tStruct, $UIA_pUIElement)

	; consolewrite("Element from point is passed, trying to convert to object ")
	$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

	Local $UIA_pTW
	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	$oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If IsObj($oTW) = 0 Then
		MsgBox(1, "UI automation treewalker failed", "UI Automation failed failed", 10)
	EndIf

	Local $oParentHandle[10] ; Max 10 (grand)parents

	; 	at least 1
	$i = 0
	$oTW.getparentelement($oUIElement, $oParentHandle[$i])
	$oParentHandle[$i] = ObjCreateInterface($oParentHandle[$i], $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If IsObj($oParentHandle[$i]) = 0 Then
		MsgBox(1, "No parent", "UI Automation failed", 10)
	Else
		While ($i <= 9) And (IsObj($oParentHandle[$i]) = True)
			$i = $i + 1
			$oTW.getparentelement($oParentHandle[$i - 1], $oParentHandle[$i])
			$oParentHandle[$i] = ObjCreateInterface($oParentHandle[$i], $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		WEnd
		$parentCount = $i - 1
		ConsoleWrite($parentCount & " parents found" & @CRLF)
	EndIf

	If IsObj($oldUIElement) Then
		If $oldUIElement = $oUIElement Then
			Return
		EndIf
	EndIf
	_WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN) ; Clears Red outline graphics.

	GUICtrlSetData($edtCtrlInfo, "Mouse position is retrieved " & $x & "-" & $y & @CRLF)
	$oldElement = $oUIElement

	If IsObj($oUIElement) Then
		Local $title = _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId)
		Local $class = _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid)
		Local $controltypeName = _UIA_GetControlName(_UIA_getPropertyValue($oUIElement, $UIA_ControlTypePropertyId))
		Local $controltypeId = _UIA_getPropertyValue($oUIElement, $UIA_ControlTypePropertyId)
		Local $controlIDString = $title
		Local $nativeWindow = _UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId)
		Local $pos = StringInStr($controlIDString, "-")

		If $pos > 0 Then
			$controlIDString = StringLeft($controlIDString, $pos)
		EndIf
		$controlIDString = _NiceString($controlIDString)

		;  ConsoleWrite("At least we have an element "  & "[" & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & "][" & _UIA_getPropertyValue($oUIElement, $UIA_ClassNamePropertyId) & "]" & @CRLF)
		GUICtrlSetData($edtCtrlInfo, "At least we have an element " & "[" & $title & "][" & $class & "]" & @CRLF, 1)
		$text1 = "Title is: <" & $title & ">" & @TAB _
				 & "Class   := <" & $class & ">" & @TAB _
				 & "controltype:= " & "<" & $controltypeName & ">" & @TAB _
				 & ",<" & $controltypeId & ">" & @TAB & ", (" & Hex($controltypeId) & ")" & @TAB & @CRLF


		Local $codeText1 = ""

		If $nativeWindow <> 0 Then
			$codeText1 = $codeText1 & "_UIA_setVar(""" & $controlIDString & ".mainwindow"",""title:=" & $title & ";classname:=" & $class & """)" & @CRLF
			$codeText1 = $codeText1 & "_UIA_action(""" & $controlIDString & ".mainwindow"",""setfocus"")" & @CRLF
		Else
			$codeText1 = $codeText1 & "; First find the object in the parent before you can do something" & @CRLF
			$codeText1 = $codeText1 & ";$oUIElement=_UIA_getObjectByFindAll(""" & $controlIDString & ".mainwindow"", ""title:=" & $title & ";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
			$codeText1 = $codeText1 & "Local $oUIElement=_UIA_getObjectByFindAll($oP0, ""title:=" & $title & ";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
			$codeText1 = $codeText1 & "_UIA_action($oUIElement,""click"")" & @CRLF
		EndIf

		$text1 = $text1 & "*** Parent Information top down ***" & @CRLF
		Local $pText1 = ""
		Local $pCodeText2 = ""

		; parentcount-1 As thats the $UIA_oDesktop
		For $i = $parentCount To 0 Step -1
			$objParent = $oParentHandle[$i]
			Local $ptitle = _UIA_getPropertyValue($objParent, $UIA_NamePropertyId)
			Local $pclass = _UIA_getPropertyValue($objParent, $uia_classnamepropertyid)
			Local $pcontroltypeName = _UIA_GetControlName(_UIA_getPropertyValue($objParent, $UIA_ControlTypePropertyId))
			Local $pControltypeId = _UIA_getPropertyValue($objParent, $UIA_ControlTypePropertyId)
			Local $pDefaultExpression = """Title:=" & $ptitle & ";" & "controltype:=" & $pcontroltypeName & ";" & "class:=" & $pclass & """"
			Local $pNativeWindow = _UIA_getPropertyValue($objParent, $UIA_NativeWindowHandlePropertyId)
			$pText1 = $pText1 & $i & ": Title is: <" & $ptitle & ">" & @TAB _
					 & "Class   := <" & $pclass & ">" & @TAB _
					 & "controltype:= " & "<" & $pcontroltypeName & ">" & @TAB _
					 & ",<" & $pControltypeId & ">" & @TAB & ", (" & Hex($pControltypeId) & ")" & @TAB & @CRLF
			$pText1 = $pText1 & $pDefaultExpression & @TAB & @CRLF
			If $i = $parentCount - 1 Then
				$pCodeText2 = $pCodeText2 & "Local $oP" & $i & "=_UIA_getObjectByFindAll($UIA_oDesktop, " & $pDefaultExpression & ", $treescope_children)" & @TAB & @CRLF
			Else
				If $i <= $parentCount - 2 Then
					$pCodeText2 = $pCodeText2 & "Local $oP" & $i & "=_UIA_getObjectByFindAll($oP" & $i + 1 & ", " & $pDefaultExpression & ", $treescope_children)" & @TAB & @CRLF

				EndIf

			EndIf
			If ($pNativeWindow <> 0) And ($i <> $parentCount) Then
				$pCodeText2 = $pCodeText2 & "_UIA_Action($oP" & $i & ",""setfocus"")" & @CRLF
			EndIf
		Next

		$text1 = $text1 & $pText1

		$text1 = $text1 & "*** Standard code ***" & @CRLF
		$text1 = $text1 & "#include ""UIAWrappers.au3""" & @CRLF
		$text1 = $text1 & "AutoItSetOption(""MustDeclareVars"", 1)" & @CRLF & @CRLF

		$text1 = $text1 & $pCodeText2
		$text1 = $text1 & $codeText1

		$text1 = $text1 & "*** Detailed properties of the highlighted element ***"
		$text1 = $text1 & @CRLF & _UIA_getAllPropertyValues($oUIElement)

		GUICtrlSetData($edtCtrlInfo, "Having the following values for all properties: " & @CRLF & $text1 & @CRLF, 1)

		_GUICtrlEdit_LineScroll($edtCtrlInfo, 0, 0 - _GUICtrlEdit_GetLineCount($edtCtrlInfo))

		$t = _UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId)
		_DrawRect($t[0], $t[2] + $t[0], $t[1], $t[3] + $t[1])
	EndIf

EndFunc   ;==>GetElementInfo

Func Close()
	Exit
EndFunc   ;==>Close

Func _NiceString($str)
	Local $tStr = $str
	$tStr = StringReplace($tStr, " ", "")
	$tStr = StringReplace($tStr, "\", "")
	Return $tStr
EndFunc   ;==>_NiceString

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
EndFunc   ;==>_DrawRect


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
		If IsArray($tval) Then
			$tval = _ArrayToString($tval, ";")
		EndIf
		If $tval <> "" Then
			$tStr = $tStr & "UIA_" & $UIA_propertiesSupportedArray[$i][0] & ":= <" & $tval & ">" & $tSeparator
		EndIf
	Next
	Return $tStr
EndFunc   ;==>_UIA_getAllPropertyValues



; Find it by using a findall array of the UIA framework
Func _UIA_GetObjectByFindAll($obj, $str, $treeScope, $p1 = 0)
	Local $pCondition, $pTrueCondition
	Local $pElements, $iLength

	Local $tResult
	Local $propertyID
	Local $tPos
	Local $relPos
	Local $relIndex = 0
	Local $tMatch
	Local $tStr
	Local $properties2Match[1][2] ; All properties of the expression to match in a normalized form
	Local $parentHandle ; Handle to get the parent of the element available

	Local $allProperties, $propertyCount, $propName, $propValue, $bAdd, $index, $i, $arrSize, $j
	Local $objParent, $propertyActualValue, $propertyVal, $oAutomationElementArray, $matchCount

	; 	Split it first into multiple sections representing each property
	$allProperties = StringSplit($str, "; ", 1)

	; Redefine the array to have all properties that are used to identify
	$propertyCount = $allProperties[0]
	ReDim $properties2Match[$propertyCount][2]
	For $i = 1 To $allProperties[0]
		$tResult = StringSplit($allProperties[$i], ":=", 1)

		; Handle syntax without a property to have default name property:  Ok as Name:=Ok
		If $tResult[0] = 1 Then
			$tResult[1] = StringStripWS($tResult[1], 3)
			$propName = $UIA_NamePropertyId
			$propValue = $allProperties[$i]

			$properties2Match[$i - 1][0] = $propName
			$properties2Match[$i - 1][1] = $propValue
		Else
			$tResult[1] = StringStripWS($tResult[1], 3)
			$tResult[2] = StringStripWS($tResult[2], 3)
			$propName = $tResult[1]
			$propValue = $tResult[2]

			; Exclude the properties with a specific meaning
			$bAdd = True
			If $propName = "indexrelative" Then
				$relPos = $propValue
				$bAdd = False
			EndIf
			If ($propName = "index") Or ($propName = "instance") Then
				$relIndex = $propValue
				$bAdd = False
			EndIf

			If $bAdd = True Then
				$index = _UIA_GetPropertyIndex($propName)

				; Some properties expect a number (otherwise system will break)
				Switch $UIA_propertiesSupportedArray[$index][1]
					Case $UIA_ControlTypePropertyId
						$propValue = Number(_UIA_GetControlID($propValue))
				EndSwitch

				; Add it to the normalized array
				$properties2Match[$i - 1][0] = $UIA_propertiesSupportedArray[$index][1] ; store the propertyID (numeric value)
				$properties2Match[$i - 1][1] = $propValue

			EndIf
		EndIf
	Next

	; Now walk through the tree
	$obj.FindAll($treeScope, $UIA_oTRUECondition, $pElements)
	$oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	$matchCount = 0

	; If there are no childs found then there is nothing to search
	If IsObj($oAutomationElementArray) Then
		; All elements to inspect are in this array
		$oAutomationElementArray.Length($iLength)
	Else

		$iLength = 0
	EndIf

	;
	Local $UIA_pUIElement
	For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
		$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

		;
		; 			& "Class   := <" & _UIA_GetPropertyValue($UIA_oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
		; 			& "controltype:= <" &  _UIA_GetPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB & @CRLF, $UIA_Log_Wrapper)

		; 		Walk through all properties in the properties2Match array to match
		; 		Normally not a big array just 1 - 5 elements frequently just 1
		$arrSize = UBound($properties2Match, 1) - 1
		For $j = 0 To $arrSize
			$propertyID = $properties2Match[$j][0]
			$propertyVal = $properties2Match[$j][1]
			$propertyActualValue = ""
			;

			; Some properties expect a number (otherwise system will break)

			Switch $propertyID
				Case $UIA_ControlTypePropertyId
					$propertyVal = Number($propertyVal)
			EndSwitch

			$propertyActualValue = _UIA_GetPropertyValue($UIA_oUIElement, $propertyID)
			$tMatch = StringRegExp($propertyActualValue, $propertyVal, 0)

			; Filter so not to much logging happens
			If $propertyActualValue <> "" Then
			EndIf

			If $tMatch = 0 Then
				; 				Special situation could be that its non matching on regex but exact match is there
				If $propertyVal <> $propertyActualValue Then ExitLoop
				$tMatch = 1
			EndIf

		Next

		If $tMatch = 1 Then
			If $relPos <> 0 Then
				;
				$oAutomationElementArray.GetElement($i + $relPos, $UIA_pUIElement)
				$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
			EndIf
			If $relIndex <> 0 Then
				$matchCount = $matchCount + 1
				If $matchCount <> $relIndex Then $tMatch = 0
			EndIf

			If $tMatch = 1 Then

				; Have the parent also available in the RTI
				$UIA_oTW.getparentelement($UIA_oUIElement, $parentHandle)
				$objParent = ObjCreateInterface($parentHandle, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
				If IsObj($objParent) Then

				EndIf

				; Add element to runtime information object reference
				If IsString($p1) Then


				EndIf
				Return $UIA_oUIElement
			EndIf
		EndIf
	Next

	Return ""
EndFunc   ;==>_UIA_GetObjectByFindAll



; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_GetControlName
; Description ...: Transforms the number of a control to a readable name
; Syntax.........: _UIA_GetControlName($controlID)
; Parameters ....: $controlID
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; ===============================================================================================================================
Func _UIA_GetControlName($controlID)
	Local $i
	SetError(1, 0, 0)
	For $i = 0 To UBound($UIA_ControlArray) - 1
		If ($UIA_ControlArray[$i][1] = $controlID) Then
			Return $UIA_ControlArray[$i][0]
		EndIf
	Next
EndFunc   ;==>_UIA_GetControlName

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_GetControlId
; Description ...: Transforms the name of a controltype to an id
; Syntax.........: _UIA_GetControlId($controlName)
; Parameters ....: $controlName
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
; ===============================================================================================================================
Func _UIA_GetControlID($controlName)
	Local $tName, $i
	$tName = StringUpper($controlName)
	If StringLeft($tName, 3) <> "UIA" Then
		$tName = "UIA_" & $tName & "CONTROLTYPEID"
	EndIf
	SetError(1, 0, 0)
	For $i = 0 To UBound($UIA_ControlArray) - 1
		If (StringUpper($UIA_ControlArray[$i][0]) = $tName) Then
			Return $UIA_ControlArray[$i][1]
		EndIf
	Next
EndFunc   ;==>_UIA_GetControlID

; ## Internal use just to find the location of the property name in the property array##
Func _UIA_GetPropertyIndex($propName)
	Local $i
	For $i = 0 To UBound($UIA_propertiesSupportedArray, 1) - 1
		If StringLower($UIA_propertiesSupportedArray[$i][0]) = StringLower($propName) Then
			Return $i
		EndIf
	Next
	Return SetError(1, 0, 0)
EndFunc   ;==>_UIA_GetPropertyIndex
