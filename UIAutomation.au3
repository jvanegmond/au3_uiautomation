#include-once
#include "UIAWrappers.au3"

; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 and up
; Description ...: UI automation for AutoIt.
; Author(s) .....: junkew, Manadar
; ===============================================================================================================================

Func _UIA_ControlGetHandle(ByRef $hWnd, $controlID)
	If $hWnd == 0 Then
		$hWnd = _UIA_GetDesktopElement()
		If @error Then Return SetError(3, 0, 0)
	EndIf

	If Not _UIA_IsElement($hWnd) Then
		$hWnd = __UIA_ControlGetFromHwnd($hWnd)
		If @error Then Return SetError(1, 0, 0)
	EndIf

	If Not _UIA_IsElement($controlID) Then
		$controlID = __UIA_ControlGet($hWnd, $controlID)
		If @error Then Return SetError(2, 0, 0)
	EndIf

	Return $controlID
EndFunc

Func _UIA_ControlSetText($hWnd, $controlID, $text, $flag = 0)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$tPattern = _UIA_CreateControlPattern($controlID, $UIA_ValuePattern)
	$tPattern.SetValue($text)

	; TODO: Impl $flag <> 0 to refresh window
EndFunc

Func _UIA_ControlGetText($hWnd, $controlID)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$tPattern = _UIA_CreateControlPattern($controlID, $UIA_ValuePattern)
	Local $sText = ""
	$tPattern.CurrentValue($sText)
	Return $sText
EndFunc

Func _UIA_ControlCheck($hWnd, $controlID, $checked = True)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$currentState = _UIA_GetPropertyValue($controlID, $UIA_ToggleToggleStatePropertyId)

	$tPattern = _UIA_CreateControlPattern($controlID, $UIA_TogglePattern)
	If $currentState <> $checked Then
		$tPattern.Toggle()
	EndIf
EndFunc

Func _UIA_ControlFocus($hWnd, $controlID)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	$controlID.SetFocus()
EndFunc

Func _UIA_ControlClick($hWnd, $controlID, $button = "invoke", $clicks = 1, $x = Default, $y = Default)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	If $button = "invoke" Then
		$controlID.SetFocus()

		$tPattern = _UIA_CreateControlPattern($controlID, $UIA_InvokePattern)
		$tPattern.Invoke()
	Else
		WinActivate($hWnd)

		$aBound = _UIA_GetPropertyValue($controlID, $UIA_BoundingRectanglePropertyId)

		If $x = Default Then $x = $aBound[2] / 2
		If $y = Default Then $y = $aBound[3] / 2

		$x = $x + $aBound[0]
		$y = $y + $aBound[1]

		MouseClick($button, $x, $y, $clicks, 0)
	EndIf
EndFunc

Func _UIA_ControlGetPos($hWnd, $controlID)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	Local $aWinBound = _UIA_GetPropertyValue($hWnd, $UIA_BoundingRectanglePropertyId)
	Local $aBound = _UIA_GetPropertyValue($controlID, $UIA_BoundingRectanglePropertyId)

	$aBound[0] = $aBound[0] - $aWinBound[0]
	$aBound[1] = $aBound[1] - $aWinBound[1]

	Return $aBound
EndFunc

Func _UIA_ControlSend($hWnd, $controlID, $string, $flag = 0)
	$controlID = _UIA_ControlGetHandle($hWnd, $controlID)
	If @error Then Return SetError(@error, 0, 0)

	WinActivate($hWnd)

	$controlID.SetFocus()

	SendKeepActive($hWnd)
	Send($string, $flag)
EndFunc

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
		If StringRegExp($controlID, $_UIA_Regex_ControlId_IsValidIdentifier) Then
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

