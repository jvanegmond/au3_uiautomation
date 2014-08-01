;~ Example 10 Automating mach 3 (AFX windows and other hard to get recognized by AutoIT)
;~ http://www.autoitscript.com/forum/topic/155857-automation-not-working-with-some-software/
;~ http://www.machsupport.com/software/mach3/

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <debug.au3>
;~ #include "CUIAutomation2.au3"
#include "UIAWrappers.au3"
HotKeySet("{ESC}", "Terminate")

;~ Turn debugging UIA on by default, dumps most details to consolewindow for the moment, later will use a logfile
;~ _UIA_setVar("Global.Debug",true)
;~ _UIA_setVar("Global.Highlight",true) ;- Highlights object when found

;~ Set the system under test variables
_UIA_setVar("SUT1.Folder","C:\Mach3")
_UIA_setVar("SUT1.Workingdir","C:\Mach3\")
_UIA_setVar("SUT1.EXE","Mach3.exe")
_UIA_setVar("SUT1.Fullname", _UIA_getVar("SUT1.Folder") & "\"& _UIA_getVar("SUT1.EXE"))
_UIA_setVar("SUT1.Parameters","/p Mach3Mill")
_UIA_setVar("SUT1.Processname","mach3.exe")
_UIA_setVar("SUT1.Windowstate",@SW_RESTORE)

_UIA_setVar("SUT1.Fullname", _UIA_getVar("SUT1.Folder") & "\"& _UIA_getVar("SUT1.EXE"))

;~ Set the system under test objects to recognize and abstract logical and physical names for readability in main script

_UIA_setVar("MACH3.mainwindow","classname:=Afx:00400000:b:00010003:00000006.*")
;~ _UIA_setVar("MACH3.mainwindow","name:=Mach3 CNC  Demo index:=1")

_UIA_setVar("MACH3.editgcode","name:=Edit G-Code")
_UIA_setVar("MACH3.btnCyclestart","automationid:=8142")
_UIA_setVar("MACH3.btnStop","automationid:=8140")
_UIA_setVar("MACH3.btnRewind","automationid:=8295")

_UIA_setVar("MACH3.mnuFile","name:=((File)|(Bestand));index:=2")
_UIA_setVar("MACH3.mnuOpen","name:=Load.*")

_UIA_setVar("MACH3.dlgOpen","name:=Open*")
_UIA_setVar("MACH3.dlgOpen.edtFilename","name:=((Filename:)|(Bestandsnaam:));indexrelative:=2")
_UIA_setVar("MACH3.dlgOpen.btnOpen","name:=Open*;index:=6")

_UIA_setVar("NOTEPAD.mainwindow","classname:=Notepad")
_UIA_setVar("NOTEPAD.edit","classname:=Edit")
_UIA_setVar("NOTEPAD.mnuFile","name:=((File)|(Bestand))")
_UIA_setVar("NOTEPAD.mnuSave","name:=((Save.*)|(Opslaan.*))")
_UIA_setVar("NOTEPAD.btnClose","name:=((Close)|(Sluiten))")

_UIA_setVar("NOTEPAD.dlgSave","name:=((Save as.*)|(Opslaan als.*))")
_UIA_setVar("NOTEPAD.dlgSave.edtFilename","name:=((Filename:)|(Bestandsnaam:));indexrelative:=1")
_UIA_setVar("NOTEPAD.dlgSave.btnSave","name:=((Save)|(Opslaan));ControlType:=Button")
_UIA_setVar("NOTEPAD.dlgSave.btnYes","name:=((Yes)|(Ja));ControlType:=Button")

;~ Start system under test
_UIA_DEBUG("Starting system under test" & @CRLF)
_UIA_StartSUT("SUT1")
_UIA_DEBUG("SUT is started" & @CRLF)

_UIA_DEBUG("PID of SUT1 is " & _UIA_getVar("RTI.SUT1.PID") & @CRLF)
_UIA_DEBUG("HWND of SUT1 is " & _UIA_getVar("RTI.SUT1.HWND") & @CRLF)

;~ Main script
_UIA_DEBUG("*** Main script started ***" & @CRLF)
_UIA_action("MACH3.mainwindow","focus")

;~ _UIA_DumpThemAll(_UIA_getVar("RTI.MACH3.MAINWINDOW"),$treescope_subtree)

;~ _UIA_action("MACH3.editgCode", "left")
_UIA_action("name:=Edit G-Code", "left")
;~ _UIA_action("Edit G-Code", "left")

_UIA_action("NOTEPAD.mainwindow","focus")
_UIA_action("NOTEPAD.edit","sendkeys","f600{ENTER}g1 Z-2{ENTER}g1 y-13.5{ENTER}g1 z-14{ENTER}g1 z-26{ENTER}g1 z-38{ENTER}g1 y-35{ENTER}")
_UIA_action("NOTEPAD.mnuFile","left")
_UIA_action("NOTEPAD.mnuSave","left")
_UIA_action("NOTEPAD.dlgSave.edtFilename","sendkeys","demofile.txt")
_UIA_action("NOTEPAD.dlgSave.btnSave","left")
_UIA_action("NOTEPAD.dlgSave.btnYes","left")
_UIA_action("NOTEPAD.btnClose","left")

_UIA_action("MACH3.mainwindow","focus")
_UIA_action("MACH3.mnuFile","left")
_UIA_action("MACH3.mnuOpen","left")
_UIA_action("MACH3.dlgOpen.edtFilename","sendkeys","demofile.txt")
_UIA_action("MACH3.dlgOpen.btnOpen","left")

sleep(3000) ;~ Just 3 seconds to be able to load the script

_UIA_action("MACH3.btnStop","left")
sleep(1000) ;~ Just some slowing down, seems to go to quick
_UIA_action("MACH3.btnRewind","left")
sleep(1000) ;~ Just some slowing down, seems to go to quick
_UIA_action("MACH3.btnCycleStart","left")
sleep(1000) ;~ Just some slowing down, seems to go to quick

; The End
Func Terminate()
	consolewrite("Exiting")
    $running=false
;~ 	Exit 0
EndFunc   ;==>Terminate