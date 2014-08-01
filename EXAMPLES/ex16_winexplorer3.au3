;~ Example 16 Details about the right pane of the windows explorer
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

  ListParents( $pWindow, 50008 ) ; 50008 = SysListView32 on XP ; 50008 = UIItemsView on 7
  ; Run the code in post #71 to get this value

EndFunc


Func ListParents( $pWindow, $iCtrlType )

  Local $oWindow = ObjCreateInterface( $pWindow, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  If Not IsObj( $oWindow ) Then Return

  Local $pCondition
  $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $iCtrlType, $pCondition )
  If Not $pCondition Then Return

  Local $pUIParent, $aUIParents[20], $iUIParents = 0
  $oWindow.FindFirst( $TreeScope_Descendants, $pCondition, $pUIParent )
  If Not $pUIParent Then Return

  $aUIParents[$iUIParents] = $pUIParent
  $iUIParents += 1

  Local $pRawWalker, $oRawWalker, $same
  $oUIAutomation.RawViewWalker( $pRawWalker )
  $oRawWalker = ObjCreateInterface( $pRawWalker, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker )
  If Not IsObj( $oRawWalker ) Then Return

  While Not $same
    $oRawWalker.GetParentElement( $pUIParent, $pUIParent )
    $oUIAutomation.CompareElements( $pWindow, $pUIParent, $same )
    $aUIParents[$iUIParents] = $pUIParent
    $iUIParents += 1
  WEnd

  Local $oUIParent, $sClass, $sIndent = ""
  For $i = $iUIParents - 1 To 0 Step -1
    $oUIParent = ObjCreateInterface( $aUIParents[$i], $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
    $oUIParent.GetCurrentPropertyValue( $UIA_ClassNamePropertyId, $sClass )
    ConsoleWrite( $sIndent & $sClass & @CRLF )
    $sIndent &= "    "
  Next

EndFunc