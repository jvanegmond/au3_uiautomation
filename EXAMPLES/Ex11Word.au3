#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=N

;~ Start the system under test applications
_UIA_StartSUT("SUT1") ;~Calculator
_UIA_StartSUT("SUT2") ;~Notepad
_UIA_StartSUT("SUT3") ;~MS Word

;~ To be moved to UID (User interface definition) files
;~ Set the system under test UID objects to recognize
local $UID_WORD[4][2] = [ _
["mainwindow","classname:=OpusApp"], _
["btnZoeken","name:=((Zoeken.*)|(Find.*)); ControlType:=Button; acceleratorkey:=Ctrl\+F"] , _
["document","classname:=_WwG"], _
["btnBold","name:=((Vet)|(Bold))"] _
]
_UIA_setVarsFromArray($UID_Word,"Word.")

local $UID_CALC[7][2] = [ _
["mainwindow","classname:=CalcFrame"], _
["1","name:=1; controltype:=button"],  _
["2","name:=2; controltype:=button"] , _
["3","name:=3; controltype:=button"] , _
["BACKSPACE","AutomationId:=83"] , _
["mnuEdit","name:=((Edit)|(Bewerken)); controltype:=MenuItem"], _
["mnuCopy","name:=((Copy.*)|(Kopi.*)); controltype:=MenuItem"] _
]
_UIA_setVarsFromArray($UID_CALC,"Calculator.")

local $UID_NOTEPAD[4][2] = [ _
["mainwindow","classname:=Notepad"], _
["title","controltype:=50037"], _
["mnuEdit","name:=((Edit)|(Bewerken))"], _
["mnuPaste","name:=((Paste.*)|(Plak.*))"] _
]
_UIA_setVarsFromArray($UID_NOTEPAD,"Notepad.")

;~ To be moved to 1 or multiple scriptfiles
;- Set the script
;~ The actual script, 50,10 is only there if a lot of lines and parameters are needed

local $script[50][10]= [ _
["Word.Mainwindow","setfocus"], _
["Word.btnBold",   "click"], _
["word.document",  "sendkeys", "hello world"], _
["word.btnZoeken", "click"],  _
["calculator.mainwindow", "setfocus"], _
["calculator.1","click"], _
["calculator.2","click"], _
["calculator.3","click"], _
["calculator.backspace","click"], _
["calculator.mnuEdit","click"], _
["calculator.mnuCopy","click"], _
["notepad.mainwindow", "setfocus"], _
["notepad.mnuEdit","click"], _
["notepad.mnuPaste","click"], _
["notepad.mainwindow","setvalue", "hello world"] _
]

_UIA_launchScript($script)

Exit


