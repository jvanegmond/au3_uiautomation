;~ Example 30 ISimpleDom
;~ SimpleDOM. ISimpleDOM.au3 below contains constants, interface descriptions and functions to implement ISimpleDOM interfaces.
;~ ISimpleDOM is created by Mozilla and is implemented in Firefox and Thunderbird. Google Chrome also supports ISimpleDOM. I'm not aware of other programs that supports ISimpleDOM.
;~ The main interface is ISimpleDOMNode. You get an ISimpleDOMNode interface pointer by using QueryService from an IAccessible object.
;~ There are two other intefaces: ISimpleDOMText and ISimpleDOMDocument. You get pointers to these interfaces with QueryInterface of ISimpleDOMNode.
;~ The documentation is not very accurate. The most accurate documentation can be found in the header files. This is a part of the header files for the three interfaces:

#include "CUIAutomation2.au3"
#include "MSAccessibility.au3"
#include "ISimpleDOM.au3"

#include <Array.au3>

Opt( "MustDeclareVars", 1 )

Global $aInfo[10000], $iInfo = 0
const $cDesktopName="Bureaublad"
;~ const $cDesktopName="Desktop"

MainFunc()


Func MainFunc()

  HotKeySet( "^w", "GetWindowInfo" )
  HotKeySet( "{ESC}", "Close" )

  While Sleep(100)
  WEnd

EndFunc


Func GetWindowInfo()
  Local $aMousePos = MouseGetPos(), $pObject, $tVarChild, $vt, $err = 0
  If AccessibleObjectFromPoint( $aMousePos[0], $aMousePos[1], $pObject, $tVarChild ) = $S_OK Then
    $vt = BitAND( DllStructGetData( $tVarChild, 1, 1 ), 0xFFFF )
    If $vt = $VT_I4 Then
      Local $oObject, $hWnd, $sName = ""
      If WindowFromAccessibleObject( $pObject, $hWnd ) = $S_OK Then

        AccessibleObjectFromWindow( $hWnd, $OBJID_CLIENT, $tIID_IAccessible, $pObject )
        $oObject = ObjCreateInterface( $pObject, $sIID_IAccessible, $dtagIAccessible )

        ; Get parent objects to top window
        Local $pParent, $pPrev, $oPrev, $iRole
        Do
          $pPrev = $pParent
          $oPrev = $oObject
          $oObject.get_accParent( $pParent )
          $oObject = ObjCreateInterface( $pParent, $sIID_IAccessible, $dtagIAccessible )
          $oObject.get_accName( $CHILDID_SELF, $sName )
        Until String( $sName ) = $cDesktopName

        ; Info for top window (previous to desktop)
        PrintElementInfoToArray( $pPrev, $oPrev, $CHILDID_SELF, "" )

        ; Info for child objects of the top window
        If $oPrev.get_accRole( $CHILDID_SELF, $iRole ) = $S_OK And $iRole = $ROLE_SYSTEM_WINDOW Then
          WindowFromAccessibleObject( $pPrev, $hWnd )
          PrintWindowObjects( $hWnd )
        Else
          $err = 1
        EndIf

      Else
        $err = 1
      EndIf
    Else
      $err = 1
    EndIf
  Else
    $err = 1
  EndIf
  If $err Then _
    MsgBox( 0, "ISimpleDOM interfaces", _
               "AccessibleObjectFromPoint failed." & @CRLF & _
               "Try another point e.g. the window title bar." )
EndFunc


Func PrintWindowObjects( $hWindow )

  ; Object from window
  Local $pWindow, $oWindow
  AccessibleObjectFromWindow( $hWindow, $OBJID_CLIENT, $tIID_IAccessible, $pWindow )
  $oWindow = ObjCreateInterface( $pWindow, $sIID_IAccessible, $dtagIAccessible )
  If Not IsObj( $oWindow ) Then Return

  ; Get window objects
  WalkTreeWithAccessibleChildren( $pWindow, 0, 8 )

  ; Print window objects
  ReDim $aInfo[$iInfo]
  _ArrayDisplay( $aInfo, "ISimpleDOM interfaces" )
  ReDim $aInfo[10000]
  $iInfo = 0

EndFunc


