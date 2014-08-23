#include-once
#include "CUIAutomation2.au3"

; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 and up
; Description ...: UI automation for AutoIt.
; Author(s) .....: junkew, Manadar
; ===============================================================================================================================

Local $UIA_oUIAutomation

Local Const $_UIA_Regex_ControlId_SplitKeyValuePairs = "(?:ID|TEXT|CLASS|CLASSNN|NAME|REGEXPCLASS|X|Y|W|H|INSTANCE|HANDLE): ?(?:[^;]*?;;)*[^;\]]+"
Local Const $_UIA_Regex_ControlId_IsValidIdentifier = "\[(?:(?:(?:ID|TEXT|CLASS|CLASSNN|NAME|REGEXPCLASS|X|Y|W|H|INSTANCE|HANDLE): ?(?:.*?;;)*[^;\]]+);? ?)+\]"
Local Const $UIA_Regex_ControlId_ClassNameNN = "^([^\[\]]+?)([0-9])$"

; ===================================================================================================================
Local Const $patternArray[21][3] = [ _
		[$UIA_ValuePattern, $sIID_IUIAutomationValuePattern, $dtagIUIAutomationValuePattern], _
		[$UIA_InvokePattern, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern], _
		[$UIA_SelectionPattern, $sIID_IUIAutomationSelectionPattern, $dtagIUIAutomationSelectionPattern], _
		[$UIA_LegacyIAccessiblePattern, $sIID_IUIAutomationLegacyIAccessiblePattern, $dtagIUIAutomationLegacyIAccessiblePattern], _
		[$UIA_SelectionItemPattern, $sIID_IUIAutomationSelectionItemPattern, $dtagIUIAutomationSelectionItemPattern], _
		[$UIA_RangeValuePattern, $sIID_IUIAutomationRangeValuePattern, $dtagIUIAutomationRangeValuePattern], _
		[$UIA_ScrollPattern, $sIID_IUIAutomationScrollPattern, $dtagIUIAutomationScrollPattern], _
		[$UIA_GridPattern, $sIID_IUIAutomationGridPattern, $dtagIUIAutomationGridPattern], _
		[$UIA_GridItemPattern, $sIID_IUIAutomationGridItemPattern, $dtagIUIAutomationGridItemPattern], _
		[$UIA_MultipleViewPattern, $sIID_IUIAutomationMultipleViewPattern, $dtagIUIAutomationMultipleViewPattern], _
		[$UIA_WindowPattern, $sIID_IUIAutomationWindowPattern, $dtagIUIAutomationWindowPattern], _
		[$UIA_DockPattern, $sIID_IUIAutomationDockPattern, $dtagIUIAutomationDockPattern], _
		[$UIA_TablePattern, $sIID_IUIAutomationTablePattern, $dtagIUIAutomationTablePattern], _
		[$UIA_TextPattern, $sIID_IUIAutomationTextPattern, $dtagIUIAutomationTextPattern], _
		[$UIA_TogglePattern, $sIID_IUIAutomationTogglePattern, $dtagIUIAutomationTogglePattern], _
		[$UIA_TransformPattern, $sIID_IUIAutomationTransformPattern, $dtagIUIAutomationTransformPattern], _
		[$UIA_ScrollItemPattern, $sIID_IUIAutomationScrollItemPattern, $dtagIUIAutomationScrollItemPattern], _
		[$UIA_ItemContainerPattern, $sIID_IUIAutomationItemContainerPattern, $dtagIUIAutomationItemContainerPattern], _
		[$UIA_VirtualizedItemPattern, $sIID_IUIAutomationVirtualizedItemPattern, $dtagIUIAutomationVirtualizedItemPattern], _
		[$UIA_SynchronizedInputPattern, $sIID_IUIAutomationSynchronizedInputPattern, $dtagIUIAutomationSynchronizedInputPattern], _
		[$UIA_ExpandCollapsePattern, $sIID_IUIAutomationExpandCollapsePattern, $dtagIUIAutomationExpandCollapsePattern] _
	]

_UIA_Init()

