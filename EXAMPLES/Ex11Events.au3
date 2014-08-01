#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "CUIAutomation2.au3"
#include "UIAWrappers.au3"
HotKeySet("{ESC}", "terminate") ; Set ESC as a hotkey to exit the script.

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ Focus Changed Handler
Global $tFCEHandler
Global $oFCEHandler = UIA_ObjectFromTag("_MyHandler_", $dtagIUIAutomationFocusChangedEventHandler, $tFCEHandler)

$hr=$objUIAutomation.AddFocusChangedEventHandler(0, $oFCEHandler())
$running=true

while $running=true
    consolewrite("running")
    sleep(100)
WEnd
    consolewrite("Exiting2")
$objUIAutomation.RemoveFocusChangedEventHandler($oFCEHandler())
    consolewrite("Exiting3")
$objUIAutomation.RemoveAllEventHandlers()
    consolewrite("Exiting4")
exit

; The End
Func Terminate()
    consolewrite("Exiting")
    $running=false
;~  Exit 0
EndFunc   ;==>Terminate

; Handler methods. "_MyHandler_" is the specified prefix:
Func _MyHandler_QueryInterface($pSelf, $pRIID, $pObj)
    Local $tStruct = DllStructCreate("ptr", $pObj)
    Switch _WinAPI_StringFromGUID($pRIID)
        Case $sIID_IUnknown, $sIID_IUIAutomationFocusChangedEventHandler
        Case Else
            ConsoleWrite(@CRLF)
            Return 0x80004002 ; E_NOINTERFACE
    EndSwitch
    DllStructSetData($tStruct, 1, $pSelf)
    Return 0 ; S_OK
EndFunc
Func _MyHandler_AddRef($pSelf)
    #forceref $pSelf
    Return 1
EndFunc
Func _MyHandler_Release($pSelf)
    #forceref $pSelf
    Return 1
EndFunc
Func _MyHandler_HandleFocusChangedEvent($pSelf, $pElem)
    consolewrite("Focus changing")
    #forceref $pSelf
    If $pElem Then
        Local $oUIElement = ObjCreateInterface($pElem, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
;~         Local $sFocused
;~         $oUIElement.CurrentClassName($sFocused)
   $oUIElement.addref()
        ConsoleWrite("Title is: <" &  _UIA_getPropertyValue($oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
                    & "Class   := <" & _UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
                    & "controltype:= <" &  _UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB  _
                    & " (" &  hex(_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId)) &  ")" & @TAB & @CRLF)
    EndIf
;~     Return 0 ; S_OK
EndFunc