Func WalkTreeWithAccessibleChildren( $pAcc, $iLevel, $iLevels = 0 )

  If $iLevels And $iLevel = $iLevels Then Return

  ; Create object
  Local $oAcc = ObjCreateInterface( $pAcc, $sIID_IAccessible, $dtagIAccessible )
  If Not IsObj( $oAcc ) Then Return
  $oAcc.AddRef()

  ; Indentation
  Local $sIndent = ""
  For $i = 0 To $iLevel - 1
    $sIndent &= "    "
  Next

  Local $iChildCount, $iReturnCount, $tVarChildren

  ; Get children
  If $oAcc.get_accChildCount( $iChildCount ) Or Not $iChildCount Then Return
  If AccessibleChildren( $pAcc, 0, $iChildCount, $tVarChildren, $iReturnCount ) Then Return

  Local $vt, $pChildObj, $oChildObj
  Local $pService, $oService, $pISimpleDOMNode, $oISimpleDOMNode, $pISimpleDOM, $oISimpleDOM

  ; $oISimpleDOMNode.nodeInfo
  Local $sNodeName, $iNameSpaceID, $sNodeValue, $iNumChildren, $iUniqueID, $iNodeType, $sInnerHTML

  ; $oISimpleDOMNode.attributes
  Local $iMaxAttribs = 100, $iNumAttribs
  Local $tAttribNames  = DllStructCreate( "ptr[" & $iMaxAttribs & "]" ),   $sAttribName
  Local $tNameSpaceIDs = DllStructCreate( "short[" & $iMaxAttribs & "]" ), $iNameSpaceID
  Local $tAttribValues = DllStructCreate( "ptr[" & $iMaxAttribs & "]" ),   $sAttribValue

  ; $oISimpleDOMNode.computedStyle
  Local $iMaxStyleProperties = 100, $iNumStyleProperties
  Local $tStyleProperties = DllStructCreate( "ptr[" & $iMaxStyleProperties & "]" ), $sStyleProperty
  Local $tStyleValues     = DllStructCreate( "ptr[" & $iMaxStyleProperties & "]" ), $sStyleValue

  ; For each child
  For $i = 1 To $iReturnCount

    ; $tVarChildren is an array of VARIANTs with information about the children
    $vt = BitAND( DllStructGetData( $tVarChildren, $i, 1 ), 0xFFFF )

    If $vt = $VT_DISPATCH Then

      ; Child object

      $pChildObj = DllStructGetData( $tVarChildren, $i, 3 )
      $oChildObj = ObjCreateInterface( $pChildObj, $sIID_IAccessible, $dtagIAccessible )

      If IsObj( $oChildObj ) Then

        ; Try to get an ISimpleDOMNode interface pointer for the child object
        If $oChildObj.QueryInterface( DllStructGetPtr( $tIID_IServiceProvider ), $pService ) = $S_OK Then
          $oService = ObjCreateInterface( $pService, $sIID_IServiceProvider, $dtagIServiceProvider )
          If $oService.QueryService( $tIID_ISimpleDOMNode, $tIID_ISimpleDOMNode, $pISimpleDOMNode ) = $S_OK Then
            $aInfo[$iInfo] = $sIndent & "$pISimpleDOMNode = " & Ptr( $pISimpleDOMNode )
            $iInfo += 1
            $oISimpleDOMNode = ObjCreateInterface( $pISimpleDOMNode, $sIID_ISimpleDOMNode, $dtagISimpleDOMNode )
            If IsObj( $oISimpleDOMNode ) Then
              $oISimpleDOMNode.nodeInfo( $sNodeName, $iNameSpaceID, $sNodeValue, $iNumChildren, $iUniqueID, $iNodeType )
              $aInfo[$iInfo+0] = $sIndent & "$sNodeName       = " & $sNodeName
              $aInfo[$iInfo+1] = $sIndent & "$iNameSpaceID    = " & $iNameSpaceID
              $aInfo[$iInfo+2] = $sIndent & "$sNodeValue      = " & $sNodeValue
              $aInfo[$iInfo+3] = $sIndent & "$iNumChildren    = " & $iNumChildren
              $aInfo[$iInfo+4] = $sIndent & "$iUniqueID       = " & $iUniqueID
              $aInfo[$iInfo+5] = $sIndent & "$iNodeType       = " & $iNodeType & " (" & GetNodeType( $iNodeType ) & ")"
              $iInfo += 6

              ; $oISimpleDOMNode.attributes
              $oISimpleDOMNode.attributes( $iMaxAttribs, $tAttribNames, $tNameSpaceIDs, $tAttribValues, $iNumAttribs )
              $aInfo[$iInfo] = $sIndent & "$iNumAttribs     = " & $iNumAttribs
              $iInfo += 1
              For $j = 1 To $iNumAttribs
                $sAttribName  = SysReadString( DllStructGetData( $tAttribNames, 1, $j ) )
                $sAttribValue = SysReadString( DllStructGetData( $tAttribValues, 1, $j ) )
                $iNameSpaceID = DllStructGetData( $tNameSpaceIDs, 1, $j )
                $aInfo[$iInfo+0] = "    " & $sIndent & "$iAttrib      = " & $j
                $aInfo[$iInfo+1] = "    " & $sIndent & "$sAttribName  = " & $sAttribName
                $aInfo[$iInfo+2] = "    " & $sIndent & "$sAttribValue = " & $sAttribValue
                $aInfo[$iInfo+3] = "    " & $sIndent & "$iNameSpaceID = " & $iNameSpaceID
                $iInfo += 4
                ; Free memory allocated by BSTRs
                SysFreeString( DllStructGetData( $tAttribNames, 1, $j ) )
                SysFreeString( DllStructGetData( $tAttribValues, 1, $j ) )
              Next

              ; $oISimpleDOMNode.computedStyle
              $oISimpleDOMNode.computedStyle( $iMaxStyleProperties, 0, $tStyleProperties, $tStyleValues, $iNumStyleProperties )
              $aInfo[$iInfo] = $sIndent & "$iNumStyleProps  = " & $iNumStyleProperties
              $iInfo += 1
              For $j = 1 To $iNumStyleProperties
                $sStyleProperty = SysReadString( DllStructGetData( $tStyleProperties, 1, $j ) )
                $sStyleValue    = SysReadString( DllStructGetData( $tStyleValues, 1, $j ) )
                $aInfo[$iInfo+0] = "    " & $sIndent & "$iStyle       = " & $j
                $aInfo[$iInfo+1] = "    " & $sIndent & "$sStyleProp   = " & $sStyleProperty
                $aInfo[$iInfo+2] = "    " & $sIndent & "$sStyleValue  = " & $sStyleValue
                $iInfo += 3
                ; Free memory allocated by BSTRs
                SysFreeString( DllStructGetData( $tStyleProperties, 1, $j ) )
                SysFreeString( DllStructGetData( $tStyleValues, 1, $j ) )
              Next

              ;$oISimpleDOMNode.innerHTML( $sInnerHTML )
              ;If String( $sInnerHTML ) <> "0" Then
              ;  $aInfo[$iInfo] = $sIndent & "$sInnerHTML      = " & $sInnerHTML
              ;  $iInfo += 1
              ;EndIf

              If $iNodeType = 3 Then ; $NODETYPE_TEXT
                ; Try to get an ISimpleDOMText interface pointer with $oISimpleDOMNode.QueryInterface
                If $oISimpleDOMNode.QueryInterface( DllStructGetPtr( $tIID_ISimpleDOMText ), $pISimpleDOM ) = $S_OK Then
                  $aInfo[$iInfo] = $sIndent & "$pISimpleDOMText = " & Ptr( $pISimpleDOM )
                  $iInfo += 1
                  $oISimpleDOM = ObjCreateInterface( $pISimpleDOM, $sIID_ISimpleDOMText, $dtagISimpleDOMText )
                  If IsObj( $oISimpleDOM ) Then
                    Local $sDomText
                    $oISimpleDOM.domText( $sDomText )
                    $aInfo[$iInfo] = $sIndent & "$sDomText        = " & $sDomText
                    $iInfo += 1
                  EndIf
                EndIf

              ElseIf $iNodeType = 9 Then ; $NODETYPE_DOCUMENT
                ; Try to get an ISimpleDOMDocument interface pointer with $oISimpleDOMNode.QueryInterface
                If $oISimpleDOMNode.QueryInterface( DllStructGetPtr( $tIID_ISimpleDOMDocument ), $pISimpleDOM ) = $S_OK Then
                  $aInfo[$iInfo] = $sIndent & "$pISimpleDOMDocument = " & Ptr( $pISimpleDOM )
                  $iInfo += 1
                  $oISimpleDOM = ObjCreateInterface( $pISimpleDOM, $sIID_ISimpleDOMDocument, $dtagISimpleDOMDocument )
                  If IsObj( $oISimpleDOM ) Then
                    Local $sURL, $sTitle, $sMimeType, $sDocType
                    $oISimpleDOM.URL( $sURL )
                    $oISimpleDOM.title( $sTitle )
                    $oISimpleDOM.mimeType( $sMimeType )
                    $oISimpleDOM.docType( $sDocType )
                    $aInfo[$iInfo+0] = $sIndent & "$sURL                = " & $sURL
                    $aInfo[$iInfo+1] = $sIndent & "$sTitle              = " & $sTitle
                    $aInfo[$iInfo+2] = $sIndent & "$sMimeType           = " & $sMimeType
                    $aInfo[$iInfo+3] = $sIndent & "$sDocType            = " & $sDocType
                    $iInfo += 4
                  EndIf
                EndIf
              EndIf

            EndIf
          EndIf
        EndIf

        PrintElementInfoToArray( $pChildObj, $oChildObj, $CHILDID_SELF, $sIndent )
        WalkTreeWithAccessibleChildren( $pChildObj, $iLevel + 1, $iLevels )

      EndIf

    EndIf

  Next

