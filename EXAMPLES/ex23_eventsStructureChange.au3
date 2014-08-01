;~ Example 23 events
;~ If you have downloaded the example above it's very important that you replace this code in MainFunc
;~
;~ ; Create UI element
;~ Local $pUIElement
;~ $oUIAutomation.GetRootElement( $pUIElement ) ; Desktop
;~ If Not $pUIElement Then Return

;~ with this code
;~
;~ ; Create UI element
;~ Local $hWindow, $pUIElement
;~ $hWindow = WinGetHandle( "[CLASS:IEFrame]" ) ; Internet Explorer
;~ $oUIAutomation.ElementFromHandle( $hWindow, $pUIElement )
;~ If Not $pUIElement Then Return

#include "CUIAutomation2.au3"

Opt( "MustDeclareVars", 1 )

Global Const $S_OK = 0x00000000
Global Const $E_NOINTERFACE = 0x80004002
Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"

Global $tIUIAutomationStructureChangedEventHandler, $oIUIAutomationStructureChangedEventHandler

Global $oUIAutomation

MainFunc()



Func MainFunc()

  ; Create custom event handler object for structure change events
  $oIUIAutomationStructureChangedEventHandler = ObjectFromTag( "oIUIAutomationStructureChangedEventHandler_", $dtagIUIAutomationStructureChangedEventHandler, $tIUIAutomationStructureChangedEventHandler, True )
  If Not IsObj( $oIUIAutomationStructureChangedEventHandler ) Then Return

  ; Create UI Automation object
  $oUIAutomation = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation )
  If Not IsObj( $oUIAutomation ) Then Return

  ; Create UI element
  ;Local $pUIElement
  ;$oUIAutomation.GetRootElement( $pUIElement ) ; Desktop
  ;If Not $pUIElement Then Return

  ; Create UI element
  Local $hWindow, $pUIElement
  $hWindow = WinGetHandle( "[CLASS:IEFrame]" ) ; Internet Explorer
  $oUIAutomation.ElementFromHandle( $hWindow, $pUIElement )
  If Not $pUIElement Then Return

  ; Add structure change event handler
  If $oUIAutomation.AddStructureChangedEventHandler( $pUIElement, $TreeScope_Subtree, 0, $oIUIAutomationStructureChangedEventHandler ) Then Exit

  HotKeySet( "{ESC}", "Quit" )

  While Sleep(100)
  WEnd

EndFunc

Func Quit()
  $oIUIAutomationStructureChangedEventHandler = 0
  DeleteObjectFromTag( $tIUIAutomationStructureChangedEventHandler )
  Exit
EndFunc



; Get property ($id) for UI element ($obj)
Func _UIA_getPropertyValue( $obj, $id )
  Local $tVal
  $obj.GetCurrentPropertyValue( $id, $tVal )
  If Not IsArray( $tVal ) Then Return $tVal
  Local $tStr = $tVal[0]
  For $i = 1 To UBound( $tVal ) - 1
    $tStr &= "; " & $tVal[$i]
  Next
  Return $tStr
EndFunc

; List all descendants of the parent UI element
; in a hierarchical structure like a treeview.
Func ListDescendants( $oParent, $iLevel, $iLevels = 0 )

  If Not IsObj( $oParent ) Then Return
  If $iLevels And $iLevel = $iLevels Then Return

  Local $pRawWalker, $oRawWalker
  $oUIAutomation.RawViewWalker( $pRawWalker )
  $oRawWalker = ObjCreateInterface( $pRawWalker, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker )

  Local $pUIElement, $oUIElement
  $oRawWalker.GetFirstChildElement( $oParent, $pUIElement )
  $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )

  Local $sIndent = ""
  For $i = 0 To $iLevel - 1
    $sIndent &= "    "
  Next

  While IsObj( $oUIElement )
    ConsoleWrite( $sIndent & "Title     = " & _UIA_getPropertyValue( $oUIElement, $UIA_NamePropertyId ) & @CRLF & _
                  $sIndent & "Class     = " & _UIA_getPropertyValue( $oUIElement, $UIA_ClassNamePropertyId ) & @CRLF & _
                  $sIndent & "Ctrl type = " & _UIA_getPropertyValue( $oUIElement, $UIA_ControlTypePropertyId ) & @CRLF & _
                  $sIndent & "Ctrl name = " & _UIA_getPropertyValue( $oUIElement, $UIA_LocalizedControlTypePropertyId ) & @CRLF & _
                  $sIndent & "Value     = " & _UIA_getPropertyValue( $oUIElement, $UIA_LegacyIAccessibleValuePropertyId ) & @CRLF & _
                  $sIndent & "Handle    = " & Hex( _UIA_getPropertyValue( $oUIElement, $UIA_NativeWindowHandlePropertyId ) ) & @CRLF & @CRLF )

    ListDescendants( $oUIElement, $iLevel + 1, $iLevels )

    $oRawWalker.GetNextSiblingElement( $oUIElement, $pUIElement )
    $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  WEnd

EndFunc



