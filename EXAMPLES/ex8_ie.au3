;~ Example 8 The other major browser Internet Explorer automated (made on Example 6 and 7)
;~
;~ This demonstrates that with almost identical code you can automate 3 major browsers
;~
;~ Small changes compared to the Fire fox example
;~ 1. Renamed FF to IE
;~ 2. Some constants defined differently to map with IE names
;~ navigate html pages,
;~ find hyperlink,
;~ click hyperlink,
;~ find picture,
;~ click picture,
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
#include "CUIAutomation2.au3"
#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ Make this language specific
const $cToolbarByName = "classname:=ReBarWindow32" ;Navigation bar
const $cAddressBarByName = "name:=Adres en.*"
const $cIENewTabByName="name:=Nieuw.*"
const $cBrowser="classname:=IEFrame"
;~ const $cDocumentWindow="controltype:=" & $UIA_DocumentControlTypeId
const $cDocumentWindow="classname:=Internet Explorer_Server"
const $cBoardItem="name:=controlsend doesn't work"
const $cEdtSearch="name:=Search.*"
const $cSearchButton="name:=Search.*; indexrelative:=3"

$strIEExeFolder=@programfilesdir & "\Internet Explorer\"
$strIEStartup=""
$strIEExe=$strIEExeFolder & "iexplore.exe "

;~ Start chrome
if fileexists($strIEExe) Then
    if not processexists("iexplore.exe") Then
        run($strIEExe & $strIEStartup,"", @SW_MAXIMIZE )
        ProcessWait("iexplore.exe")
        ;~ Just to give some time to start
        sleep(10000)
    endif
Else
    consolewrite("No clue where to find IE on your system, please start manually:" & @CRLF )
    consolewrite($strIEExe & $strIEStartup & @CRLF)
EndIf

;~ Find the IE window
$oIE=_UIA_getFirstObjectOfElement($UIA_oDesktop, $cBrowser, $treescope_children)
if not isobj($oIE) Then
    _UIA_DumpThemAll($UIA_oDesktop,$treescope_children)
EndIf

;~ Make sure chrome is front window
$oIE.setfocus()

if isobj($oIE) Then
    consolewrite("Action 1" & @CRLF)

;~  get the IE toolbar
;~  $oIEToolbar=_UIA_getFirstObjectOfElement($oIE,"controltype:=" & $UIA_ToolBarControlTypeId, $treescope_subtree)
    $oIEToolbar=_UIA_getFirstObjectOfElement($oIE,$cToolbarByName, $treescope_subtree)
    if not isobj($oIEToolbar) Then
        _UIA_DumpThemAll($oIE,$treescope_subtree)
    EndIf

consolewrite("Action 2" & @CRLF)
;~  get the addressbar
;~  $oIEAddressBar=_UIA_getFirstObjectOfElement($oIEToolbar,"class:=Chrome_OmniboxView", $treescope_children) ;worked in chrome 28
;~  $oIEAddressBar=_UIA_getFirstObjectOfElement($oIEToolbar,"controltype:=" & $UIA_EditControlTypeId , $treescope_subtree) ;works in chrome 29
;~  $oIEAddressBar=_UIA_getFirstObjectOfElement($oIEToolbar,"name:=Adres- en zoekbalk"  , $treescope_children) ;works in chrome 29
    $oIEAddressBar=_UIA_getObjectByFindAll($oIEToolbar, $cAddressBarByName  , $treescope_subtree) ;works in chrome 29
    if not isobj($oIEAddressbar) Then
        _UIA_DumpThemAll($oIEToolbar,$treescope_subtree)
    EndIf

;~  $oValueP=_UIA_getpattern($oIEAddressBar,$UIA_ValuePatternId)
;~  sleep(2000)

;~  get the value of the addressbar
;~  $myText=""
;~  $oValueP.CurrentValue($myText)
;~  consolewrite("address: " & $myText & @CRLF)

