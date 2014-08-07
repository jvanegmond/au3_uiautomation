#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include "CUIAutomation2.au3"

; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 and up
; Description ...: Brings UI automation to AutoIt.
; Author(s) .....: junkew, Manadar
; ===============================================================================================================================

Global $UIA_oUIAutomation ; The main library core CUI automation reference
Global $UIA_oDesktop, $UIA_pDesktop ; Desktop will be frequently the starting point

Global $UIA_oUIElement, $UIA_pUIElement ; Used frequently to get an element

Global $UIA_oTW, $UIA_pTW ; Generic treewalker which is allways available
Global $UIA_oTRUECondition ; TRUE condition easy to be available for treewalking

Global $UIA_DefaultWaitTime = 200 ; Frequently it makes sense to have a small waiting time to have windows rebuild, could be set to 0 if good synch is happening

Global $UIA_oMainwindow

; ===================================================================================================================

_UIA_Init()

Func _UIA_Init()
	Local $UIA_pTRUECondition

	; The main object with acces to the windows automation api 3.0
	$UIA_oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation)
	If Not IsObj($UIA_oUIAutomation) Then
		Return SetError(1, 0, 0)
	EndIf

	; Try to get the desktop as a generic reference/global for all samples
	$UIA_oUIAutomation.GetRootElement($UIA_pDesktop)
	$UIA_oDesktop = ObjCreateInterface($UIA_pDesktop, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If Not IsObj($UIA_oDesktop) Then
		Return SetError(2, 0, 0)
	EndIf

	; Have a treewalker available to easily walk around the element trees
	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	$UIA_oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If Not IsObj($UIA_oTW) = 0 Then
		Return SetError(3, 0, 0)
	EndIf

	; Create a true condition for easy reference in treewalkers
	$UIA_oUIAutomation.CreateTrueCondition($UIA_pTRUECondition)
	$UIA_oTRUECondition = ObjCreateInterface($UIA_pTRUECondition, $sIID_IUIAutomationCondition, $dtagIUIAutomationCondition)

	Return 1
EndFunc   ;==>_UIA_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getControlName
; Description ...: Transforms the number of a control to a readable name
; Syntax.........: _UIA_getControlName($controlID)
; Parameters ....: $controlID
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; ===============================================================================================================================
Func _UIA_getControlName($controlID)
	Local $i
	SetError(1, 0, 0)
	For $i = 0 To UBound($UIA_ControlArray) - 1
		If ($UIA_ControlArray[$i][1] = $controlID) Then
			Return $UIA_ControlArray[$i][0]
		EndIf
	Next
EndFunc   ;==>_UIA_getControlName

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getControlId
; Description ...: Transforms the name of a controltype to an id
; Syntax.........: _UIA_getControlId($controlName)
; Parameters ....: $controlName
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
; ===============================================================================================================================
Func _UIA_getControlID($controlName)
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
EndFunc   ;==>_UIA_getControlID

; ## Internal use just to find the location of the property name in the property array##
Func _UIA_getPropertyIndex($propName)
	Local $i
	For $i = 0 To UBound($UIA_propertiesSupportedArray, 1) - 1
		If StringLower($UIA_propertiesSupportedArray[$i][0]) = StringLower($propName) Then
			Return $i
		EndIf
	Next
	Return SetError(1, 0, 0)
EndFunc   ;==>_UIA_getPropertyIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getPropertyValue($obj, $id)
; Description ...: Just return a single property or if its an array string them together
; Syntax.........: _UIA_getPropertyValue
; Parameters ....: $obj - An UI Element object
; 				   $id - A reference to the property id
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
; ===============================================================================================================================
; Just return a single property or if its an array string them together
Func _UIA_getPropertyValue($obj, $id)
	Local $tval
	Local $tStr
	Local $i

	If Not IsObj($obj) Then
		Return SetError(1, 0, "** NO PROPERTYVALUE DUE TO NONEXISTING OBJECT **")
	EndIf

	$obj.GetCurrentPropertyValue($id, $tval)
	$tStr = "" & $tval
	If IsArray($tval) Then
		$tStr = ""
		For $i = 0 To UBound($tval) - 1
			$tStr = $tStr & $tval[$i]
			If $i <> UBound($tval) - 1 Then
				$tStr = $tStr & "; "
			EndIf
		Next
		Return $tStr
	EndIf
	Return $tStr
EndFunc   ;==>_UIA_getPropertyValue

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

; INTERNAL USE
; Small helper function to get an object out of a treeSearch based on the name / title
; Not possible to match on multiple properties then findall should be used
Func _UIA_getFirstObjectOfElement($obj, $str, $treeScope)
	Local $tResult, $tval, $iTry, $t
	Local $pCondition, $oCondition
	Local $propertyID
	Local $i

	; Split a description into multiple subdescription/properties
	$tResult = StringSplit($str, ":=", 1)

	; If there is only 1 value without a property assume the default property name to use for identification
	If $tResult[0] = 1 Then
		$propertyID = $UIA_NamePropertyId
		$tval = $str
	Else
		For $i = 0 To UBound($UIA_propertiesSupportedArray) - 1
			If $UIA_propertiesSupportedArray[$i][0] = StringLower($tResult[1]) Then
				$propertyID = $UIA_propertiesSupportedArray[$i][1]

				; 				Some properties expect a number (otherwise system will break)
				Switch $UIA_propertiesSupportedArray[$i][1]
					Case $UIA_ControlTypePropertyId
						$tval = Number($tResult[2])
					Case Else
						$tval = $tResult[2]
				EndSwitch
			EndIf
		Next
	EndIf

	; Tricky when numeric values to pass
	$UIA_oUIAutomation.createPropertyCondition($propertyID, $tval, $pCondition)

	$oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationPropertyCondition, $dtagIUIAutomationPropertyCondition)

	$iTry = 1
	$UIA_oUIElement = ""
	Local Const $UIA_tryMax = 3 ; Retry

	While Not IsObj($UIA_oUIElement) And $iTry <= $UIA_tryMax
		$t = $obj.Findfirst($treeScope, $oCondition, $UIA_pUIElement)
		$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		If Not IsObj($UIA_oUIElement) Then
			Sleep(100)
			$iTry = $iTry + 1
		EndIf
	WEnd

	If IsObj($UIA_oUIElement) Then
		Return $UIA_oUIElement
	Else
		Return SetError(1, 0, "")
	EndIf

