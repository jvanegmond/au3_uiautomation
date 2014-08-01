;~ Example 1 Iterating thru the different ways of representing the objects in the tree
;~ a. Autoit WinList function
;~ b. UIAutomation RawViewWalker
;~ c. UIAutomation ControlViewWalker
;~ d. UIAutomation ContentViewWalker
;~ e. Finding elements based on conditions (based on property id, frequently search on name or classname)

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "..\CUIAutomation2.au3"
#include "..\UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

Func sampleWinList()
	Local $var = WinList()

	For $i = 1 To $var[0][0]
		; Only display visble windows
		If $var[$i][0] <> "" And IsVisible($var[$i][1]) Then
			ConsoleWrite("Title=" & $var[$i][0] & @TAB & "Handle=" & $var[$i][1] & @CRLF)
		EndIf
	Next
EndFunc   ;==>sampleWinList

Func IsVisible($handle)
	If BitAND(WinGetState($handle), 2) Then
		Return 1
	Else
		Return 0
	EndIf

EndFunc   ;==>IsVisible

samplewinlist()

sampleTW(1)
sampleTW(2)
sampleTW(3)

ConsoleWrite("**** Desktop windows ****" & @CRLF)
findThemAll($UIA_oDesktop, $TreeScope_Children)

ConsoleWrite("**** All childs of the taskbar ****")
$oTaskBar = _UIA_gettaskbar()
findThemAll($oTaskBar, $treescope_subtree)

Func sampleTW($t)
	ConsoleWrite("initializing tw " & $t & @CRLF)
;~ ' Lets show all the items of the desktop with a treewalker
	If $t = 1 Then $UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	If $t = 2 Then $UIA_oUIAutomation.ControlViewWalker($UIA_pTW)
	If $t = 3 Then $UIA_oUIAutomation.ContentViewWalker($UIA_pTW)

	$oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If IsObj($oTW) = 0 Then
		MsgBox(1, "UI automation treewalker failed", "UI Automation failed failed", 10)
	EndIf

	$oTW.GetFirstChildElement($UIA_oDesktop, $UIA_pUIElement)
	$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

	While IsObj($oUIElement) = True
		ConsoleWrite("Title is: " & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & @TAB & "Handle=" & Hex(_UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId)) & @TAB & "Class=" & _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid) & @CRLF)
		$oTW.GetNextSiblingElement($oUIElement, $UIA_pUIElement)
		$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	WEnd
EndFunc   ;==>sampleTW

Func findThemAll($oElementStart, $TreeScope)
;~  Get result with findall function alternative could be the treewalker
	Dim $pCondition, $pTrueCondition
	Dim $pElements, $iLength

	$UIA_oUIAutomation.CreateTrueCondition($pTrueCondition)
	$oCondition = ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition, $dtagIUIAutomationCondition)
;~  $oCondition1 = _AutoItObject_WrapperCreate($aCall[1], $dtagIUIAutomationCondition)
;~ Tricky to search all descendants on html objects or from desktop/root element
	$oElementStart.FindAll($TreeScope, $oCondition, $pElements)

	$oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	$oAutomationElementArray.Length($iLength)
	For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
		$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		ConsoleWrite("Title is: " & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & @TAB & "Class=" & _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid) & @CRLF)
	Next

EndFunc   ;==>findThemAll