Func _UIA_Init()
	; The main object with acces to the windows automation api 3.0
	$UIA_oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation)
	If Not IsObj($UIA_oUIAutomation) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $UIA_oUIAutomation
EndFunc   ;==>_UIA_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_GetPropertyValue($oElement, $iPropertyID)
; Description ...: Returns the property of an element
; Parameters ....: $oElement - An UI Element object
; 				   $iPropertyID - A reference to the property id
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1    - $oElement was not a UI element
; ===============================================================================================================================
; Just return a single property or if its an array string them together
Func _UIA_GetPropertyValue($oElement, $iPropertyID)
	Local $vRetVal

	If Not _UIA_IsElement($oElement) Then
		Return SetError(1, 0, 0)
	EndIf

	$oElement.GetCurrentPropertyValue($iPropertyID, $vRetVal)
	Return $vRetVal
EndFunc   ;==>_UIA_GetPropertyValue


Func _UIA_CreateControlPattern($obj, $Pattern)
	Local $sIID_Pattern
	Local $sdTagPattern

	For $i = 0 To UBound($patternArray) - 1
		If $patternArray[$i][0] = $Pattern Then
			$sIID_Pattern = $patternArray[$i][1]
			$sdTagPattern = $patternArray[$i][2]
			ExitLoop
		EndIf
	Next

	Local $pPattern
	$obj.GetCurrentPattern($Pattern, $pPattern)
	Local $oPattern = ObjCreateInterface($pPattern, $sIID_Pattern, $sdTagPattern)
	If IsObj($oPattern) Then
		Return $oPattern
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_UIA_CreateControlPattern

; __UIA_ControlGet parameters:

; $searchRoot can be:
; - a Win32 window handle
; - window title (str)
; - another control in UI automation tree (for example, a group box)
; its meaning is basically the root context from which to start the tree search from

; $controlID can be:
; - a handle to a Win32 control
; - a handle to a UIAutomation control (this is then returned without modification)
; - a string in the following format: [KEY: VALUE; KEY: VALUE] where keys can be:
; ID - UIA_AutomationId
; TEXT - UIA_ValueValue or UIA_iaccessiblevalue
; CLASS - UIA_class
; CLASSNN - CLASS + INSTANCE (legacy)
; NAME - ??? - The internal .NET Framework WinForms name (if available)
; REGEXPCLASS - CLASS based on regular expression (check escaping mechanism, backslashes?)
; X \ Y \ W \ H - UIA_BoundingRectangle
; INSTANCE - Created by this UDF by walking the UIA tree

; Internal: Use _UIA_ControlGetHandle instead
Func __UIA_ControlGet($searchRoot, $controlID = 0)
	If IsString($controlID) Then
		If StringRegExp($controlID, $_UIA_Regex_ControlID_IsValidIdentifier) Then
			$ret = __UIA_ControlSearch($searchRoot, $controlID)
			Return SetError(@error, 0, $ret)
		Else
			; Legacy support for ClassNameNN format (or legacy ID support)
			If StringRegExp($controlID, $UIA_Regex_ControlId_ClassNameNN) And Not StringRegExp($controlID, "^[0-9]+$") Then
				$ret = __UIA_ControlSearch($searchRoot, "[CLASSNN:" & $controlID & "]")
				Return SetError(@error, 0, $ret)
			EndIf
		EndIf
	EndIf

	; hWnd pointing to Win32 control
	If IsHWnd($controlID) Then
		$ret = __UIA_ControlSearch($searchRoot, "[HANDLE:" & $controlID & "]")
		Return SetError(@error, 0, $ret)
	EndIf

	; Legacy ID support (integer which is UIA_AutomationId)
	If Int($controlID) > 0 Then
		$ret = __UIA_ControlSearch($searchRoot, "[ID:" & $controlID & "]")
		Return SetError(@error, 0, $ret)
	EndIf

	If _UIA_IsElement($controlID) Then
		Return $controlID
	EndIf

	Return SetError(1, 0, 0)
EndFunc   ;==>__UIA_ControlGet

