;~ Example 20 events
;~ Important to handle $oSender.addref()

#include "CUIAutomation2.au3"

Global Const $S_OK = 0x00000000
Global Const $E_NOTIMPL = 0x80004001
Global Const $E_NOINTERFACE = 0x80004002
Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"

Global Const $sIID_IShellBrowser = "{000214E2-0000-0000-C000-000000000046}"
Global Const $dtag_IShellBrowser = _
        "GetWindow hresult(hwnd*);" & _               ; IOleWindow:    ; Gets a window handle.
        "ContextSensitiveHelp hresult(int);" & _                       ; Controls enabling of context-sensitive help.
        "InsertMenusSB hresult(handle;ptr);" & _      ; IShellBrowser: ; Allows the container to insert its menu groups into the composite menu that is displayed when an extended namespace is being viewed or used.
        "SetMenuSB hresult(handle;handle;hwnd);" & _                   ; Installs the composite menu in the view window.
        "RemoveMenusSB hresult(handle);" & _                           ; Permits the container to remove any of its menu elements from the in-place composite menu and to free all associated resources.
        "SetStatusTextSB hresult(ptr);" & _                            ; Sets and displays status text about the in-place object in the container's frame-window status bar.
        "EnableModelessSB hresult(int);" & _                           ; Tells Windows Explorer to enable or disable its modeless dialog boxes.
        "TranslateAcceleratorSB hresult(ptr;word);" & _                ; Translates accelerator keystrokes intended for the browser's frame while the view is active.
        "BrowseObject hresult(ptr;uint);" & _                          ; Informs Microsoft Windows Explorer to browse to another folder.
        "GetViewStateStream hresult(dword;long_ptr*);" & _             ; Gets an IStream interface that can be used for storage of view-specific state information.
        "GetControlWindow hresult(uint;hwnd);" & _                     ; Gets the window handle to a browser control.
        "SendControlMsg hresult(uint;uint;wparam;lparam;lresult);" & _ ; Sends control messages to either the toolbar or the status bar in a Windows Explorer window.
        "QueryActiveShellView hresult(ptr*);" & _                      ; Retrieves the currently active (displayed) Shell view object.
        "OnViewWindowActive hresult(ptr);" & _                         ; Called by the Shell view when the view window or one of its child windows gets the focus or becomes active.
        "SetToolbarItems hresult(ptr;uint;uint);"                      ; Adds toolbar items to Windows Explorer's toolbar.

Global $tIShellBrowser, $oIShellBrowser

MainFunc()

Func MainFunc()

    $oIShellBrowser = ObjectFromTag("oIShellBrowser_", $dtag_IShellBrowser, $tIShellBrowser, Default, $sIID_IShellBrowser)
    If Not IsObj($oIShellBrowser) Then Return

    ; Try calling some methods to see if the object is functional:
    ConsoleWrite("--------------------------------------" & @CRLF)
    $oIShellBrowser.AddRef()
    $oIShellBrowser.AddRef()
    $oIShellBrowser.AddRef()
    ConsoleWrite("--------------------------------------" & @CRLF)
    $oIShellBrowser.Release()
    $oIShellBrowser.Release()
    $oIShellBrowser.Release()
    ConsoleWrite("--------------------------------------" & @CRLF)

    HotKeySet("{ESC}", "Quit")

    While Sleep(100)
    WEnd

EndFunc