consolewrite("Action 3" & @CRLF)
;~ Get reference to the tabs
    $oIETabs=_UIA_getFirstObjectOfElement($oIE,"controltype:=" & $UIA_TabControlTypeId, $treescope_subtree)
    if not isobj($oIETabs) Then
        _UIA_DumpThemAll($oIE,$treescope_subtree)
    EndIf

;~ Lets open a new tab within chrome

consolewrite("Action 4" & @CRLF)
;~  $oIENewTab= _UIA_getFirstObjectOfElement($oIETabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
    $oIENewTab= _UIA_getObjectByFindAll($oIETabs, $cIENewTabByName,$treescope_subtree)
    if not isobj($oIENewTab) Then
        _UIA_DumpThemAll($oIETabs,$treescope_subtree)
    EndIf
;~  _UIA_action($oIENewtab,"leftclick")
;~  sleep(500)

consolewrite("Action 5" & @CRLF)
    $oIEAddressBar=_UIA_getObjectByFindAll($oIEToolbar, $cAddressBarByName  , $treescope_subtree) ;works in chrome 29

    if not isobj($oIEAddressbar) Then
        _UIA_DumpThemAll($oIEToolbar,$treescope_subtree)
    EndIf

    $t=stringsplit(_UIA_getPropertyValue($oIEAddressBar, $UIA_BoundingRectanglePropertyId),";")
    _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    _UIA_action($oIEAddressBar,"leftclick")
    _UIA_action($oIEAddressBar,"setvalue using keys","www.autoitscript.com/{ENTER}")

consolewrite("Action 6" & @CRLF)

;~  give some time to open website
    sleep(2000)
    $oDocument=_UIA_getFirstObjectOfElement($oIE,$cDocumentWindow, $treescope_subtree)
    if not isobj($oDocument) Then
        _UIA_DumpThemAll($oIE,$treescope_subtree)
    Else
        $t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
        _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    EndIf

    sleep(500)

consolewrite("Action 7 retrieve document after clicking a hyperlink" & @CRLF)
    $oForumLink=_UIA_getObjectByFindAll($oDocument,"name:=Forum", $treescope_subtree)
;~ All document items
    if not isobj($oForumLink) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    _UIA_action($oForumLink,"leftclick")
    sleep(3000)

consolewrite("Action 8 first refresh the document control" & @CRLF)

    $oDocument=_UIA_getFirstObjectOfElement($oIE, $cDocumentWindow , $treescope_subtree)
    if not isobj($oDocument) Then
        _UIA_DumpThemAll($oIE,$treescope_subtree)
    Else
        $t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
        _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    EndIf

;~ Now we get the searchfield

    $oEdtSearchForum=_UIA_getObjectByFindAll($oDocument,$cEdtSearch, $treescope_subtree)
    if not isobj($oEdtSearchForum) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    _UIA_action($oEdtSearchForum,"focus")
    _UIA_action($oEdtSearchForum,"setvalue using keys","Chrome can easy be automated with ui automation") ; {ENTER}")
    sleep(500)

;~ Exit
;~ Now we press the button, see relative syntax used as the button seems not to have a name its just 2 objects further then search field
    $oBtnSearch=_UIA_getObjectByFindAll($oDocument,$cSearchButton, $treescope_subtree)
    if not isobj($oBtnSearch) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    $t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
    _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    sleep(1000)
    _UIA_action($oBtnSearch,"leftclick")
    sleep(2000)

;~ consolewrite("Action 9 first refresh the document control" & @CRLF)

    $oDocument=_UIA_getFirstObjectOfElement($oIE,$cDocumentWindow  , $treescope_subtree)
    if not isobj($oDocument) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    $oHyperlink=_UIA_getObjectByFindAll($oDocument,$cBoardItem, $treescope_subtree)
    if not isobj($oBtnSearch) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    sleep(1000)
    _UIA_action($oHyperlink,"leftclick")
    sleep(2000)

EndIf

exit