EndFunc   ;==>_UIA_getFirstObjectOfElement

; Find it by using a findall array of the UIA framework
Func _UIA_getObjectByFindAll($obj, $str, $treeScope, $p1 = 0)
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
				$index = _UIA_getPropertyIndex($propName)

				; Some properties expect a number (otherwise system will break)
				Switch $UIA_propertiesSupportedArray[$index][1]
					Case $UIA_ControlTypePropertyId
						$propValue = Number(_UIA_getControlID($propValue))
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
	For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
		$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

		;
		; 			& "Class   := <" & _UIA_getPropertyValue($UIA_oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
		; 			& "controltype:= <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB & @CRLF, $UIA_Log_Wrapper)

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

			$propertyActualValue = _UIA_getPropertyValue($UIA_oUIElement, $propertyID)
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
EndFunc   ;==>_UIA_getObjectByFindAll

Func _UIA_getPattern($obj, $patternID)
	Local $patternArray[21][3] = [ _
			[$UIA_ValuePatternId, $sIID_IUIAutomationValuePattern, $dtagIUIAutomationValuePattern], _
			[$UIA_InvokePatternId, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern], _
			[$UIA_SelectionPatternId, $sIID_IUIAutomationSelectionPattern, $dtagIUIAutomationSelectionPattern], _
			[$UIA_LegacyIAccessiblePatternId, $sIID_IUIAutomationLegacyIAccessiblePattern, $dtagIUIAutomationLegacyIAccessiblePattern], _
			[$UIA_SelectionItemPatternId, $sIID_IUIAutomationSelectionItemPattern, $dtagIUIAutomationSelectionItemPattern], _
			[$UIA_RangeValuePatternId, $sIID_IUIAutomationRangeValuePattern, $dtagIUIAutomationRangeValuePattern], _
			[$UIA_ScrollPatternId, $sIID_IUIAutomationScrollPattern, $dtagIUIAutomationScrollPattern], _
			[$UIA_GridPatternId, $sIID_IUIAutomationGridPattern, $dtagIUIAutomationGridPattern], _
			[$UIA_GridItemPatternId, $sIID_IUIAutomationGridItemPattern, $dtagIUIAutomationGridItemPattern], _
			[$UIA_MultipleViewPatternId, $sIID_IUIAutomationMultipleViewPattern, $dtagIUIAutomationMultipleViewPattern], _
			[$UIA_WindowPatternId, $sIID_IUIAutomationWindowPattern, $dtagIUIAutomationWindowPattern], _
			[$UIA_DockPatternId, $sIID_IUIAutomationDockPattern, $dtagIUIAutomationDockPattern], _
			[$UIA_TablePatternId, $sIID_IUIAutomationTablePattern, $dtagIUIAutomationTablePattern], _
			[$UIA_TextPatternId, $sIID_IUIAutomationTextPattern, $dtagIUIAutomationTextPattern], _
			[$UIA_TogglePatternId, $sIID_IUIAutomationTogglePattern, $dtagIUIAutomationTogglePattern], _
			[$UIA_TransformPatternId, $sIID_IUIAutomationTransformPattern, $dtagIUIAutomationTransformPattern], _
			[$UIA_ScrollItemPatternId, $sIID_IUIAutomationScrollItemPattern, $dtagIUIAutomationScrollItemPattern], _
			[$UIA_ItemContainerPatternId, $sIID_IUIAutomationItemContainerPattern, $dtagIUIAutomationItemContainerPattern], _
			[$UIA_VirtualizedItemPatternId, $sIID_IUIAutomationVirtualizedItemPattern, $dtagIUIAutomationVirtualizedItemPattern], _
			[$UIA_SynchronizedInputPatternId, $sIID_IUIAutomationSynchronizedInputPattern, $dtagIUIAutomationSynchronizedInputPattern], _
			[$UIA_ExpandCollapsePatternId, $sIID_IUIAutomationExpandCollapsePattern, $dtagIUIAutomationExpandCollapsePattern] _
			]

	Local $pPattern, $oPattern
	Local $sIID_Pattern
	Local $sdTagPattern
	Local $i

	For $i = 0 To UBound($patternArray) - 1
		If $patternArray[$i][0] = $patternID Then
			$sIID_Pattern = $patternArray[$i][1]
			$sdTagPattern = $patternArray[$i][2]
		EndIf
	Next

	$obj.getCurrentPattern($patternID, $pPattern)
	$oPattern = ObjCreateInterface($pPattern, $sIID_Pattern, $sdTagPattern)
	If IsObj($oPattern) Then
		Return $oPattern
	Else

	EndIf
EndFunc   ;==>_UIA_getPattern

Func _UIA_getTaskBar()
	Return _UIA_getFirstObjectOfElement($UIA_oDesktop, "classname:=Shell_TrayWnd", $TreeScope_Children)
EndFunc   ;==>_UIA_getTaskBar

Func _UIA_action($obj_or_string, $strAction, $p1 = 0, $p2 = 0, $p3 = 0, $p4 = 0)
	Local $obj
	Local $tPattern
	Local $x, $y
	Local $controlType
	Local $oElement
	Local $parentHandle
	Local $oTW
	Local $tPhysical, $startElement, $oStart, $pos, $tStr, $xx, $hwnd

	; If we are giving a description then try to make an object first by looking from repository
	; Otherwise assume an advanced description we should search under one of the previously referenced elements at runtime

	If Not IsObj($obj_or_string) Then
		Return SetError(1, 0, 0)
	EndIf
	$oElement = $obj_or_string
	$obj = $obj_or_string

	; if its a mainwindow reference find it under the desktop
	If StringInStr($obj_or_string, ".mainwindow") Then

		$startElement = "Desktop"
		$oStart = $UIA_oDesktop
		$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_subtree, $obj_or_string)
	Else

		$oStart = $UIA_oDesktop
		$startElement = "RTI.SEARCHCONTEXT"

		If Not IsObj($oStart) Then
			$pos = StringInStr($obj_or_string, ".")

			If $pos > 0 Then
				$tStr = "RTI." & StringLeft(StringUpper($obj_or_string), $pos - 1) & ".MAINWINDOW"
			Else
				$tStr = "RTI.MAINWINDOW"
			EndIf

			$oStart = $UIA_oDesktop
			$startElement = $tStr
			If Not IsObj($oStart) Then

				$oStart =$UIA_oDesktop
				$startElement = "RTI.PARENT"
				If Not IsObj($oStart) Then

					$startElement = "Desktop"
					$oStart = $UIA_oDesktop
				EndIf
			EndIf
		EndIf

		$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_subtree)
	EndIf

	; And just continue the action by setting the $obj value to an UIA element
	If IsObj($oElement) Then
		$obj = $oElement
	Else
		; exclude the intentional actions that are done for nonexistent objects
		If Not StringInStr("exist,exists", $strAction) Then
			SetError(1)
			Return False
		EndIf
	EndIf

	$controlType = _UIA_getPropertyValue($obj, $UIA_ControlTypePropertyId)

	; Execute the given action
	Switch $strAction
		; All mouse click actions
		Case "leftclick", "left", "click", "leftdoubleclick", "leftdouble", "doubleclick", _
				"rightclick", "right", "rightdoubleclick", "rightdouble", _
				"middleclick", "middle", "middledoubleclick", "middledouble"

			Local $clickAction = "left" ; Default action is the left mouse button
			Local $clickCount = 1 ; Default action is the single click

			If StringInStr($strAction, "right") Then $clickAction = "right"
			If StringInStr($strAction, "middle") Then $clickAction = "middle"
			If StringInStr($strAction, "double") Then $clickCount = 2

			Local $t
			$t = StringSplit(_UIA_getPropertyValue($obj, $UIA_BoundingRectanglePropertyId), "; ")
			$x = Int($t[1] + ($t[3] / 2))
			$y = Int($t[2] + $t[4] / 2)


			; Mouse should move to keep it as userlike as possible
			MouseMove($x, $y, 0)
			MouseClick($clickAction, $x, $y, $clickCount, 0)
			Sleep($UIA_DefaultWaitTime)

		Case "setvalue"

			If ($controlType = $UIA_WindowControlTypeId) Then
				$hwnd = 0
				$obj.CurrentNativeWindowHandle($hwnd)
				ConsoleWrite($hwnd)
				WinSetTitle(HWnd($hwnd), "", $p1)
			Else
				$obj.setfocus()
				Sleep($UIA_DefaultWaitTime)
				$tPattern = _UIA_getPattern($obj, $UIA_ValuePatternId)
				$tPattern.setvalue($p1)
			EndIf

		Case "setvalue using keys"
			$obj.setfocus()
			Send("^a")
			Send($p1)
			Sleep($UIA_DefaultWaitTime)
		Case "sendkeys", "enterstring", "type"
			$obj.setfocus()
			Send($p1)
		Case "invoke"
			$obj.setfocus()
			Sleep($UIA_DefaultWaitTime)
			$tPattern = _UIA_getPattern($obj, $UIA_InvokePatternId)
			$tPattern.invoke()
		Case "focus", "setfocus", "activate"
			$obj.setfocus()
			Sleep($UIA_DefaultWaitTime)
		Case "close"
			$tPattern = _UIA_getPattern($obj, $UIA_WindowPatternId)
			$tPattern.close()
		Case "move"
			$tPattern = _UIA_getPattern($obj, $UIA_TransformPatternId)
			$tPattern.move($p1, $p2)
		Case "resize"
			$tPattern = _UIA_getPattern($obj, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Normal)

			$tPattern = _UIA_getPattern($obj, $UIA_TransformPatternId)
			$tPattern.resize($p1, $p2)
		Case "minimize"
			$tPattern = _UIA_getPattern($obj, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Minimized)
		Case "maximize"
			$tPattern = _UIA_getPattern($obj, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Maximized)
		Case "normal"
			$tPattern = _UIA_getPattern($obj, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Normal)
		Case "close"
			$tPattern = _UIA_getPattern($obj, $UIA_WindowPatternId)
			$tPattern.close()
		Case "exist", "exists"
			; This code will never be reached but just to be complete and if it reaches this then its just true
			Return True
		Case "searchcontext", "context"
		Case Else
	EndSwitch

	Return True
EndFunc   ;==>_UIA_action

Func _UIA_ControlGetHandle($hWnd, $controlID)
	; check input
	; call internal function to get control
	; return it
EndFunc

Func _UIA_ControlSetText($hWnd, $controlID)
	; check input
	; do what _UIA_Action does with setvalue parameter
EndFunc

Func __UIA_ControlGet($hWnd, $controlID)
	; Implementation of _UIA_getFirstObjectOfElement here
	; Make sure it has instance # as well
EndFunc