Func Quit()
    ConsoleWrite(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" & @CRLF)
    $oIShellBrowser = 0 ; kill the object (ref count should be 0 now and it's safe to call function below)
    ConsoleWrite("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" & @CRLF)
    DeleteObjectFromTag($tIShellBrowser)
    Exit
EndFunc

Func StringFromGUID($pGUID)
    Local $aResult = DllCall("ole32.dll", "int", "StringFromGUID2", "struct*", $pGUID, "wstr", "", "int", 40)
    If @error Then Return SetError(@error, @extended, "")
    Return SetExtended($aResult[0], $aResult[2])
EndFunc

Func oIShellBrowser_QueryInterface($pSelf, $pRIID, $pObj)
    Local $tRef = DllStructCreate("int", $pSelf - 8) ; reference counter is size of two ints before
    Local $sIID = StringFromGUID($pRIID)
    ConsoleWrite("oIShellBrowser_QueryInterface: " & $sIID & @CRLF)
    If $sIID = $sIID_IUnknown Or $sIID = $sIID_IShellBrowser Then
        DllStructSetData(DllStructCreate("ptr", $pObj), 1, $pSelf)
        DllStructSetData($tRef, 1, DllStructGetData($tRef, 1) + 1) ; increase ref count
        Return $S_OK
    EndIf
    ; For all other cases
    Return $E_NOINTERFACE
EndFunc

Func oIShellBrowser_AddRef($pSelf)
    Local $tRef = DllStructCreate("int", $pSelf - 8) ; reference counter is size of two ints before
    Local $iRef = DllStructGetData($tRef, 1) + 1 ; increment
    DllStructSetData($tRef, 1, $iRef)
    ConsoleWrite("oIShellBrowser_AddRef ref count = " & $iRef & @CRLF)
    Return $iRef
EndFunc

Func oIShellBrowser_Release($pSelf)
    Local $tRef = DllStructCreate("int", $pSelf - 8) ; reference counter is size of two ints before
    Local $iRef = DllStructGetData($tRef, 1) - 1 ; decrement
    DllStructSetData($tRef, 1, $iRef)
    ConsoleWrite("oIShellBrowser_Release ref count = " & $iRef & @CRLF)
    Return $iRef
EndFunc

Func oIShellBrowser_GetWindow($pSelf, $phwnd)
    ConsoleWrite("oIShellBrowser_GetWindow" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_ContextSensitiveHelp($pSelf, $fEnterMode)
    ConsoleWrite("oIShellBrowser_ContextSensitiveHelp" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_InsertMenusSB($pSelf, $hmenuShared, $lpMenuWidths)
    ConsoleWrite("oIShellBrowser_InsertMenusSB" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_SetMenuSB($pSelf, $hmenuShared, $holemenuRes, $hwndActiveObject)
    ConsoleWrite("oIShellBrowser_SetMenuSB" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_RemoveMenusSB($pSelf, $hmenuShared)
    ConsoleWrite("oIShellBrowser_RemoveMenusSB" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_SetStatusTextSB($pSelf, $lpszStatusText)
    ConsoleWrite("oIShellBrowser_SetStatusTextSB" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_EnableModelessSB($pSelf, $fEnable)
    ConsoleWrite("oIShellBrowser_EnableModelessSB" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_TranslateAcceleratorSB($pSelf, $lpmsg, $wID)
    ConsoleWrite("oIShellBrowser_TranslateAcceleratorSB" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_BrowseObject($pSelf, $pidl, $wFlags)
    ConsoleWrite("oIShellBrowser_BrowseObject" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_GetViewStateStream($pSelf, $grfMode, $ppStrm)
    ConsoleWrite("oIShellBrowser_GetViewStateStream" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_GetControlWindow($pSelf, $id, $lphwnd)
    ConsoleWrite("oIShellBrowser_GetControlWindow" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_SendControlMsg($pSelf, $id, $uMsg, $wParam, $lParam, $pret)
    ConsoleWrite("oIShellBrowser_SendControlMsg" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_QueryActiveShellView($pSelf, $ppshv)
    ConsoleWrite("oIShellBrowser_QueryActiveShellView" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_OnViewWindowActive($pSelf, $ppshv)
    ConsoleWrite("oIShellBrowser_OnViewWindowActive" & @CRLF)
    Return $E_NOTIMPL
EndFunc

Func oIShellBrowser_SetToolbarItems($pSelf, $lpButtons, $nButtons, $uFlags)
    ConsoleWrite("oIShellBrowser_SetToolbarItems" & @CRLF)
    Return $E_NOTIMPL
EndFunc




Func ObjectFromTag($sFunctionPrefix, $tagInterface, ByRef $tInterface, $bIsUnknown = Default, $sIID = "{00000000-0000-0000-C000-000000000046}") ; last param is IID_IUnknown by default
    If $bIsUnknown = Default Then $bIsUnknown = True
    Local $sInterface = $tagInterface ; copy interface description
    Local $tagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
            "AddRef dword();" & _
            "Release dword();"
    ; Adding IUnknown methods
    If $bIsUnknown Then $tagInterface = $tagIUnknown & $tagInterface
    ; Below line is really simple even though it looks super complex. It's just written weird to fit in one line, not to steal your attention
    Local $aMethods = StringSplit(StringTrimRight(StringReplace(StringRegExpReplace(StringRegExpReplace($tagInterface, "\w+\*", "ptr"), "\h*(\w+)\h*(\w+\*?)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF), 1), @LF, 3)
    Local $iUbound = UBound($aMethods)
    Local $sMethod, $aSplit, $sNamePart, $aTagPart, $sTagPart, $sRet, $sParams, $hCallback
    ; Allocation
    $tInterface = DllStructCreate("int RefCount;int Size;ptr Object;ptr Methods[" & $iUbound & "];int_ptr Callbacks[" & $iUbound & "];ulong_ptr Slots[16]") ; 16 pointer sized elements more to create space for possible private props
    If @error Then Return SetError(1, 0, 0)
    For $i = 0 To $iUbound - 1
        $aSplit = StringSplit($aMethods[$i], "|", 2)
        If UBound($aSplit) <> 2 Then ReDim $aSplit[2]
        $sNamePart = $aSplit[0]
        ; Replace COM types by matching dllcallback types
        $sTagPart = StringReplace(StringReplace(StringReplace(StringReplace($aSplit[1], "object", "idispatch"), "hresult", "long"), "bstr", "ptr"), "variant", "ptr")
        $sMethod = $sFunctionPrefix & $sNamePart
        $aTagPart = StringSplit($sTagPart, ";", 2)
        $sRet = $aTagPart[0]
        $sParams = StringReplace($sTagPart, $sRet, "", 1)
        $sParams = "ptr" & $sParams
        $hCallback = DllCallbackRegister($sMethod, $sRet, $sParams)
        DllStructSetData($tInterface, "Methods", DllCallbackGetPtr($hCallback), $i + 1) ; save callback pointer
        DllStructSetData($tInterface, "Callbacks", $hCallback, $i + 1) ; save callback handle
    Next
    DllStructSetData($tInterface, "RefCount", 1) ; initial ref count is 1
    DllStructSetData($tInterface, "Size", $iUbound) ; number of interface methods
    DllStructSetData($tInterface, "Object", DllStructGetPtr($tInterface, "Methods")) ; Interface method pointers
    Return ObjCreateInterface(DllStructGetPtr($tInterface, "Object"), $sIID, $sInterface, $bIsUnknown) ; pointer that's wrapped into object
EndFunc

Func DeleteObjectFromTag(ByRef $tInterface)
    For $i = 1 To DllStructGetData($tInterface, "Size")
        DllCallbackFree(DllStructGetData($tInterface, "Callbacks", $i))
    Next
    $tInterface = 0
EndFunc