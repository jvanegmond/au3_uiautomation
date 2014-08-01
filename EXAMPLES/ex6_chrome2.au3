;~ Example 6 Demonstrates all stuff within chrome to
;~ navigate html pages,
;~ find hyperlink,
;~ click hyperlink,
;~ find picture,
;~ click picture,    "name:=Search...; indexrelative:=2" means find an element with name = Search... but then just skip 2 elements further
;~ enter data in inputbox
;~
;~ Made a lot more comments and failure to show when an object is not retrieved/found the hierarchy of the tree is written to the console
;~ Lots of optimizations could be done by using the cachefunctions (less interprocess communication) but on my machine it runs at
;~ a very acceptable speed
;~ In top of script put the text in your local language of the operating system

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <debug.au3>

#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

consolewrite("Example constants please change text to english or other language to identify controls" & @crlf)

;~ Make this language specific
const $cToolbarByName = "name:=Google Chrome Toolbar"
const $cAddressBarByName = "name:=Adres- en zoekbalk"
const $cChromeNewTabByName="name:=Nieuw tabblad"

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

;~ Find the chrome window
$oChrome=_UIA_getFirstObjectOfElement($UIA_oDesktop,"class:=Chrome_WidgetWin_1", $treescope_children)
if not isobj($oChrome) Then
    _UIA_DumpThemAll($UIA_oDesktop,$treescope_children)
EndIf

;~ Make sure chrome is front window
$oChrome.setfocus()

if isobj($oChrome) Then
    consolewrite("Action 1" & @CRLF)

;~  get the chrome toolbar
;~  $oChromeToolbar=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_ToolBarControlTypeId, $treescope_subtree)
    $oChromeToolbar=_UIA_getFirstObjectOfElement($oChrome,$cToolbarByName, $treescope_subtree)
    if not isobj($oChromeToolbar) Then
        _UIA_DumpThemAll($oChrome,$treescope_subtree)
    EndIf


consolewrite("Action 2" & @CRLF)
;~  get the addressbar
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"class:=Chrome_OmniboxView", $treescope_children) ;worked in chrome 28
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"controltype:=" & $UIA_EditControlTypeId , $treescope_subtree) ;works in chrome 29
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"name:=Adres- en zoekbalk"  , $treescope_children) ;works in chrome 29
    $oChromeAddressBar=_UIA_getObjectByFindAll($oChromeToolbar, $cAddressBarByName  , $treescope_subtree) ;works in chrome 29
    if not isobj($oChromeAddressbar) Then
        _UIA_DumpThemAll($oChromeToolbar,$treescope_subtree)
    EndIf

;~  $oValueP=_UIA_getpattern($oChromeAddressBar,$UIA_ValuePatternId)
;~  sleep(2000)

;~  get the value of the addressbar
;~  $myText=""
;~  $oValueP.CurrentValue($myText)
;~  consolewrite("address: " & $myText & @CRLF)

consolewrite("Action 3" & @CRLF)
;~ Get reference to the tabs
    $oChromeTabs=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_TabControlTypeId, $treescope_subtree)
    if not isobj($oChromeTabs) Then
        _UIA_DumpThemAll($oChrome,$treescope_subtree)
    EndIf

;~ Lets open a new tab within chrome

