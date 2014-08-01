#include <GuiEdit.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "UIAWrappers.au3"
#include <Misc.au3>

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

dim $oldUIElement ; To keep track of latest referenced element

;~ Some references for reading
;~ [url=http://support.microsoft.com/kb/138518/nl]http://support.microsoft.com/kb/138518/nl[/url]  tagpoint structures attention point
;~ [url=http://www.autoitscript.com/forum/topic/128406-interface-autoitobject-iuiautomation/]http://www.autoitscript.com/forum/topic/128406-interface-autoitobject-iuiautomation/[/url]
;~ [url=http://msdn.microsoft.com/en-us/library/windows/desktop/ff625914(v=vs.85).aspx]http://msdn.microsoft.com/en-us/library/windows/desktop/ff625914(v=vs.85).aspx[/url]

HotKeySet("{ESC}", "Close") ; Set ESC as a hotkey to exit the script.
HotKeySet("^w", "GetElementInfo") ; Set Hotkey Ctrl+M to get some basic information in the GUI

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Form1", 1024, 768, 192, 124)
$Edit1 = GUICtrlCreateEdit("", 10, 10, 600, 700)
;~ $Edit1 = GUICtrlCreateEdit("", 10, 10, 10, 10)
$Label1 = GUICtrlCreateLabel("Ctrl+W to capture information", 640,10,600,25)
$Label2 = GUICtrlCreateLabel("Escape to exit", 640,45,600,25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

_UIA_Init()

; Run the GUI until the dialog is closed
While true
$msg = GUIGetMsg()
sleep(100)
;~ if _ispressed(01) Then
;~ getelementinfo()
;~ endif
If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd

Func GetElementInfo()
Local $hWnd
Local $tStruct = DllStructCreate($tagPOINT) ; Create a structure that defines the point to be checked.
;~ Local $tStruct = DllStructCreate("INT64,INT64")
;~ Local $tStruct =_AutoItObject_DllStructCreate($tagPoint)

ToolTip("")
Global $UIA_oUIAutomation			;The main library core CUI automation reference
Global $UIA_oDesktop, $UIA_pDesktop		 ;Desktop will be frequently the starting point

Global $UIA_oUIElement, $UIA_pUIElement  ;Used frequently to get an element
Global $UIA_oTW, $UIA_pTW		 ;Generic treewalker which is allways available

$x=MouseGetPos(0)
$y=MouseGetPos(1)
DllStructSetData($tStruct, "x", $x)
DllStructSetData($tStruct, "y", $y)
consolewrite(DllStructGetData($tStruct,"x") & DllStructGetData($tStruct,"y"))

;~ consolewrite("Mouse position is retrieved " & @crlf)
$UIA_oUIAutomation.ElementFromPoint($tStruct,$UIA_pUIElement )
;~ $objUIAutomation.ElementFromPoint(DllStructGetPtr($tStruct),$pUIElement)
;~ consolewrite("Element from point is passed, trying to convert to object ")
$oUIElement = objcreateinterface($UIA_pUIElement,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)

$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
$oTW=ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
    If IsObj($oTW) = 0 Then
        msgbox(1,"UI automation treewalker failed", "UI Automation failed failed",10)
    EndIf

local $parentHandle

$oTW.getparentelement($oUIElement,$parentHandle)
$objParent=objcreateinterface($parentHandle,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
If IsObj($objParent) = 0 Then
	msgbox(1,"No parent", "UI Automation failed failed",10)
EndIf

if isobj($oldUIElement) Then
if $oldUIElement=$oUIElement then
return
endif
endif
_WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN) ; Clears Red outline graphics.
GUICtrlSetData($Edit1, "Mouse position is retrieved " & $x & "-" & $y & @CRLF)
$oldElement=$oUIElement

If IsObj($oUIElement) Then
;~  ConsoleWrite("At least we have an element "  & "[" & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & "][" & _UIA_getPropertyValue($oUIElement, $UIA_ClassNamePropertyId) & "]" & @CRLF)
GUICtrlSetData($Edit1, "At least we have an element "  & "[" & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & "][" & _UIA_getPropertyValue($oUIElement, $UIA_ClassNamePropertyId) & "]" & @CRLF,1)
    $text1="Title is: <" &  _UIA_getPropertyValue($oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
   & "Class   := <" & _UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
& "controltype:= " _
& "<" &  _UIA_getControlName(_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId)) &  ">" & @TAB  _
& ",<" &  _UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB  _
& ", (" &  hex(_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId)) &  ")" & @TAB & @CRLF

    $text1=$text1 & "*** Parent Information ***" & @CRLF

    $text1=$Text1 & "Title is: <" &  _UIA_getPropertyValue($objParent,$UIA_NamePropertyId) &  ">" & @TAB _
   & "Class   := <" & _UIA_getPropertyValue($objParent,$uia_classnamepropertyid) &  ">" & @TAB _
& "controltype:= " _
& "<" &  _UIA_getControlName(_UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId)) &  ">" & @TAB  _
& ",<" &  _UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId) &  ">" & @TAB  _
& ", (" &  hex(_UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId)) &  ")" & @TAB & @CRLF

$text1=$text1 & "*** Detailed properties of the highlighted element ***"

$text1= $text1 & @CRLF & _UIA_getAllPropertyValues($oUIElement)

GUICtrlSetData($Edit1, "Having the following values for all properties: " & @crlf & $text1 & @CRLF, 1)


_GUICtrlEdit_LineScroll($Edit1, 0, 0 - _GUICtrlEdit_GetLineCount($Edit1))

$t=stringsplit(_UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId),";")
_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
EndIf

EndFunc   ;==>Example

Func Close()
Exit
EndFunc   ;==>Close