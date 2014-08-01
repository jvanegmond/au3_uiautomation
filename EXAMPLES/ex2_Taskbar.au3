;~ Example 2 Finding the taskbar and clicking on the start menu button
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "CUIAutomation2.au3"
#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

Consolewrite("**** All childs of the taskbar ****" & @CRLF)
$oTaskBar=_UIA_gettaskbar()
_UIA_DumpThemAll($otaskbar,$treescope_subtree)
dim $pInvoke, $oStart

Consolewrite("**** try to click on the start button of the taskbar ****" & @CRLF)
;~ Get the first item that has as the name: Starten change to Start for english or other text to match start button in local language
$oStart=_UIA_getFirstObjectOfElement($oTaskbar,"Starten", $treescope_subtree)
if isobj($oStart) Then
    consolewrite("Start button found" & @CRLF)
Else
    consolewrite("I bet the text has to change to Start instead of Starten")
EndIf

;~ Get the invoke pattern to click on the item
$oStart.getCurrentPattern($UIA_InvokePatternId, $pInvoke)
$oInvokeP=objCreateInterface($pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern)
$oInvokeP.invoke()


