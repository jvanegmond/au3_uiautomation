;~ Example 18 Details about the right pane of the windows explorer with virtual items
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

  ListAllItems( $oUIList )

EndFunc


Func ListAllItems( $oUIList )

  ; List the visible items

  Local $pCondition
  $oUIAutomation.CreatePropertyCondition( $UIA_ControlTypePropertyId, $UIA_ListItemControlTypeId, $pCondition )
  If Not $pCondition Then Return

  Local $pUIElementArray, $oUIElementArray, $iElements
  $oUIList.FindAll( $TreeScope_Children, $pCondition, $pUIElementArray )
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

  ; List the virtual items

  ; TreeWalker object to get the visible items
  Local $pRawWalker, $oRawWalker
  $oUIAutomation.RawViewWalker( $pRawWalker )
  $oRawWalker = ObjCreateInterface( $pRawWalker, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker )
  If Not IsObj( $oRawWalker ) Then Return

  ; ItemContainer object to get the virtual items
  Local $pItemContainer, $oItemContainer
  $oUIList.GetCurrentPattern( $UIA_ItemContainerPatternId, $pItemContainer )
  $oItemContainer = ObjCreateInterface( $pItemContainer, $sIID_IUIAutomationItemContainerPattern, $dtagIUIAutomationItemContainerPattern )
  If Not IsObj( $oItemContainer ) Then Return

  ; Find first virtual item
  Local $pUIElementLast = $pUIElement, $pVirtualItem, $oVirtualItem
  $oItemContainer.FindItemByProperty( $pUIElementLast, $UIA_NamePropertyId, 0, $pUIElement )
  If Not $pUIElement Then Return

  ; Realize first virtual item
  $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
  $oUIElement.GetCurrentPattern( $UIA_VirtualizedItemPatternId, $pVirtualItem )
  $oVirtualItem = ObjCreateInterface( $pVirtualItem, $sIID_IUIAutomationVirtualizedItemPattern, $dtagIUIAutomationVirtualizedItemPattern )
  $oVirtualItem.Realize()

  While $pUIElement
    $oUIElement.GetCurrentPropertyValue( $UIA_NamePropertyId, $name )
    $oUIElement.GetCurrentPropertyValue( $UIA_SelectionItemIsSelectedPropertyId, $sel )
    ConsoleWrite( $name & "  " & $sel & @CRLF )

    $pUIElementLast = $pUIElement

    ; Check if the next item is already realized
    $oRawWalker.GetNextSiblingElement( $oUIElement, $pUIElement )
    If $pUIElement Then
      $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
    Else
      ; No it's a virtual item, realize it
      $oItemContainer.FindItemByProperty( $pUIElementLast, $UIA_NamePropertyId, 0, $pUIElement )
      If Not $pUIElement Then ExitLoop ; No more items

      $oUIElement = ObjCreateInterface( $pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
      $oUIElement.GetCurrentPattern( $UIA_VirtualizedItemPatternId, $pVirtualItem )
      $oVirtualItem = ObjCreateInterface( $pVirtualItem, $sIID_IUIAutomationVirtualizedItemPattern, $dtagIUIAutomationVirtualizedItemPattern )
      $oVirtualItem.Realize()
    EndIf
  WEnd

EndFunc