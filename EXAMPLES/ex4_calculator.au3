;~ Example 4 that demonstrates on the calculator
;~ How to click
;~ How to find buttons (be aware that you have to change the captions to language of your windows)
;~ How to click in the menu (copy result to the clipboard)
;~    then it uses notepad to demonstrate
;~ How to set a value on a textbox with the value pattern
;~
;~ Attention points
;~ Examples are build on exact match of text (so this includes tab and Ctrl+C values), later I will
;~ make some function that can find with regexp or non exact match (need treewalker for that)
;~ Timing / sleep is sometimes needed to give the system time to popup the menus / execute the action
;~ Focus of application is sometimes to be set (and sometimes not as you look on the clicking of the
;~ buttons it will even happen when there is a screen in front of the calculator)

#include "..\UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

consolewrite("Example text is for dutch calculator so please change text to english or other language to identify controls" & @crlf)

;~ Translate below to correct language
$cCalcClassName="CalcFrame"
$cNotepadClassName="Notepad"

$cButton1="1"
$cButtonAdd="Optellen"
$cButton3="3"
$cButtonEqual="Is gelijk aan"
$cButtonEdit="Bewerken"

;~ Start the calculator and notepad
run("calc.exe")
run("notepad.exe")

$oCalc=_UIA_getFirstObjectOfElement($UIA_oDesktop,"class:=" & $cCalcClassname, $treescope_children)
$oNotepad=_UIA_getFirstObjectOfElement($UIA_oDesktop,"class:="& $cNotepadClassName, $treescope_children)

if isobj($oCalc) Then

;~ You can comment this out just there to get the names of whats available under the calc window
_UIA_DumpThemAll($oCalc,$treescope_subtree)

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButton1, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButtonAdd, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButton3, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButtonEqual, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButtonEdit, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    sleep(1500)
;~  findThemAll($oCalc,$treescope_subtree)
;~  sleep(1000)

;~ Use a regular expression to identify the copy choice as there are special characters/tabs etc in the name
;~     $sText="Kopiëren.*"    ;Copy
;~     $sText="name:=((Copy.*)|(Kopi.*))"    ;Copy
    $sText="((Copy.*)|(Kopi.*))"    ;Copy
    $oButton=_UIA_getObjectByFindAll($oCalc,"name:=" & $sText, $treescope_subtree)
    if isobj($oButton) Then
        consolewrite("Menuitem is there")
    Else
        consolewrite("Menuitem is NOT there")
    EndIf
    sleep(1000)

    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke
    sleep(500)

EndIf

if isobj($oNotepad) Then

$myText=clipget()

;~ You can comment this out
_UIA_dumpThemAll($oNotepad,$treescope_subtree)
    sleep(1000)

;~ Activate notepad and put the value in the edit text control of notepad
    $oNotepad.setfocus()

    $sText="Edit"
    $oEdit=_UIA_getFirstObjectOfElement($oNotepad,"classname:=" & $sText, $treescope_subtree)
    $oValueP=_UIA_getpattern($oEdit,$UIA_ValuePatternId)
    $oValueP.SetValue($myText)

EndIf

Exit

