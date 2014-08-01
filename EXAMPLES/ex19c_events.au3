;~ Example 19c events
#include "CUIAutomation2.au3"

Opt( "MustDeclareVars", 1 )

Global Const $S_OK = 0x00000000
Global Const $E_NOINTERFACE = 0x80004002
Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"

Global $tIUIAutomationStructureChangedEventHandler, $oIUIAutomationStructureChangedEventHandler

Global $oUIAutomation

MainFunc()



Func MainFunc()

  $oIUIAutomationStructureChangedEventHandler = ObjectFromTag( "oIUIAutomationStructureChangedEventHandler_", $dtagIUIAutomationStructureChangedEventHandler, $tIUIAutomationStructureChangedEventHandler, True )
  If Not IsObj( $oIUIAutomationStructureChangedEventHandler ) Then Return

  $oUIAutomation = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation )
  If Not IsObj( $oUIAutomation ) Then Return

  Local $pUIElement
  $oUIAutomation.GetRootElement( $pUIElement ) ; Desktop
  If Not $pUIElement Then Return

  If $oUIAutomation.AddStructureChangedEventHandler( $pUIElement, $TreeScope_Subtree, 0, $oIUIAutomationStructureChangedEventHandler ) Then Exit

  HotKeySet( "{ESC}", "Quit" )

  While Sleep(10)
  WEnd

EndFunc

Func Quit()
  $oIUIAutomationStructureChangedEventHandler = 0
  DeleteObjectFromTag( $tIUIAutomationStructureChangedEventHandler )
  Exit
EndFunc



Func _UIA_getPropertyValue( $obj, $id )
  Local $tVal
  $obj.GetCurrentPropertyValue( $id, $tVal )
  Return $tVal
EndFunc