EndFunc


Func PrintElementInfoToArray( $pElement, $oElement, $iChild, $sIndent )
  Local $hWnd, $sName, $iRole, $sRole, $iRoleLen
  Local $iState, $sState, $iStateLen
  Local $sValue, $x, $y, $w, $h
  If $iChild <> $CHILDID_SELF Then
    $aInfo[$iInfo] = $sIndent & "$iChildElem = " & $iChild
    $iInfo += 1
  EndIf
  If $iChild = $CHILDID_SELF And $oElement.get_accRole( $CHILDID_SELF, $iRole ) = $S_OK And $iRole = $ROLE_SYSTEM_WINDOW Then
    WindowFromAccessibleObject( $pElement, $hWnd )
    $aInfo[$iInfo] = $sIndent & "$hWnd   = " & $hWnd
    $iInfo += 1
  EndIf
  $oElement.get_accName( $iChild, $sName )
  $aInfo[$iInfo] = $sIndent & "$sName  = " & $sName
  $iInfo += 1
  If $oElement.get_accRole( $iChild, $iRole ) = $S_OK Then
    $aInfo[$iInfo] = $sIndent & "$iRole  = 0x" & Hex( $iRole )
    $iInfo += 1
    $iRoleLen = GetRoleText( $iRole, 0, 0 ) + 1
    $sRole = DllStructCreate( "wchar[" & $iRoleLen & "]" )
    GetRoleText( $iRole, DllStructGetPtr( $sRole ), $iRoleLen )
    $aInfo[$iInfo] = $sIndent & "$sRole  = " & DllStructGetData( $sRole, 1 )
    $iInfo += 1
  EndIf
  If $oElement.get_accState( $iChild, $iState ) = $S_OK Then
    $aInfo[$iInfo] = $sIndent & "$iState = 0x" & Hex( $iState )
    $iInfo += 1
    $iStateLen = GetStateText( $iState, 0, 0 ) + 1
    $sState = DllStructCreate( "wchar[" & $iStateLen & "]" )
    GetStateText( $iState, DllStructGetPtr( $sState ), $iStateLen )
    $aInfo[$iInfo] = $sIndent & "$sState = " & DllStructGetData( $sState, 1 )
    $iInfo += 1
  EndIf
  If $oElement.get_accValue( $iChild, $sValue ) = $S_OK Then
    $aInfo[$iInfo] = $sIndent & "$sValue = " & $sValue
    $iInfo += 1
  EndIf
  IF $oElement.accLocation( $x, $y, $w, $h, $iChild ) = $S_OK Then
    $aInfo[$iInfo] = $sIndent & "$x, $y, $w, $h = " & $x & ", " & $y & ", " & $w & ", " & $h
    $iInfo += 1
  EndIf
  $aInfo[$iInfo] = ""
  $iInfo += 1
EndFunc


Func Close()
  Exit
EndFunc