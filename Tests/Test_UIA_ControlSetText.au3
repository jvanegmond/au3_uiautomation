#include "..\UIAWrappers.au3"
#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

Global $UIA_oUIAutomation

Local $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd

$pid = Run("notepad.exe")
WinWait("Untitled - Notepad")
$hWnd = WinGetHandle("Untitled - Notepad")

$oNotepad = _UIA_ControlSetText($hWnd, "[CLASS:Edit; INSTANCE:1]", "Hello World!")

Sleep(200)

AssertAreEqual("Hello World!", ControlGetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]"))

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd

; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
    ; Do anything here.
    ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
            @TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
            @TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
            @TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
            @TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
            @TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
            @TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
            @TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
            @TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
            @TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc
