#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <debug.au3>
#include "CUIAutomation2.au3"
#include "..\UIAWrappers.au3"
HotKeySet("{ESC}", "Terminate")

;~ Turn debugging UIA on by default see log.txt for output
;~ _UIA_setVar("Global.Debug",true)
;~ _UIA_setVar("Global.Highlight",true) ;- Highlights object when found

;~ Set the system under test variables
_UIA_setVar("SUT1.Folder",@programfilesdir & "\Windows Media Player")
_UIA_setVar("SUT1.Workingdir", @programfilesdir & "\Windows Media Player\")
_UIA_setVar("SUT1.EXE","wmplayer.exe")
_UIA_setVar("SUT1.Fullname", _UIA_getVar("SUT1.Folder") & "\"& _UIA_getVar("SUT1.EXE"))
_UIA_setVar("SUT1.Parameters","")
_UIA_setVar("SUT1.Processname","wmplayer.exe")
_UIA_setVar("SUT1.Windowstate",@SW_RESTORE)

_UIA_setVar("SUT1.Fullname", _UIA_getVar("SUT1.Folder") & "\"& _UIA_getVar("SUT1.EXE"))
_UIA_setVar("SUT1.Parameters","")
_UIA_setVar("SUT1.Processname","wmplayer.exe")

;~ Set the system under test objects to recognize
_UIA_setVar("WMP.mainwindow","classname:=WMPlayerApp")
_UIA_setVar("WMP.Playlists","classname:=SysTreeView32")
_UIA_setVar("WMP.Firstlist","name:=(Afspeellijst.*)|(Playlist.*)")
_UIA_setVar("WMP.Playbutton","name:=playGlyph")
_UIA_setVar("WMP.Volumebutton","name:=Volume")

;~ Start system under test
_UIA_DEBUG("Starting system under test" & @CRLF)
_UIA_StartSUT("SUT1")

;~ Get the main WMP element
;~ _UIA_DEBUG("Action 1 Finding main window" & @CRLF)
;~ $oWMP=_UIA_getFirstObjectOfElement($oDesktop, _UIA_getVar("WMP.mainwindow"), $treescope_children)
;~ $oWMP.setfocus()

;~ Action on the logical object as defined
_UIA_action("WMP.MAINWINDOW","setfocus")
;~ Retrieve the actual object from the runtime type information
$oWMP=_UIA_getVar("RTI.WMP.mainwindow")

;~ Get the playlists
;~ _UIA_DEBUG("Action 2 Finding playlists" & @CRLF)
$oPL=_UIA_getFirstObjectOfElement($oWMP, _UIA_getVar("WMP.playlists"), $treescope_subtree)
$oFirstPL=_UIA_getObjectByFindAll($oPL, _UIA_getVar("WMP.Firstlist"), $treescope_subtree)

;~ See if its expanded/collapsed
_UIA_DEBUG("Action 3 Expanding if needed" & @CRLF)
dim $state
;~ Get the pattern
$oExpandP=_UIA_getpattern($oFirstPL,$UIA_ExpandCollapsePatternId)
if isobj($oExpandP) Then
;~ Get the state
;~ Global Const $ExpandCollapseState_Collapsed=0
;~ Global Const $ExpandCollapseState_Expanded=1
;~ Global Const $ExpandCollapseState_PartiallyExpanded=2
;~ Global Const $ExpandCollapseState_LeafNode=3
    $oExpandP.CurrentExpandCollapseState($state)
    if $state=$ExpandCollapseState_Collapsed Then
;~         _UIA_action("WMP.Firstlist","leftdoubleclick")
         _UIA_action($oFirstPL,"leftdoubleclick")
    EndIf
endif

;~ _UIA_DEBUG("Action 4 Starting with the playbutton" & @CRLF)
;~ $oPlayButton=_UIA_getObjectByFindAll($oWMP, _UIA_getVar("WMP.Playbutton"), $treescope_subtree)
_UIA_action("WMP.Playbutton","left")
 sleep(500)

_UIA_DEBUG("Action 5 And finding the volume" & @CRLF)
$oVolumeButton=_UIA_getObjectByFindAll($oWMP, _UIA_getVar("WMP.Volumebutton"), $treescope_subtree)
$oValueP=_UIA_getpattern($oVolumeButton,$UIA_ValuePatternId)

if isobj($oValueP) Then
dim $volume
    $oValuep.currentvalue($volume)
    _UIA_Debug("Volume is " & $volume & @CRLF)
EndIf

; The End
Func Terminate()
    consolewrite("Exiting")
    $running=false
;~  Exit 0
EndFunc   ;==>Terminate