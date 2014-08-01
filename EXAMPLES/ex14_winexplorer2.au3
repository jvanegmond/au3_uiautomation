;~ Example 14 Details 2 about the right pane of the windows explorer
#include "CUIAutomation2.au3"

Opt( "MustDeclareVars", 1 )

Global $oUIAutomation

MainFunc()


Func MainFunc()

  Local $hWindow = WinGetHandle( "[CLASS:CabinetWClass]", "" )        ; Windows Explorer, Windows 7
  ;Local $hWindow = WinGetHandle( "[CLASS:ExploreWClass]", "" )       ; Windows Explorer, Windows XP
  ;Local $hWindow = WinGetHandle( "Windows Explorer right pane", "" ) ; Windows Explorer right pane
  ;Local $hWindow = WinGetHandle( "[CLASS:IEFrame]", "" )             ; Internet Explorer
  ;Local $hWindow = WinGetHandle( "Calculator" )                      ; Calculator
  If Not $hWindow Then Return

  $oUIAutomation = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation )
  If Not IsObj( $oUIAutomation ) Then Return

  Local $pWindow
  $oUIAutomation.ElementFromHandle( $hWindow, $pWindow )
  If Not $pWindow Then Return

  Local $oWindow = ObjCreateInterface( $pWindow, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  If Not IsObj( $oWindow ) Then Return

  ListClassDescendants( $oWindow, "UIItemsView" )    ; Windows Explorer, Windows 7
  ;ListClassDescendants( $oWindow, "SysListView32" ) ; Windows Explorer, Windows XP

EndFunc


Func ListClassDescendants( $oWindow, $sClass )

  Local $pCondition
  $oUIAutomation.CreatePropertyCondition( $UIA_ClassNamePropertyId, $sClass, $pCondition )
  If Not $pCondition Then Return

  Local $pUIElement, $oUIElement
  $oWindow.FindFirst( $TreeScope_Descendants, $pCondition, $pUIElement )
  $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  If Not IsObj( $oUIElement ) Then Return

  ListDescendants( $oUIElement, 0, 1 )

EndFunc


; Same function as in post #71
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
    ConsoleWrite( $sIndent & "Title    = " & _UIA_getPropertyValue( $oUIElement, $UIA_NamePropertyId ) & @CRLF & _
                  $sIndent & "Selected = " & _UIA_getPropertyValue( $oUIElement, $UIA_SelectionItemIsSelectedPropertyId ) & @CRLF & _
                  $sIndent & "Class    = " & _UIA_getPropertyValue( $oUIElement, $UIA_ClassNamePropertyId ) & @CRLF & _
                  $sIndent & "Type     = " & _UIA_getPropertyValue( $oUIElement, $UIA_LocalizedControlTypePropertyId ) & @CRLF & _
                  $sIndent & "Handle   = " & Hex( _UIA_getPropertyValue( $oUIElement, $UIA_NativeWindowHandlePropertyId ) ) & @CRLF & @CRLF )

    ListDescendants( $oUIElement, $iLevel + 1, $iLevels )

    $oRawWalker.GetNextSiblingElement( $oUIElement, $pUIElement )
    $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  WEnd

EndFunc


; Same function as in post #71
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