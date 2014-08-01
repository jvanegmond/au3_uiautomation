;~ Example 15 Details about the right pane of the windows explorer
#include "CUIAutomation2.au3"

Opt( "MustDeclareVars", 1 )

Global $oUIAutomation

MainFunc()


Func MainFunc()

  ; Be sure to use the right class if you are on Vista or Windows 8
  Local $hWindow = WinGetHandle( "[CLASS:CabinetWClass]", "" )  ; Windows Explorer, Windows 7
  ;Local $hWindow = WinGetHandle( "[CLASS:ExploreWClass]", "" ) ; Windows Explorer, Windows XP
  If Not $hWindow Then Return

  $oUIAutomation = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation )
  If Not IsObj( $oUIAutomation ) Then Return

  Local $pWindow
  $oUIAutomation.ElementFromHandle( $hWindow, $pWindow )
  If Not $pWindow Then Return

  Local $oWindow = ObjCreateInterface( $pWindow, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  If Not IsObj( $oWindow ) Then Return

  ListAllItems( $oWindow, 50007 ) ; 50007 = List view element
  ; Run the code in post #71 to get this value

EndFunc


Func ListAllItems( $oWindow, $iCtrlType )

  Local $pCondition
  $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $iCtrlType, $pCondition )
  If Not $pCondition Then Return

  Local $pUIElementArray, $oUIElementArray, $iElements
  $oWindow.FindAll( $TreeScope_Descendants, $pCondition, $pUIElementArray )
  $oUIElementArray = ObjCreateInterface( $pUIElementArray, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray )
  $oUIElementArray.Length( $iElements )
  If Not $iElements Then Return

  Local $pUIElement, $oUIElement, $name, $sel
  For $i = 0 To $iElements - 1
    $oUIElementArray.GetElement( $i, $pUIElement )
    $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )

    $oUIElement.GetCurrentPropertyValue( $UIA_NamePropertyId, $name )
    $oUIElement.GetCurrentPropertyValue( $UIA_SelectionItemIsSelectedPropertyId, $sel )
    ConsoleWrite( $name & "  " & $sel & @CRLF )
  Next

EndFunc