consolewrite("Action 4" & @CRLF)
;~  $oChromeNewTab= _UIA_getFirstObjectOfElement($oChromeTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
    $oChromeNewTab= _UIA_getObjectByFindAll($oChromeTabs, $cChromeNewTabByName,$treescope_subtree)
    if not isobj($oChromeNewTab) Then
        _UIA_DumpThemAll($oChromeTabs,$treescope_subtree)
    EndIf
    _UIA_action($oChromeNewtab,"leftclick")
    sleep(500)

consolewrite("Action 4a" & @CRLF)
$oChromeAddressBar=_UIA_getObjectByFindAll($oChromeToolbar, $cAddressBarByName  , $treescope_subtree) ;works in chrome 29

if not isobj($oChromeAddressbar) Then
_UIA_DumpThemAll($oChromeToolbar,$treescope_subtree)
EndIf

$t=stringsplit(_UIA_getPropertyValue($oChromeAddressBar, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
_UIA_action($oChromeAddressBar,"leftclick")

;~ _UIA_action($oChromeAddressBar,"leftclick")
_UIA_action($oChromeAddressBar,"setvalue using keys","chrome://accessibility/{ENTER}")


consolewrite("Action 4b" & @CRLF)
;~ give some time to open website
sleep(2000)
$oDocument=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
if not isobj($oDocument) Then
_UIA_DumpThemAll($oChrome,$treescope_subtree)
Else
$t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
EndIf

sleep(500)

consolewrite("Action 4c retrieve document after clicking a hyperlink" & @CRLF)
$oForumLink=_UIA_getObjectByFindAll($oDocument,"name:=On", $treescope_subtree)
if not isobj($oForumLink) Then
consolewrite("*** Scripting will fail as accessibility is off ****")
MsgBox(4096, "Accessibility warning", "Accessibility is turned off, put it on by clicking on Off after Global accessibility mode", 10)
_UIA_DumpThemAll($oDocument,$treescope_subtree)
EndIf

consolewrite("Action 4d" & @CRLF)
;~ $oChromeNewTab= _UIA_getFirstObjectOfElement($oChromeTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
$oChromeNewTab= _UIA_getObjectByFindAll($oChromeTabs, $cChromeNewTabByName,$treescope_subtree)
if not isobj($oChromeNewTab) Then
_UIA_DumpThemAll($oChromeTabs,$treescope_subtree)
EndIf
_UIA_action($oChromeNewtab,"leftclick")
sleep(500)
consolewrite("Action 5" & @CRLF)
$oChromeAddressBar=_UIA_getObjectByFindAll($oChromeToolbar, $cAddressBarByName , $treescope_subtree) ;works in chrome 29
if not isobj($oChromeAddressbar) Then
_UIA_DumpThemAll($oChromeToolbar,$treescope_subtree)
EndIf
$t=stringsplit(_UIA_getPropertyValue($oChromeAddressBar, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
_UIA_action($oChromeAddressBar,"leftclick")
_UIA_action($oChromeAddressBar,"setvalue using keys","www.autoitscript.com/{ENTER}")
consolewrite("Action 6" & @CRLF) ;~ give some time to open website
sleep(2000)
$oDocument=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
if not isobj($oDocument) Then
_UIA_DumpThemAll($oChrome,$treescope_subtree)
Else
$t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
EndIf
sleep(500)
consolewrite("Action 7 retrieve document after clicking a hyperlink" & @CRLF)
$oForumLink=_UIA_getObjectByFindAll($oDocument,"name:=Forum", $treescope_subtree)
if not isobj($oForumLink) Then
_UIA_DumpThemAll($oDocument,$treescope_subtree)
EndIf
_UIA_action($oForumLink,"invoke")
sleep(3000)
consolewrite("Action 8 first refresh the document control" & @CRLF)
$oDocument=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)

if not isobj($oDocument) Then
_UIA_DumpThemAll($oChrome,$treescope_subtree)
Else
$t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
EndIf ;~ Now we get the searchfield
$oEdtSearchForum=_UIA_getObjectByFindAll($oDocument,"name:=Search...", $treescope_subtree)
if not isobj($oEdtSearchForum) Then
_UIA_DumpThemAll($oDocument,$treescope_subtree)
EndIf
_UIA_action($oEdtSearchForum,"focus")
_UIA_action($oEdtSearchForum,"setvalue using keys","Chrome can easy be automated with ui automation") ; {ENTER}")
sleep(500)
;~ Exit
;~ Now we press the button, see relative syntax used as the button seems not to have a name its just 2 objects further then search field
$oBtnSearch=_UIA_getObjectByFindAll($oDocument,"name:=Search...; indexrelative:=2", $treescope_subtree)
if not isobj($oBtnSearch) Then
_UIA_DumpThemAll($oDocument,$treescope_subtree)
EndIf
$t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
sleep(1000)
_UIA_action($oBtnSearch,"invoke")
sleep(2000)
;~ consolewrite("Action 9 first refresh the document control" & @CRLF)
$oDocument=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
if not isobj($oDocument) Then
_UIA_DumpThemAll($oDocument,$treescope_subtree)
EndIf
$oHyperlink=_UIA_getObjectByFindAll($oDocument,"name:=controlsend doesn't work", $treescope_subtree)
if not isobj($oBtnSearch) Then
_UIA_DumpThemAll($oDocument,$treescope_subtree)
EndIf
sleep(1000)
_UIA_action($oHyperlink,"invoke")
sleep(2000)
EndIf
exit