Func oIUIAutomationStructureChangedEventHandler_HandleStructureChangedEvent( $pSelf, $pSender, $iChangeType, $pRuntimeId ) ; Ret: long  Par: ptr;long;ptr

  ; Create sender object
  Local $oSender = ObjCreateInterface( $pSender, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  $oSender.AddRef()

  ; Get object class
  Local $sClass
  $oSender.GetCurrentPropertyValue( $UIA_ClassNamePropertyId, $sClass )

  ; Only handle objects of class "Frame Notification Bar"
  If $sClass = "Frame Notification Bar" Then

    ; Print object properties
    ConsoleWrite( @CRLF & _
                  "Title     = " & _UIA_getPropertyValue( $oSender, $UIA_NamePropertyId ) & @CRLF & _
                  "Class     = " & _UIA_getPropertyValue( $oSender, $UIA_ClassNamePropertyId ) & @CRLF & _
                  "Ctrl type = " & _UIA_getPropertyValue( $oSender, $UIA_ControlTypePropertyId ) & @CRLF & _
                  "Ctrl name = " & _UIA_getPropertyValue( $oSender, $UIA_LocalizedControlTypePropertyId ) & @CRLF & _
                  "Value     = " & _UIA_getPropertyValue( $oSender, $UIA_LegacyIAccessibleValuePropertyId ) & @CRLF & _
                  "Handle    = " & Hex( _UIA_getPropertyValue( $oSender, $UIA_NativeWindowHandlePropertyId ) ) & @CRLF & @CRLF )

    If $iChangeType = 0 Then ; Window open event
      ConsoleWrite( "Notification Bar opened" & @CRLF & @CRLF )
    Else ; $iChangeType = 1  ; Window close event
      ConsoleWrite( "Notification Bar closed" & @CRLF & @CRLF )
      Return $S_OK
    EndIf

    ; List descendants of the object
    ConsoleWrite( "Descendants of the Frame Notification Bar:" & @CRLF & @CRLF )
    ListDescendants( $oSender, 0, 0 )

    ; Condition to find Save button (split button)
    Local $pCondition
    $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $UIA_SplitButtonControlTypeId, $pCondition )
    If Not $pCondition Then Return $S_OK

    ; Find Save button
    Local $pSave, $oSave
    $oSender.FindFirst( $TreeScope_Descendants, $pCondition, $pSave )

    If $pSave Then

      ; Click Save and Close buttons in the first "Frame Notification Bar" window

      $oSave = ObjCreateInterface( $pSave, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
      If Not IsObj( $oSave ) Then Return $S_OK

      ; Click (invoke) Save button
      Local $pInvoke, $oInvoke
      $oSave.GetCurrentPattern( $UIA_InvokePatternId, $pInvoke )
      $oInvoke = ObjCreateInterface( $pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern )
      If Not IsObj( $oInvoke ) Then Return $S_OK
      $oInvoke.Invoke()
      ConsoleWrite( "Save button clicked" & @CRLF & @CRLF )

      ; Condition to find Close button
      Local $pCondition1, $pCondition2
      $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $UIA_ButtonControlTypeId, $pCondition1 )
      $oUIAutomation.CreatePropertyCondition( $UIA_NamePropertyId, "Close", $pCondition2 )
      $oUIAutomation.CreateAndCondition( $pCondition1, $pCondition2, $pCondition )
      If Not $pCondition Then Return $S_OK

      ; Find Close button
      Local $pClose, $oClose
      $oSender.FindFirst( $TreeScope_Descendants, $pCondition, $pClose )
      $oClose = ObjCreateInterface( $pClose, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
      If Not IsObj( $oClose ) Then Return $S_OK

      ; Click (invoke) Close button
      Local $pInvoke, $oInvoke
      $oClose.GetCurrentPattern( $UIA_InvokePatternId, $pInvoke )
      $oInvoke = ObjCreateInterface( $pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern )
      If Not IsObj( $oInvoke ) Then Return $S_OK
      $oInvoke.Invoke()
      ConsoleWrite( "Close button clicked" & @CRLF & @CRLF )

    Else

      ; Click Close button in the next "Frame Notification Bar" windows

      ; Condition to find Close button
      Local $pCondition1, $pCondition2
      $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $UIA_ButtonControlTypeId, $pCondition1 )
      $oUIAutomation.CreatePropertyCondition( $UIA_NamePropertyId, "Close", $pCondition2 )
      $oUIAutomation.CreateAndCondition( $pCondition1, $pCondition2, $pCondition )
      If Not $pCondition Then Return $S_OK

      ; Find Close button
      Local $pClose, $oClose
      $oSender.FindFirst( $TreeScope_Descendants, $pCondition, $pClose )
      $oClose = ObjCreateInterface( $pClose, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
      If Not IsObj( $oClose ) Then Return $S_OK

      ; Click (invoke) Close button
      Local $pInvoke, $oInvoke
      $oClose.GetCurrentPattern( $UIA_InvokePatternId, $pInvoke )
      $oInvoke = ObjCreateInterface( $pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern )
      If Not IsObj( $oInvoke ) Then Return $S_OK
      $oInvoke.Invoke()
      ConsoleWrite( "Close button clicked" & @CRLF & @CRLF )

    EndIf

  EndIf

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

; Copied and slightly modified (print methods) from this post by trancexx:
; http://www.autoitscript.com/forum/topic/153520-iuiautomation-ms-framework-automate-chrome-ff-ie/page*#entry1143566
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