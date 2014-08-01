;~ Example 28 events MSAA
#include "CUIAutomation2.au3"
#include "MSAccessibility.au3"

Opt( "MustDeclareVars", 1 )

Global $hMenuEventProc, $hMenuEventHook
Global $hFocusEventProc, $hFocusEventHook
global const $cDesktopName="Bureaublad"
;~ global const $cDesktopName="Desktop"

MainFunc()

Func MainFunc()

  $hMenuEventProc = DllCallbackRegister( "MenuEventProc", "none", "ptr;dword;hwnd;long;long;dword;dword" )
  $hMenuEventHook = SetWinEventHook( $EVENT_SYSTEM_MENUSTART, $EVENT_SYSTEM_MENUPOPUPEND, DllCallbackGetPtr( $hMenuEventProc ) )

  $hFocusEventProc = DllCallbackRegister( "FocusEventProc", "none", "ptr;dword;hwnd;long;long;dword;dword" )
  $hFocusEventHook = SetWinEventHook( $EVENT_OBJECT_FOCUS, $EVENT_OBJECT_FOCUS, DllCallbackGetPtr( $hFocusEventProc ) )

  HotKeySet( "{ESC}", "Close" )

  While Sleep(100)
  WEnd

EndFunc


Func MenuEventProc( $hMenuEventHook, $iMenuEvent, $hWnd, $iObjectID, $iChildID, $iThreadID, $iEventTime )

  Local $pAccessible, $oAccessible, $tVarChild
  If AccessibleObjectFromEvent( $hWnd, $iObjectID, $iChildID, $pAccessible, $tVarChild ) = $S_OK Then
    $oAccessible = ObjCreateInterface( $pAccessible, $sIID_IAccessible, $dtagIAccessible )

    Switch $iMenuEvent
      Case $EVENT_SYSTEM_MENUSTART
        ConsoleWrite( "Menu event: $EVENT_SYSTEM_MENUSTART" & @CRLF )
      Case $EVENT_SYSTEM_MENUEND
        ConsoleWrite( "Menu event: $EVENT_SYSTEM_MENUEND" & @CRLF )
      Case $EVENT_SYSTEM_MENUPOPUPSTART
        ConsoleWrite( "Menu event: $EVENT_SYSTEM_MENUPOPUPSTART" & @CRLF )
      Case $EVENT_SYSTEM_MENUPOPUPEND
        ConsoleWrite( "Menu event: $EVENT_SYSTEM_MENUPOPUPEND" & @CRLF )
    EndSwitch

    ; Get parent objects to top window
    Local $pParent, $oObject = $oAccessible, $pPrev, $oPrev, $sName
    Do
      $pPrev = $pParent
      $oPrev = $oObject
      $oObject.get_accParent( $pParent )
      $oObject = ObjCreateInterface( $pParent, $sIID_IAccessible, $dtagIAccessible )
      $oObject.get_accName( $CHILDID_SELF, $sName )
	  consoleWrite( $sName & @CRLF)
    Until String( $sName ) = $cDesktopName

    ; Name of top window (previous to desktop)
    $oPrev.get_accName( $CHILDID_SELF, $sName )

    ConsoleWrite( "Program = " & $sName & @CRLF )
    PrintElementInfo( $oAccessible, $iChildID, "" )
  EndIf

EndFunc


Func FocusEventProc( $hFocusEventHook, $iFocusEvent, $hWnd, $iObjectID, $iChildID, $iThreadID, $iEventTime )

  Local $pAccessible, $oAccessible, $tVarChild
  If AccessibleObjectFromEvent( $hWnd, $iObjectID, $iChildID, $pAccessible, $tVarChild ) = $S_OK Then
    $oAccessible = ObjCreateInterface( $pAccessible, $sIID_IAccessible, $dtagIAccessible )

    ; Get parent objects to top window
    Local $pParent, $oObject = $oAccessible, $pPrev, $oPrev, $sName
    Do
      $pPrev = $pParent
      $oPrev = $oObject
      $oObject.get_accParent( $pParent )
      $oObject = ObjCreateInterface( $pParent, $sIID_IAccessible, $dtagIAccessible )
	  if isobj($oObject) Then
		        $oObject.get_accName( $CHILDID_SELF, $sName )
			Else
	  $sName=""
	  EndIf

	Until String( $sName ) = $cDesktopName

    ; Name of top window (previous to desktop)
    $oPrev.get_accName( $CHILDID_SELF, $sName )

    ConsoleWrite( "Focus event:" & @CRLF )
    ConsoleWrite( "Program = " & $sName & @CRLF )
    PrintElementInfo( $oAccessible, $iChildID, "" )
  EndIf

EndFunc


Func Close()
  UnhookWinEvent( $hMenuEventHook )
  DllCallbackFree( $hMenuEventProc )
  UnhookWinEvent( $hFocusEventHook )
  DllCallbackFree( $hFocusEventProc )
  Exit
EndFunc