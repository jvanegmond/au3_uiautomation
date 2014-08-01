;~ Example 3 Clicking a litlle more and in the end displaying all items from the clock (thats not directly possible with AU3Info)
;~ This shows a little more on the concept of
;~ 1. Find your element
;~ 2. Think what you want and find the right pattern
;~ 3. Retrieve the pattern and execute the action
;~
;~ Within the patterns you will find not likely direct support for clicking right mouse and default actions are not allways what you want so
;~ then you have to fallback to mousemove, mouseclick functions of autoit or
;~ the sendinput function from microsoft (not declared in the standard autoit library)

#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

Consolewrite("**** Get the taskbar ****" & @CRLF)
$oTaskBar=_UIA_gettaskbar()
;~ Equal To
;~ _UIA_getFirstObjectOfElement($oDesktop,"classname:=Shell_TrayWnd",$TreeScope_Children)

Consolewrite("**** All childs of the taskbar ****" & @CRLF)
;~  _UIA_dumpThemAll($otaskbar,$treescope_subtree)

Dim $pInvoke ;~ Pattern invoke
Dim $oStart  ;~ Object reference to IUIElement for button start

Consolewrite("**** Different ways of assigning the startbutton to an object ****" & @CRLF)
;~ $oStart=_UIA_getFirstObjectOfElement($oTaskbar,"Starten", $treescope_subtree)
$oStart=_UIA_getFirstObjectOfElement($oTaskbar,"name:=Starten", $treescope_subtree)

Dim $oClock  ;~ Object reference to IUIElement for button of clock, be aware this is a panel not a button
$oClock=_UIA_getFirstObjectOfElement($oTaskbar,"classname:=TrayClockWClass", $treescope_subtree)

Consolewrite("**** try to click on the start button of the taskbar ****" & @CRLF)
;~ Get the first item that has as the name: Starten change to Start for english or other text to match start button in local language
$oStart=_UIA_getFirstObjectOfElement($oTaskbar,"Starten", $treescope_subtree)

if isobj($oStart) Then
    consolewrite("Start button found")
Else
    consolewrite("I bet the text has to change to Start instead of Starten")
EndIf

Consolewrite("Get the invoke pattern to click on the start button item. Invoke possible: " & _UIA_getPropertyValue($UIA_oUIElement, $UIA_IsInvokePatternAvailablePropertyId) & @CRLF)
;~ $oStart.getCurrentPattern($UIA_InvokePatternId, $pInvoke)
;~ $oInvokeP=objCreateInterface($pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern)
$oInvokeP=_UIA_getpattern($oStart,$UIA_InvokePatternID)
$oInvokeP.invoke()
sleep(100)

Consolewrite("Get the menu that is after the start button" & @crlf)

$oMenuStart=_UIA_getFirstObjectOfElement($UIA_oDesktop,"Menu Start", $treescope_children)
if isobj($oMenuStart) Then
    consolewrite("Menu start found" & @crlf)
Else
    consolewrite("I bet the text has to change to Start instead of Starten" & @crlf)
EndIf

dim $oStartMenuItem
$oStartMenuItem=_UIA_getFirstObjectOfElement($oMenuStart,"name:=SciTE", $treescope_subtree)
;~ $oStartMenuItem=_UIA_getFirstObjectOfElement($oMenuStart,"Microsoft Excel 2010", $treescope_subtree)
;~ $oStartMenuItem=_UIA_getFirstObjectOfElement($oMenuStart,"SpotGrit", $treescope_subtree)
if isobj($oStartMenuItem) Then
    consolewrite("Scite found" & @crlf)
Else
    consolewrite("scite not found" & @crlf)
EndIf

Consolewrite("Get the pattern to click on the menu after the start button. Invoke possible: " & _UIA_getPropertyValue($oStartMenuItem, $UIA_IsInvokePatternAvailablePropertyId) & @CRLF)
$oInvokeP=_UIA_getpattern($oStartMenuItem,$UIA_InvokePatternID)
;~ This would definitely fail as there is no invoke pattern
if isobj($oInvokeP) Then
    consolewrite("invoke found lets see what happens" & @crlf)
Else
    consolewrite("invoke not supported" & @crlf)
EndIf
$oInvokeP.invoke()

sleep(2000)

consolewrite("So you saw it selected but did not click" & @crlf)
;~ still you can click as you now know the dimensions where to click
dim $t
$t=stringsplit(_UIA_getPropertyValue($oStartMenuItem, $UIA_BoundingRectanglePropertyId),";")
consolewrite($t[1] & ";" & $t[2] & ";" & $t[3] & ";" & $t[4] & @crlf)
;~ _winapi_mouse_event($MOUSEEVENTF_ABSOLUTE + $MOUSEEVENTF_MOVE,$t[1],$t[2])
mousemove($t[1]+($t[3]/2),$t[2]+$t[4]/2)
mouseclick("left")
sleep(2000)

Consolewrite("**** try to click on the clock (TrayClockWClass) button of the taskbar ****" & @CRLF)
if isobj($oClock) Then
    consolewrite("Clock found" & @crlf)
Else
    consolewrite("Clock not found" & @crlf)
EndIf

dim $pLegacy
;~ $oClock.getCurrentPattern($UIA_InvokePatternId, $pInvoke)
$oLegacyP=_UIA_getPattern($oClock,$UIA_LegacyIAccessiblePatternId)
$oLegacyP.dodefaultaction()

dim $oClock2
$oClock2=_UIA_getFirstObjectOfElement($UIA_odesktop,"classname:=ClockFlyoutWindow",$TreeScope_Children)
_UIA_dumpthemall($oClock2,$treescope_subtree)

consolewrite("Check log.txt for the output as we run in debug logging mode automatically" & @crlf)

Exit

