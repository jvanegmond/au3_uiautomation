#include-once
#include "CUIAutomation2.au3"
#include "StructureConstants.au3"

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

; Gets an UIA element for a Win32 window handle
Func __UIA_ControlGetFromHwnd($hwnd)
	If Not WinExists($hwnd) Then Return SetError(1, 0, 0)

	Local $pCondition
	$UIA_oUIAutomation.CreatePropertyCondition($UIA_NativeWindowHandlePropertyId, Int($hwnd), $pCondition)

	Local $UIA_pUIElement
	Local $t = _UIA_GetDesktopElement().FindFirst($TreeScope_Children, $pCondition, $UIA_pUIElement)
	Local $oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If Not _UIA_IsElement($oUIElement) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $oUIElement
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
EndFunc   ;==>_UIA_GetDesktopElement

Func _UIA_IsElement($control)
	Return IsObj($control) ; derp, TODO: check name?
EndFunc   ;==>_UIA_IsElement

Func _UIA_GetTrueCondition()
	Local $oTrueCondition
	$UIA_oUIAutomation.CreateTrueCondition($oTrueCondition)
	Return $oTrueCondition
EndFunc

Func _UIA_GetElementFromPoint($pos)
	Local $tStruct = DllStructCreate($tagPOINT)
	DllStructSetData($tStruct, "x", $pos[0])
	DllStructSetData($tStruct, "y", $pos[1])

	Local $UIA_pUIElement
	$UIA_oUIAutomation.ElementFromPoint($tStruct, $UIA_pUIElement)
	$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If Not _UIA_IsElement($oUIElement) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $oUIElement
EndFunc

Func _UIA_GetRawViewWalker()
	Local $UIA_pTW

	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	$UIA_oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If Not IsObj($UIA_oTW) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $UIA_pTW
EndFunc