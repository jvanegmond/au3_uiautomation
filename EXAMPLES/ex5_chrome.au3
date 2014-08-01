;~ Example 5 Automating chrome
;~ This example shows how to use UI Automation with chrome (later an example will come to put stuff in the html page)
;~ 1. Have chrome started with "--force-renderer-accessibility"
;~ 2. Check with chrome://accessibility in the adress bar if accessibility is on/off, turn it on
;~ a. or close all browsers and change in script the run command to the right path of the chrome.exe
;~
;~ Apparently google changed some stuff in chrome version 29 and seems not allways to return classname properly so sometimes
;~ harder to get the right element

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <debug.au3>

#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

$strChromeExeFolder=@UserProfileDir & "\AppData\Local\Google\Chrome\Application\"
$strChromeStartup="--force-renderer-accessibility"
$strChromeExe=$strChromeExeFolder & "chrome.exe "

;~ Start chrome
if fileexists($strChromeExe) Then
    if not processexists("chrome.exe") Then
        run($strChromeExe & $strChromeStartup,"", @SW_MAXIMIZE )
        ProcessWait("chrome.exe")
        ;~ Just to give some time to start
        sleep(10000)
    endif
Else
    consolewrite("No clue where to find chrome on your system, please start manually:" & @CRLF )
    consolewrite($strChromeExe & $strChromeStartup & @CRLF)
EndIf

$oChrome=_UIA_getFirstObjectOfElement($UIA_oDesktop,"class:=Chrome_WidgetWin_1", $treescope_children)
$oChrome.setfocus()
;~ _UIA_DumpThemAll($oDesktop,$treescope_children)

if isobj($oChrome) Then
;~  _UIA_DumpThemAll($oChrome,$treescope_children)


;~  get the toolbar
;~  $oChromeToolbar=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_ToolBarControlTypeId, $treescope_subtree)
$oChromeToolbar=_UIA_getFirstObjectOfElement($oChrome,"name:=Google Chrome Toolbar" , $treescope_subtree)
;~ _UIA_DumpThemAll($oChromeToolbar,$treescope_subtree)

;~  get the addressbar
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChrome,"class:=Chrome_OmniboxView", $treescope_children) ;worked in chrome 28
$oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"controltype:=" & $UIA_EditControlTypeId , $treescope_subtree) ;works in chrome 29
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChrome,"name:=Adres- en zoekbalk"  , $treescope_children) ;works in chrome 29

;~  _UIA_DumpThemAll($oChromeToolbar,$treescope_children)
$oValueP=_UIA_getpattern($oChromeAddressBar,$UIA_ValuePatternId)

;~  get the value of the addressbar
$myText=""
$oValueP.CurrentValue($myText)
consolewrite("address: " & $myText & @CRLF)
;~ Exit

;~ Click all tabs
$oChromeTabs=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_TabControlTypeId, $treescope_subtree)
 _UIA_DumpThemall($oChromeTabs,$treescope_children)


;~  Get result with findall function alternative could be the treewalker
    dim $pCondition, $pTrueCondition
	dim $pElements, $iLength

    $UIA_oUIAutomation.CreateTrueCondition($pTRUECondition)

    $oCondition=ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition,$dtagIUIAutomationCondition)

	$oChromeTabs.FindAll($treescope_children, $oCondition, $pElements)
    $oAutomationElementArray = ObjCreateInterFace($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	$oAutomationElementArray.Length($iLength)

    For $i = 0 To $iLength - 1; it's zero based
	$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
        $oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
        consolewrite( "Title is: <" &  _UIA_getPropertyValue($oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
   & "Class   := <" & _UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
& "controltype:= <" &  _UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB & @CRLF)
;~  Invoke or select them all
;~ Tricky as chrome seems to say it supports certain patterns but then they seem not to be implemented


;~ only tabs with content
if _UIA_getPropertyValue($oUIElement, $UIA_IsSelectionItemPatternAvailablePropertyId) = "True" Then
_UIA_action($oUIElement,"leftclick")
;~  $oSelectP=_UIA_getpattern($oUIElement,$UIA_SelectionItemPatternId)
;~  $oSelectP.Select()
EndIf
Next


;~ Lets open a new tab within chrome
$oChromeNewTab=_UIA_getFirstObjectOfElement($oChromeTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
_UIA_action($oChromeNewTab,"leftclick")

;~ Lets get the valuepattern of the addressbar
;~  $oLegacyP=_UIA_getpattern($oChromeAddressBar,$UIA_LegacyIAccessiblePatternId)
;~

_UIA_action($oChromeAddressBar,"leftclick")
_UIA_action($oChromeAddressBar,"setvalue using keys","www.autoitscript.com/{ENTER}")

EndIf


exit