Func oIUIAutomationStructureChangedEventHandler_HandleStructureChangedEvent( $pSelf, $pSender, $iChangeType, $pRuntimeId ) ; Ret: long  Par: ptr;long;ptr
  ConsoleWrite( "oIUIAutomationStructureChangedEventHandler_HandleStructureChangedEvent: " & $pSender & " " & $iChangeType & @CRLF )
  Local $oSender = ObjCreateInterface( $pSender, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  $oSender.AddRef()
  ConsoleWrite( "Title     = " & _UIA_getPropertyValue( $oSender, $UIA_NamePropertyId ) & @CRLF & _
                "Class     = " & _UIA_getPropertyValue( $oSender, $UIA_ClassNamePropertyId ) & @CRLF & _
                "Ctrl type = " & _UIA_getPropertyValue( $oSender, $UIA_ControlTypePropertyId ) & @CRLF & _
                "Ctrl name = " & _UIA_getPropertyValue( $oSender, $UIA_LocalizedControlTypePropertyId ) & @CRLF & _
                "Value     = " & _UIA_getPropertyValue( $oSender, $UIA_LegacyIAccessibleValuePropertyId ) & @CRLF & _
                "Handle    = " & Hex( _UIA_getPropertyValue( $oSender, $UIA_NativeWindowHandlePropertyId ) ) & @CRLF & @CRLF )
  Return $S_OK
EndFunc

Func oIUIAutomationStructureChangedEventHandler_QueryInterface( $pSelf, $pRIID, $pObj ) ; Ret: long  Par: ptr;ptr*
  Local $sIID = StringFromGUID( $pRIID )
  If $sIID = $sIID_IUnknown Then
    ConsoleWrite( "oIUIAutomationStructureChangedEventHandler_QueryInterface: IUnknown" & @CRLF )
    DllStructSetData( DllStructCreate( "ptr", $pObj ), 1, $pSelf )
    oIUIAutomationStructureChangedEventHandler_AddRef( $pSelf )
    Return $S_OK
  ElseIf $sIID = $sIID_IUIAutomationStructureChangedEventHandler Then
    ConsoleWrite( "oIUIAutomationStructureChangedEventHandler_QueryInterface: IUIAutomationStructureChangedEventHandler" & @CRLF )
    DllStructSetData( DllStructCreate( "ptr", $pObj ), 1, $pSelf )
    oIUIAutomationStructureChangedEventHandler_AddRef( $pSelf )
    Return $S_OK
  Else
    ConsoleWrite( "oIUIAutomationStructureChangedEventHandler_QueryInterface: " & $sIID & @CRLF )
    Return $E_NOINTERFACE
  EndIf
EndFunc

Func oIUIAutomationStructureChangedEventHandler_AddRef( $pSelf ) ; Ret: ulong
  ConsoleWrite( "oIUIAutomationStructureChangedEventHandler_AddRef" & @CRLF )
  Return 1
EndFunc

Func oIUIAutomationStructureChangedEventHandler_Release( $pSelf ) ; Ret: ulong
  ConsoleWrite( "oIUIAutomationStructureChangedEventHandler_Release" & @CRLF )
  Return 1
EndFunc



Func StringFromGUID( $pGUID )
  Local $aResult = DllCall( "ole32.dll", "int", "StringFromGUID2", "struct*", $pGUID, "wstr", "", "int", 40 )
  If @error Then Return SetError( @error, @extended, "" )
  Return SetExtended( $aResult[0], $aResult[2] )
EndFunc



Func ObjectFromTag($sFunctionPrefix, $tagInterface, ByRef $tInterface, $fPrint = False, $bIsUnknown = Default, $sIID = "{00000000-0000-0000-C000-000000000046}") ; last param is IID_IUnknown by default
    If $bIsUnknown = Default Then $bIsUnknown = True
    Local $sInterface = $tagInterface ; copy interface description
    Local $tagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
            "AddRef dword();" & _
            "Release dword();"
    ; Adding IUnknown methods
    If $bIsUnknown Then $tagInterface = $tagIUnknown & $tagInterface
    ; Below line is really simple even though it looks super complex. It's just written weird to fit in one line, not to steal your attention
    Local $aMethods = StringSplit(StringReplace(StringReplace(StringReplace(StringReplace(StringTrimRight(StringReplace(StringRegExpReplace(StringRegExpReplace($tagInterface, "\w+\*", "ptr"), "\h*(\w+)\h*(\w+\*?)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF), 1), "object", "idispatch"), "hresult", "long"), "bstr", "ptr"), "variant", "ptr"), @LF, 3)
    Local $iUbound = UBound($aMethods)
    Local $sMethod, $aSplit, $sNamePart, $aTagPart, $sTagPart, $sRet, $sParams, $hCallback
    ; Allocation
    $tInterface = DllStructCreate("int RefCount;int Size;ptr Object;ptr Methods[" & $iUbound & "];int_ptr Callbacks[" & $iUbound & "];ulong_ptr Slots[16]") ; 16 pointer sized elements more to create space for possible private props
    If @error Then Return SetError(1, 0, 0)
    For $i = 0 To $iUbound - 1
        $aSplit = StringSplit($aMethods[$i], "|", 2)
        If UBound($aSplit) <> 2 Then ReDim $aSplit[2]
        $sNamePart = $aSplit[0]
        $sTagPart = $aSplit[1]
        $sMethod = $sFunctionPrefix & $sNamePart
        If $fPrint Then
            Local $iPar = StringInStr( $sTagPart, ";", 2 ), $t
            If $iPar Then
                $t = "Ret: " & StringLeft( $sTagPart, $iPar - 1 ) & "  " & _
                     "Par: " & StringRight( $sTagPart, StringLen( $sTagPart ) - $iPar )
            Else
                $t = "Ret: " & $sTagPart
            EndIf
            Local $s = "Func " & $sMethod & _
                "( $pSelf ) ; " & $t & @CRLF & _
                "EndFunc" & @CRLF
            ConsoleWrite( $s )
        EndIf
        $aTagPart = StringSplit($sTagPart, ";", 2)
        $sRet = $aTagPart[0]
        $sParams = StringReplace($sTagPart, $sRet, "", 1)
        $sParams = "ptr" & $sParams
        $hCallback = DllCallbackRegister($sMethod, $sRet, $sParams)
        ConsoleWrite(@error & @CRLF & @CRLF)
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