Func __UIA_ControlSearch($searchRoot, $controlSearchString)
	Local $searchInstance = 1

	; Create condition array
	$kvPairs = StringRegExp($controlSearchString, $_UIA_Regex_ControlId_SplitKeyValuePairs, 3)
	$numPairs = UBound($kvPairs)
	Local $pConditions[$numPairs]
	For $i = 0 To $numPairs - 1
		$kvPair = $kvPairs[$i]
		$n = StringInStr($kvPair, ":")
		$key = StringLeft($kvPair, $n - 1)
		$value = StringMid($kvPair, $n + 1)
		Switch $key
			Case "ID" ; UIA_AutomationId
				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_AutomationIdPropertyId, String($value), $pCondition)
				$pConditions[$i] = $pCondition
			Case "TEXT"
				; TODO: Implement text/value property condition
			Case "CLASS" ; UIA_class
				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_ClassNamePropertyId, String($value), $pCondition)
				$pConditions[$i] = $pCondition
			Case "INSTANCE"
				$searchInstance = Int($value)
			Case "CLASSNN"
				$parsed = StringRegExp($value, $UIA_Regex_ControlId_ClassNameNN, 1)
				If @error Then Return SetError(1, 0, 0)

				$class = $parsed[0]
				$searchInstance = Int($parsed[1])

				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_ClassNamePropertyId, String($class), $pCondition)
				$pConditions[$i] = $pCondition
			Case "HANDLE"
				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_NativeWindowHandlePropertyId, Int($value), $pCondition)
				$pConditions[$i] = $pCondition
		EndSwitch
	Next

	; AND conditions together
	Local $pCondition = 0
	If $numPairs = 1 Then
		$pCondition = $pConditions[0]
	Else
		Local $pAndCondition = $pConditions[0]
		For $i = 1 To $numPairs - 1
			Local $pNewCondition
			$UIA_oUIAutomation.CreateAndCondition($pAndCondition, $pConditions[$i], $pNewCondition)
			$pAndCondition = $pNewCondition
		Next
		$pCondition = $pConditions[0]
	EndIf

	; Search for the element
	Local $pElements
	$searchRoot.FindAll($TreeScope_Children, $pCondition, $pElements)

	$oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	Local $iLength
	$oAutomationElementArray.Length($iLength)

	; Pick the element based on the INSTANCE given
	If $iLength = 0 Then
		Return SetError(1, 0, 0)
	Else
		$searchInstance -= 1 ; for 0-based index in $oAutomationElementArray

		If $searchInstance < 0 Or $searchInstance >= $iLength Then
			Return SetError(1, 0, 0)
		EndIf

		Local $pFound
		$oAutomationElementArray.GetElement($searchInstance, $pFound)
		$oFound = ObjCreateInterface($pFound, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

		Return $oFound
	EndIf
EndFunc   ;==>__UIA_ControlSearch

; Gets an UIA element for a Win32 window handle
Func __UIA_ControlGetFromHwnd($hwnd)
	If Not WinExists($hwnd) Then Return SetError(1, 0, 0)

	Local $pCondition, $UIA_pUIElement

	$UIA_oUIAutomation.createPropertyCondition($UIA_NativeWindowHandlePropertyId, Int($hwnd), $pCondition)

	$t = _UIA_GetDesktopElement().FindFirst($TreeScope_Children, $pCondition, $UIA_pUIElement)
	$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

	Return $UIA_oUIElement
EndFunc   ;==>__UIA_ControlGetFromHwnd

Func _UIA_GetDesktopElement()
	Local $UIA_oDesktop ; Desktop will be frequently the starting point

	; Try to get the desktop as a generic reference/global for all samples
	Local $UIA_pDesktop
	$UIA_oUIAutomation.GetRootElement($UIA_pDesktop)
	$UIA_oDesktop = ObjCreateInterface($UIA_pDesktop, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If Not _UIA_IsElement($UIA_oDesktop) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $UIA_oDesktop
EndFunc

Func _UIA_IsElement($control)
	Return IsObj($control)
EndFunc   ;==>_UIA_IsElement