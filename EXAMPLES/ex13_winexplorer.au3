;~ Example 13 Details about the right pane of the windows explorer
#include "CUIAutomation2.au3"

Opt( "MustDeclareVars", 1 )

Global $oUIAutomation

MainFunc()


Func MainFunc()

  Local $hWindow = WinGetHandle( "[CLASS:CabinetWClass]" )              ; Windows Explorer, Windows 7
  ;Local $hWindow = WinGetHandle( "[CLASS:ExploreWClass]" )             ; Windows Explorer, Windows XP
  ;Local $hWindow = WinGetHandle( "Windows Explorer right pane" )       ; Windows Explorer right pane
  ;Local $hWindow = WinGetHandle( "[TITLE:Test; CLASS:AutoIt v3 GUI]" ) ; AutoIt GUI window
  ;Local $hWindow = WinGetHandle( "[CLASS:IEFrame]" )                   ; Internet Explorer
  ;Local $hWindow = WinGetHandle( "Calculator" )                        ; Calculator
  If Not $hWindow Then Return

  $oUIAutomation = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation )
  If Not IsObj( $oUIAutomation ) Then Return

  Local $pWindow
  ;$oUIAutomation.GetRootElement( $pWindow )             ; Desktop
  $oUIAutomation.ElementFromHandle( $hWindow, $pWindow ) ; Window
  If Not $pWindow Then Return

  Local $oWindow = ObjCreateInterface( $pWindow, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  If Not IsObj( $oWindow ) Then Return

  ;ListDescendants( $oWindow, 0, 1 ) ; Desktop
  ListDescendants( $oWindow, 0, 0 )  ; Window

EndFunc


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
                  $sIndent & "Selected  = " & _UIA_getPropertyValue( $oUIElement, $UIA_SelectionItemIsSelectedPropertyId ) & @CRLF & _
                  $sIndent & "Handle    = " & Hex( _UIA_getPropertyValue( $oUIElement, $UIA_NativeWindowHandlePropertyId ) ) & @CRLF & @CRLF )

    ListDescendants( $oUIElement, $iLevel + 1, $iLevels )

    $oRawWalker.GetNextSiblingElement( $oUIElement, $pUIElement )
    $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  WEnd

EndFunc


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