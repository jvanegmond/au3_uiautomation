;~ Example 17 Details about the right pane of the windows explorer with virtual items
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

  Local $pCondition
  $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $UIA_ListControlTypeId, $pCondition )
  If Not $pCondition Then Return

  Local $pUIList, $oUIList
  $oWindow.FindFirst( $TreeScope_Descendants, $pCondition, $pUIList )
  $oUIList = ObjCreateInterface( $pUIList, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  If Not IsObj( $oUIList ) Then Return

  ListAllItemsCached( $oUIList )

EndFunc


Func ListAllItemsCached( $oUIList )

  ConsoleWrite( "With CACHING" & @CRLF )

  Local $pIUIAutomationCacheRequest, $oIUIAutomationCacheRequest
  $oUIAutomation.CreateCacheRequest( $pIUIAutomationCacheRequest )
  $oIUIAutomationCacheRequest = ObjCreateInterface( $pIUIAutomationCacheRequest, $sIID_IUIAutomationCacheRequest, $dtagIUIAutomationCacheRequest )
  If Not IsObj( $oIUIAutomationCacheRequest ) Then Return

  Local $iAutomationElementMode
  If $oIUIAutomationCacheRequest.AddProperty( $UIA_NamePropertyId ) Then Return                       ; Method returns non-zero value on error
  If $oIUIAutomationCacheRequest.AddProperty( $UIA_SelectionItemIsSelectedPropertyId ) Then Return
  If $oIUIAutomationCacheRequest.put_AutomationElementMode( $AutomationElementMode_None ) Then Return ; Set Mode = None = 0 ; Mode = Full = 1 is default
  If $oIUIAutomationCacheRequest.get_AutomationElementMode( $iAutomationElementMode ) Then Return     ; Get the Mode we have just set
  ConsoleWrite( "AutomationElementMode = " & $iAutomationElementMode & @CRLF )                        ; This should print Mode = 0

  Local $pCondition
  $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $UIA_ListItemControlTypeId, $pCondition )
  If Not $pCondition Then Return

  Local $pUIElementArray, $oUIElementArray, $iElements
  $oUIList.FindAllBuildCache( $TreeScope_Children, $pCondition, $pIUIAutomationCacheRequest, $pUIElementArray )
  $oUIElementArray = ObjCreateInterface( $pUIElementArray, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray )
  $oUIElementArray.Length( $iElements )
  If Not $iElements Then Return

  Local $pUIElement, $oUIElement, $name, $sel
  For $i = 0 To $iElements - 1
    $oUIElementArray.GetElement( $i, $pUIElement )
    $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )

    $oUIElement.GetCachedPropertyValue( $UIA_NamePropertyId, $name )
    $oUIElement.GetCachedPropertyValue( $UIA_SelectionItemIsSelectedPropertyId, $sel )
    ConsoleWrite( $name & "  " & $sel & @CRLF )
  Next

EndFunc