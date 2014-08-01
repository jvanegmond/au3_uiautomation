#include-once

#include "MSAccessibility.au3"

; https://developer.mozilla.org/en-US/docs/Web/Accessibility/AT-APIs/ImplementationFeatures/MSAA

Global Const $NODETYPE_ELEMENT = 1
Global Const $NODETYPE_ATTRIBUTE = 2
Global Const $NODETYPE_TEXT = 3
Global Const $NODETYPE_CDATA_SECTION = 4
Global Const $NODETYPE_ENTITY_REFERENCE = 5
Global Const $NODETYPE_ENTITY = 6
Global Const $NODETYPE_PROCESSING_INSTRUCTION = 7
Global Const $NODETYPE_COMMENT = 8
Global Const $NODETYPE_DOCUMENT = 9
Global Const $NODETYPE_DOCUMENT_TYPE = 10
Global Const $NODETYPE_DOCUMENT_FRAGMENT = 11
Global Const $NODETYPE_NOTATION = 12

Func GetNodeType( $iNodeType )
	Local Static $aNodeTypes[12] = [ _
	"$NODETYPE_ELEMENT", _
	"$NODETYPE_ATTRIBUTE", _
	"$NODETYPE_TEXT", _
	"$NODETYPE_CDATA_SECTION", _
	"$NODETYPE_ENTITY_REFERENCE", _
	"$NODETYPE_ENTITY", _
	"$NODETYPE_PROCESSING_INSTRUCTION", _
	"$NODETYPE_COMMENT", _
	"$NODETYPE_DOCUMENT", _
	"$NODETYPE_DOCUMENT_TYPE", _
	"$NODETYPE_DOCUMENT_FRAGMENT", _
	"$NODETYPE_NOTATION" ]
	If $iNodeType >= 1 And $iNodeType <= 12 Then
		Return $aNodeTypes[$iNodeType-1]
	Else
		Return ""
	EndIf
EndFunc

; http://doxygen.db48x.net/mozilla-full/html/d4/dd6/interfaceISimpleDOMNode.html
Global Const $sIID_ISimpleDOMNode = "{1814CEEB-49E2-407F-AF99-FA755A7D2607}"
Global Const $tIID_ISimpleDOMNode = CLSIDFromString( $sIID_ISimpleDOMNode )
Global $dtagISimpleDOMNode = "nodeInfo hresult(bstr*;short*;bstr*;uint*;uint*;ushort*);" & _
"attributes hresult(ushort;struct*;struct*;struct*;ushort*);" & _
"attributesForNames hresult(ushort;struct*;struct*;struct*);" & _
"computedStyle hresult(ushort;int;struct*;struct*;ushort*);" & _
"computedStyleForProperties hresult(ushort;int;struct*;struct*);" & _
"scrollTo hresult(int);" & _
"parentNode hresult(ptr*);" & _
"firstChild hresult(ptr*);" & _
"lastChild hresult(ptr*);" & _
"previousSibling hresult(ptr*);" & _
"nextSibling hresult(ptr*);" & _
"childAt hresult(uint;ptr*);" & _
"innerHTML hresult(bstr*);" & _
"localInterface hresult(ptr*);" & _
"language hresult(bstr*);"

; http://doxygen.db48x.net/mozilla-full/html/d3/daa/interfaceISimpleDOMText.html
Global Const $sIID_ISimpleDOMText = "{4E747BE5-2052-4265-8AF0-8ECAD7AAD1C0}"
Global Const $tIID_ISimpleDOMText = CLSIDFromString( $sIID_ISimpleDOMText )
Global $dtagISimpleDOMText = "domText hresult(bstr*);" & _
"clippedSubstringBounds hresult(uint;uint;int*;int*;int*;int*);" & _
"unclippedSubstringBounds hresult(uint;uint;int*;int*;int*;int*);" & _
"scrollToSubstring hresult(uint;uint);" & _
"fontFamily hresult(bstr*);"

; http://doxygen.db48x.net/mozilla-full/html/d7/d59/interfaceISimpleDOMDocument.html
Global Const $sIID_ISimpleDOMDocument = "{0D68D6D0-D93D-4D08-A30D-F00DD1F45B24}"
Global Const $tIID_ISimpleDOMDocument = CLSIDFromString( $sIID_ISimpleDOMDocument )
Global $dtagISimpleDOMDocument = "URL hresult(bstr*);" & _
"title hresult(bstr*);" & _
"mimeType hresult(bstr*);" & _
"docType hresult(bstr*);" & _
"nameSpaceURIForID hresult(short;bstr*);" & _
"alternateViewMediaTypes hresult(bstr*);"


; BSTR functions
; Copied and slightly modified from AutoItObject.au3 by the AutoItObject-Team

Func SysAllocString( $str )
	Local $aRet = DllCall( "oleaut32.dll", "ptr", "SysAllocString", "wstr", $str )
	If @error Then Return SetError(1, 0, 0)
	Return $aRet[0]
EndFunc

Func SysFreeString( $pBSTR )
	If Not $pBSTR Then Return SetError(1, 0, 0)
	DllCall( "oleaut32.dll", "none", "SysFreeString", "ptr", $pBSTR )
	If @error Then Return SetError(2, 0, 0)
EndFunc

Func SysReadString( $pBSTR, $iLen = -1 )
	If Not $pBSTR Then Return SetError(1, 0, "")
	If $iLen < 1 Then $iLen = SysStringLen( $pBSTR )
	If $iLen < 1 Then Return SetError(2, 0, "")
	Return DllStructGetData( DllStructCreate( "wchar[" & $iLen & "]", $pBSTR ), 1 )
EndFunc

Func SysStringLen( $pBSTR )
	If Not $pBSTR Then Return SetError(1, 0, 0)
	Local $aRet = DllCall( "oleaut32.dll", "uint", "SysStringLen", "ptr", $pBSTR )
	If @error Then Return SetError(2, 0, 0)
	Return $aRet[0]
EndFunc