Func __UIA_ControlSearch($searchRoot, $searchString)
	Local $searchInstance = 1, $searchBoundX = -1, $searchBoundY = -1, $searchBoundW = -1, $searchBoundH = -1
	Local $searchText = ""

	; Create condition array
	$searchStringKvPairs = StringRegExp($searchString, $_UIA_Regex_ControlId_SplitKeyValuePairs, 3)

	Local $pConditions[UBound($searchStringKvPairs)]
	Local $p = 0

	For $i = 0 To UBound($searchStringKvPairs) - 1
		$kvPair = $searchStringKvPairs[$i]
		$split = StringInStr($kvPair, ":")
		$key = StringLeft($kvPair, $split - 1)
		$value = StringMid($kvPair, $split + 1)
		Switch $key
			Case "ID", "NAME" ; AutomationId (always true?)
				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_AutomationIdPropertyId, String($value), $pCondition)
				$pConditions[$p] = $pCondition
				$p += 1
			Case "TEXT" ; Any text mentioned in the 'value pattern' of the control
				; Search for the text later, because FindAll/Properties do not support substring search
				$searchText = $value
			Case "CLASS" ; Classname
				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_ClassNamePropertyId, String($value), $pCondition)
				$pConditions[$p] = $pCondition
				$p += 1
			Case "INSTANCE" ; Instance number only
				$searchInstance = Int($value)
				; TODO: Error if instance already set by ClassNN? Check AutoIt behavior.
			Case "CLASSNN" ; Classname + Instance number appended
				$parsed = StringRegExp($value, $UIA_Regex_ControlId_ClassNameNN, 1)
				If @error Then Return SetError(1, 0, 0)

				$class = $parsed[0]
				$searchInstance = Int($parsed[1])
				; TODO: Error if instance already set by ClassNN? Check AutoIt behavior.

				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_ClassNamePropertyId, String($class), $pCondition)
				$pConditions[$p] = $pCondition
				$p += 1
			Case "HANDLE" ; Native window handle
				Local $pCondition
				$UIA_oUIAutomation.CreatePropertyCondition($UIA_NativeWindowHandlePropertyId, Int($value), $pCondition)
				$pConditions[$p] = $pCondition
				$p += 1
			Case "X"
				$searchBoundX = Int($value)
			Case "Y"
				$searchBoundY = Int($value)
			Case "W"
				$searchBoundW = Int($value)
			Case "H"
				$searchBoundH = Int($value)
		EndSwitch
	Next

	If $p = 0 Then
		; When no conditions are given, create a condition that's always true
		$pConditions = _UIA_GetTrueCondition()
	ElseIf $p = 1 Then
		; If there is only one condition, we use that as our final condition
		$pConditions = $pConditions[0]
	Else
		; AND conditions together to create a single new condition
		Local $pAndCondition = $pConditions[0], $pCondition = 0
		For $i = 1 To $p - 1
			Local $pNewCondition
			$UIA_oUIAutomation.CreateAndCondition($pAndCondition, $pConditions[$i], $pNewCondition)
			$pAndCondition = $pNewCondition
		Next
		$pConditions = $pAndCondition
	EndIf

	; Search for the element
	Local $pElements
	$searchRoot.FindAll($TreeScope_Children, $pConditions, $pElements)
	If Not $pElements Then Return SetError(1, 0, 0)

	$oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	Local $iLength
	$oAutomationElementArray.Length($iLength)
	If $iLength = 0 Then ; no elements found
		Return SetError(1, 0, 0)
	EndIf
	; Check if instance given fits the number of elements found
	If $searchInstance = 0 Or $searchInstance > $iLength Then
		Return SetError(1, 0, 0) ; TODO Correct @error num? Check AutoIt.
	EndIf

	; Get all elements and check other custom non-condition parameters, return the $searchInstance-th which matches
	Local $matchedInstance = 0
	For $i = 0 To $iLength - 1 ; GetElement is 1-indexed
		Local $pFound
		$oAutomationElementArray.GetElement($i, $pFound)
		$oFound = ObjCreateInterface($pFound, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

		Local $match = True ; assume a match until one of our custom non-condition parameters says otherwise

		; Check search text matches
		If $searchText <> "" Then
			$tValuePattern = _UIA_CreateControlPattern($oFound, $UIA_ValuePattern)
			If @error Then
				$match = False
			Else
				Local $sText = ""
				$tValuePattern.CurrentValue($sText)

				If Not StringInStr($sText, $searchText) Then
					$match = False
				EndIf
			EndIf
		EndIf

		; Check some properties about size or position of control
		If $searchBoundX <> -1 Or $searchBoundY <> -1 Or $searchBoundW <> -1 Or $searchBoundH <> -1 Then
			$aBound = _UIA_GetPropertyValue($oFound, $UIA_BoundingRectanglePropertyId) ; $aBound[0] = X [1] = Y, [2] = W, [3] = H

			; Convert absolute X and Y to local coordinates relative to $searchRoot
			$aWinBound = _UIA_GetPropertyValue($searchRoot, $UIA_BoundingRectanglePropertyId)
			$aBound[0] = $aBound[0] - $aWinBound[0]
			$aBound[1] = $aBound[1] - $aWinBound[1]

			If $searchBoundX <> -1 And $searchBoundX <> $aBound[0] Then
				$match = False
			EndIf
			If $searchBoundY <> -1 And $searchBoundY <> $aBound[1] Then
				$match = False
			EndIf
			If $searchBoundW <> -1 And $searchBoundW <> $aBound[2] Then
				$match = False
			EndIf
			If $searchBoundH <> -1 And $searchBoundH <> $aBound[3] Then
				$match = False
			EndIf
		EndIf

		; Check matched instance number
		If $match Then
			$matchedInstance += 1

			If $matchedInstance = $searchInstance Then
				Return $oFound
			EndIf
		EndIf
	Next

	Return SetError(1, 0, 0)
EndFunc   ;==>__UIA_ControlSearch