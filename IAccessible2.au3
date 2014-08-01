#include-once

#include "MSAccessibility.au3"

; A structure defining the locale of an accessible object
Global Const $tagIA2Locale = "ptr language; ptr country; ptr variant"

; A structure defining the type of and extents of changes made to a table
Global Const $tagIA2TableModelChange = "int type; long firstRow; long lastRow; long firstColumn; long lastColumn"

; A structure containing a substring and the start and end offsets in the enclosing string
Global Const $tagIA2TextSegment = "ptr text; long start; long end"

; Use the following constants to compare against the strings returned by IAccessibleRelation::relationType
Global Const $IA2_RELATION_CONTAINING_APPLICATION = "containingApplication" 
Global Const $IA2_RELATION_CONTAINING_DOCUMENT    = "containingDocument" 
Global Const $IA2_RELATION_CONTAINING_TAB_PANE    = "containingTabPane" 
Global Const $IA2_RELATION_CONTAINING_WINDOW      = "containingWindow" 
Global Const $IA2_RELATION_CONTROLLED_BY          = "controlledBy" 
Global Const $IA2_RELATION_CONTROLLER_FOR         = "controllerFor" 
Global Const $IA2_RELATION_DESCRIBED_BY           = "describedBy" 
Global Const $IA2_RELATION_DESCRIPTION_FOR        = "descriptionFor" 
Global Const $IA2_RELATION_EMBEDDED_BY            = "embeddedBy" 
Global Const $IA2_RELATION_EMBEDS                 = "embeds" 
Global Const $IA2_RELATION_FLOWS_FROM             = "flowsFrom" 
Global Const $IA2_RELATION_FLOWS_TO               = "flowsTo" 
Global Const $IA2_RELATION_LABEL_FOR              = "labelFor" 
Global Const $IA2_RELATION_LABELED_BY             = "labelledBy" 
Global Const $IA2_RELATION_LABELLED_BY            = "labelledBy" 
Global Const $IA2_RELATION_MEMBER_OF              = "memberOf" 
Global Const $IA2_RELATION_NEXT_TABBABLE          = "nextTabbable" 
Global Const $IA2_RELATION_NODE_CHILD_OF          = "nodeChildOf" 
Global Const $IA2_RELATION_NODE_PARENT_OF         = "nodeParentOf" 
Global Const $IA2_RELATION_PARENT_WINDOW_OF       = "parentWindowOf" 
Global Const $IA2_RELATION_POPUP_FOR              = "popupFor" 
Global Const $IA2_RELATION_PREVIOUS_TABBABLE      = "previousTabbable" 
Global Const $IA2_RELATION_SUBWINDOW_OF           = "subwindowOf" 

; enum IA2Actions
; This enum defines values which are predefined actions for use when implementing support for media.
; This enum is used when specifying an action for IAccessibleAction::doAction.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_accessible_action_8idl.html
Global Enum _
$IA2_ACTION_OPEN = -1, _
$IA2_ACTION_COMPLETE = -2, _
$IA2_ACTION_CLOSE = -3

; enum IA2CoordinateType
; These constants define which coordinate system a point is located in.
; This enum is used in IAccessible2::scrollToPoint, IAccessibleImage::imagePosition,
; IAccessibleText::characterExtents, IAccessibleText::offsetAtPoint, and IAccessibleText::scrollSubstringToPoint. 
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_i_a2_common_types_8idl.html
Global Enum _
$IA2_COORDTYPE_SCREEN_RELATIVE, _
$IA2_COORDTYPE_PARENT_RELATIVE

; enum IA2EventID
; IAccessible2 specific event constants.
; This enum defines the event IDs fired by IAccessible2 objects. The event IDs are in addition to those used by MSAA.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_accessible_event_i_d_8idl.html
Global Enum _
$IA2_EVENT_ACTION_CHANGED = 0x101, _
$IA2_EVENT_ACTIVE_DECENDENT_CHANGED, _
$IA2_EVENT_ACTIVE_DESCENDANT_CHANGED = $IA2_EVENT_ACTIVE_DECENDENT_CHANGED, _
$IA2_EVENT_DOCUMENT_ATTRIBUTE_CHANGED, _
$IA2_EVENT_DOCUMENT_CONTENT_CHANGED, _
$IA2_EVENT_DOCUMENT_LOAD_COMPLETE, _
$IA2_EVENT_DOCUMENT_LOAD_STOPPED, _
$IA2_EVENT_DOCUMENT_RELOAD, _
$IA2_EVENT_HYPERLINK_END_INDEX_CHANGED, _
$IA2_EVENT_HYPERLINK_NUMBER_OF_ANCHORS_CHANGED, _
$IA2_EVENT_HYPERLINK_SELECTED_LINK_CHANGED, _
$IA2_EVENT_HYPERTEXT_LINK_ACTIVATED, _
$IA2_EVENT_HYPERTEXT_LINK_SELECTED, _
$IA2_EVENT_HYPERLINK_START_INDEX_CHANGED, _
$IA2_EVENT_HYPERTEXT_CHANGED, _
$IA2_EVENT_HYPERTEXT_NLINKS_CHANGED, _
$IA2_EVENT_OBJECT_ATTRIBUTE_CHANGED, _
$IA2_EVENT_PAGE_CHANGED, _
$IA2_EVENT_SECTION_CHANGED, _
$IA2_EVENT_TABLE_CAPTION_CHANGED, _
$IA2_EVENT_TABLE_COLUMN_DESCRIPTION_CHANGED, _
$IA2_EVENT_TABLE_COLUMN_HEADER_CHANGED, _
$IA2_EVENT_TABLE_MODEL_CHANGED, _
$IA2_EVENT_TABLE_ROW_DESCRIPTION_CHANGED, _
$IA2_EVENT_TABLE_ROW_HEADER_CHANGED, _
$IA2_EVENT_TABLE_SUMMARY_CHANGED, _
$IA2_EVENT_TEXT_ATTRIBUTE_CHANGED, _
$IA2_EVENT_TEXT_CARET_MOVED, _
$IA2_EVENT_TEXT_CHANGED, _
$IA2_EVENT_TEXT_COLUMN_CHANGED, _
$IA2_EVENT_TEXT_INSERTED, _
$IA2_EVENT_TEXT_REMOVED, _
$IA2_EVENT_TEXT_UPDATED, _
$IA2_EVENT_TEXT_SELECTION_CHANGED, _
$IA2_EVENT_VISIBLE_DATA_CHANGED

; enum IA2Role
; Collection of roles
; This enumerator defines an extended set of accessible roles of objects implementing the IAccessible2 interface.
; These roles are in addition to the MSAA roles obtained through the MSAA get_accRole method.
; Examples are 'footnote', 'heading', and 'label'. You obtain an object's IAccessible2 roles by calling IAccessible2::role.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_accessible_role_8idl.html
Global Enum _
$IA2_ROLE_UNKNOWN = 0, _
$IA2_ROLE_CANVAS = 0x401, _
$IA2_ROLE_CAPTION, _
$IA2_ROLE_CHECK_MENU_ITEM, _
$IA2_ROLE_COLOR_CHOOSER, _
$IA2_ROLE_DATE_EDITOR, _
$IA2_ROLE_DESKTOP_ICON, _
$IA2_ROLE_DESKTOP_PANE, _
$IA2_ROLE_DIRECTORY_PANE, _
$IA2_ROLE_EDITBAR, _
$IA2_ROLE_EMBEDDED_OBJECT, _
$IA2_ROLE_ENDNOTE, _
$IA2_ROLE_FILE_CHOOSER, _
$IA2_ROLE_FONT_CHOOSER, _
$IA2_ROLE_FOOTER, _
$IA2_ROLE_FOOTNOTE, _
$IA2_ROLE_FORM, _
$IA2_ROLE_FRAME, _
$IA2_ROLE_GLASS_PANE, _
$IA2_ROLE_HEADER, _
$IA2_ROLE_HEADING, _
$IA2_ROLE_ICON, _
$IA2_ROLE_IMAGE_MAP, _
$IA2_ROLE_INPUT_METHOD_WINDOW, _
$IA2_ROLE_INTERNAL_FRAME, _
$IA2_ROLE_LABEL, _
$IA2_ROLE_LAYERED_PANE, _
$IA2_ROLE_NOTE, _
$IA2_ROLE_OPTION_PANE, _
$IA2_ROLE_PAGE, _
$IA2_ROLE_PARAGRAPH, _
$IA2_ROLE_RADIO_MENU_ITEM, _
$IA2_ROLE_REDUNDANT_OBJECT, _
$IA2_ROLE_ROOT_PANE, _
$IA2_ROLE_RULER, _
$IA2_ROLE_SCROLL_PANE, _
$IA2_ROLE_SECTION, _
$IA2_ROLE_SHAPE, _
$IA2_ROLE_SPLIT_PANE, _
$IA2_ROLE_TEAR_OFF_MENU, _
$IA2_ROLE_TERMINAL, _
$IA2_ROLE_TEXT_FRAME, _
$IA2_ROLE_TOGGLE_BUTTON, _
$IA2_ROLE_VIEW_PORT, _
$IA2_ROLE_COMPLEMENTARY_CONTENT

Func GetIA2Role( $iIA2Role )
	Local Static $aIA2Roles[44] = [ _
	"$IA2_ROLE_CANVAS", _
	"$IA2_ROLE_CAPTION", _
	"$IA2_ROLE_CHECK_MENU_ITEM", _
	"$IA2_ROLE_COLOR_CHOOSER", _
	"$IA2_ROLE_DATE_EDITOR", _
	"$IA2_ROLE_DESKTOP_ICON", _
	"$IA2_ROLE_DESKTOP_PANE", _
	"$IA2_ROLE_DIRECTORY_PANE", _
	"$IA2_ROLE_EDITBAR", _
	"$IA2_ROLE_EMBEDDED_OBJECT", _
	"$IA2_ROLE_ENDNOTE", _
	"$IA2_ROLE_FILE_CHOOSER", _
	"$IA2_ROLE_FONT_CHOOSER", _
	"$IA2_ROLE_FOOTER", _
	"$IA2_ROLE_FOOTNOTE", _
	"$IA2_ROLE_FORM", _
	"$IA2_ROLE_FRAME", _
	"$IA2_ROLE_GLASS_PANE", _
	"$IA2_ROLE_HEADER", _
	"$IA2_ROLE_HEADING", _
	"$IA2_ROLE_ICON", _
	"$IA2_ROLE_IMAGE_MAP", _
	"$IA2_ROLE_INPUT_METHOD_WINDOW", _
	"$IA2_ROLE_INTERNAL_FRAME", _
	"$IA2_ROLE_LABEL", _
	"$IA2_ROLE_LAYERED_PANE", _
	"$IA2_ROLE_NOTE", _
	"$IA2_ROLE_OPTION_PANE", _
	"$IA2_ROLE_PAGE", _
	"$IA2_ROLE_PARAGRAPH", _
	"$IA2_ROLE_RADIO_MENU_ITEM", _
	"$IA2_ROLE_REDUNDANT_OBJECT", _
	"$IA2_ROLE_ROOT_PANE", _
	"$IA2_ROLE_RULER", _
	"$IA2_ROLE_SCROLL_PANE", _
	"$IA2_ROLE_SECTION", _
	"$IA2_ROLE_SHAPE", _
	"$IA2_ROLE_SPLIT_PANE", _
	"$IA2_ROLE_TEAR_OFF_MENU", _
	"$IA2_ROLE_TERMINAL", _
	"$IA2_ROLE_TEXT_FRAME", _
	"$IA2_ROLE_TOGGLE_BUTTON", _
	"$IA2_ROLE_VIEW_PORT", _
	"$IA2_ROLE_COMPLEMENTARY_CONTENT" ]
	If $iIA2Role >= 0x401 And $iIA2Role < 0x401 + 44 Then
		Return $aIA2Roles[$iIA2Role-0x401]
	Else
		Return ""
	EndIf
EndFunc

; enum IA2ScrollType
; These constants control the scrolling of an object or substring into a window.
; This enum is used in IAccessible2::scrollTo and IAccessibleText::scrollSubstringTo.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_i_a2_common_types_8idl.html
Global Enum _
$IA2_SCROLL_TYPE_TOP_LEFT, _
$IA2_SCROLL_TYPE_BOTTOM_RIGHT, _
$IA2_SCROLL_TYPE_TOP_EDGE, _
$IA2_SCROLL_TYPE_BOTTOM_EDGE, _
$IA2_SCROLL_TYPE_LEFT_EDGE, _
$IA2_SCROLL_TYPE_RIGHT_EDGE, _
$IA2_SCROLL_TYPE_ANYWHERE

; enum IA2States
; IAccessible2 specific state bit constants
; This enum defines the state bits returned by IAccessible2::states. The IAccessible2 state bits are in addition to those returned by MSAA.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_accessible_states_8idl.html
Global Enum _
$IA2_STATE_ACTIVE = 0x1, _
$IA2_STATE_ARMED = 0x2, _
$IA2_STATE_DEFUNCT = 0x4, _
$IA2_STATE_EDITABLE = 0x8, _
$IA2_STATE_HORIZONTAL = 0x10, _
$IA2_STATE_ICONIFIED = 0x20, _
$IA2_STATE_INVALID_ENTRY = 0x40, _
$IA2_STATE_MANAGES_DESCENDANTS = 0x80, _
$IA2_STATE_MODAL = 0x100, _
$IA2_STATE_MULTI_LINE = 0x200, _
$IA2_STATE_OPAQUE = 0x400, _
$IA2_STATE_REQUIRED = 0x800, _
$IA2_STATE_SELECTABLE_TEXT = 0x1000, _
$IA2_STATE_SINGLE_LINE = 0x2000, _
$IA2_STATE_STALE = 0x4000, _
$IA2_STATE_SUPPORTS_AUTOCOMPLETION = 0x8000, _
$IA2_STATE_TRANSIENT = 0x10000, _
$IA2_STATE_VERTICAL = 0x20000, _
$IA2_STATE_CHECKABLE = 0x40000, _
$IA2_STATE_PINNED = 0x80000

; enum IA2TableModelChangeType
; These constants specify the kind of change made to a table.
; This enum is used in the IA2TableModelChange struct which in turn is used by IAccessibleTable::modelChange and IAccessibleTable2::modelChange.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_i_a2_common_types_8idl.html
Global Enum _
$IA2_TABLE_MODEL_CHANGE_INSERT, _
$IA2_TABLE_MODEL_CHANGE_DELETE, _
$IA2_TABLE_MODEL_CHANGE_UPDATE

; enum IA2TextBoundaryType
; This enum defines values which specify a text boundary type.
; IA2_TEXT_BOUNDARY_SENTENCE is optional. When a method doesn't implement this method it must return S_FALSE. Typically this
; feature would not be implemented by an application. However, if the application developer was not satisfied with how screen
; readers have handled the reading of sentences this boundary type could be implemented and screen readers could use the appli-
; cation's version of a sentence rather than the screen reader's. The rest of the boundary types must be supported.
; This enum is used in IAccessibleText::textBeforeOffset, IAccessibleText::textAtOffset, and IAccessibleText::textAfterOffset.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_accessible_text_8idl.html
Global Enum _
$IA2_TEXT_BOUNDARY_CHAR, _
$IA2_TEXT_BOUNDARY_WORD, _
$IA2_TEXT_BOUNDARY_SENTENCE, _
$IA2_TEXT_BOUNDARY_PARAGRAPH, _
$IA2_TEXT_BOUNDARY_LINE, _
$IA2_TEXT_BOUNDARY_ALL

; enum IA2TextSpecialOffsets
; Special offsets for use in IAccessibleText and IAccessibleEditableText methods
; Refer to Special Offsets for use in the IAccessibleText and IAccessibleEditableText Methods for more information.
; http://accessibility.linuxfoundation.org/a11yspecs/ia2/docs/html/_i_a2_common_types_8idl.html
Global Enum _
$IA2_TEXT_OFFSET_LENGTH = -1, _
$IA2_TEXT_OFFSET_CARET = -2

Global Const $sIID_IAccessible2 = "{E89F726E-C4F4-4C19-BB19-B647D7FA8478}"
Global Const $tIID_IAccessible2 = CLSIDFromString( $sIID_IAccessible2 )
Global $dtagIAccessible2 = $dtagIAccessible & _ ; Inherits from IAccessible
"nRelations hresult(long*);" & _
"relation hresult(long;ptr*);" & _
"relations hresult(long;ptr*;long*);" & _
"role hresult(long*);" & _
"scrollTo hresult(int);" & _
"scrollToPoint hresult(int;long;long);" & _
"groupPosition hresult(long*;long*;long*);" & _
"states hresult(int*);" & _
"extendedRole hresult(bstr*);" & _
"localizedExtendedRole hresult(bstr*);" & _
"nExtendedStates hresult(long*);" & _
"extendedStates hresult(long;ptr*;long*);" & _
"localizedExtendedStates hresult(long;ptr*;long*);" & _
"uniqueID hresult(long*);" & _
"windowHandle hresult(hwnd*);" & _
"indexInParent hresult(long*);" & _
"locale hresult(ptr*);" & _
"attributes hresult(bstr*);"

Global Const $sIID_IAccessible2_2 = "{6C9430E9-299D-4E6F-BD01-A82A1E88D3FF}"
Global Const $tIID_IAccessible2_2 = CLSIDFromString( $sIID_IAccessible2_2 )
Global $dtagIAccessible2_2 = $dtagIAccessible2 & _ ; Inherits from IAccessible2
"attribute hresult(bstr;variant*);" & _
"accessibleWithCaret hresult(ptr*;long*);" & _
"relationTargetsOfType hresult(bstr;long;ptr*;long*);"

Global Const $sIID_IAccessibleAction = "{B70D9F59-3B5A-4DBA-AB9E-22012F607DF5}"
Global Const $tIID_IAccessibleAction = CLSIDFromString( $sIID_IAccessibleAction )
Global $dtagIAccessibleAction = "nActions hresult(long*);" & _
"doAction hresult(long);" & _
"description hresult(long;bstr*);" & _
"keyBinding hresult(long;long;ptr*;long*);" & _
"name hresult(long;bstr*);" & _
"localizedName hresult(long;bstr*);"

Global Const $sIID_IAccessibleApplication = "{D49DED83-5B25-43F4-9B95-93B44595979E}"
Global Const $tIID_IAccessibleApplication = CLSIDFromString( $sIID_IAccessibleApplication )
Global $dtagIAccessibleApplication = "appName hresult(bstr*);" & _
"appVersion hresult(bstr*);" & _
"toolkitName hresult(bstr*);" & _
"toolkitVersion hresult(bstr*);"

Global Const $sIID_IAccessibleComponent = "{1546D4B0-4C98-4BDA-89AE-9A64748BDDE4}"
Global Const $tIID_IAccessibleComponent = CLSIDFromString( $sIID_IAccessibleComponent )
Global $dtagIAccessibleComponent = "locationInParent hresult(long*;long*);" & _
"foreground hresult(long*);" & _
"background hresult(long*);"

Global Const $sIID_IAccessibleDocument = "{C48C7FCF-4AB5-4056-AFA6-902D6E1D1149}"
Global Const $tIID_IAccessibleDocument = CLSIDFromString( $sIID_IAccessibleDocument )
Global $dtagIAccessibleDocument = "anchorTarget hresult(ptr*);"

Global Const $sIID_IAccessibleEditableText = "{A59AA09A-7011-4B65-939D-32B1FB5547E3}"
Global Const $tIID_IAccessibleEditableText = CLSIDFromString( $sIID_IAccessibleEditableText )
Global $dtagIAccessibleEditableText = "copyText hresult(long;long);" & _
"deleteText hresult(long;long);" & _
"insertText hresult(long;bstr);" & _
"cutText hresult(long;long);" & _
"pasteText hresult(long);" & _
"replaceText hresult(long;long;bstr);" & _
"setAttributes hresult(long;long;bstr);"

Global Const $sIID_IAccessibleText = "{24FD2FFB-3AAD-4A08-8335-A3AD89C0FB4B}"
Global Const $tIID_IAccessibleText = CLSIDFromString( $sIID_IAccessibleText )
Global $dtagIAccessibleText = "addSelection hresult(long;long);" & _
"attributes hresult(long;long*;long*;bstr*);" & _
"caretOffset hresult(long*);" & _
"characterExtents hresult(long;int;long*;long*;long*;long*);" & _
"nSelections hresult(long*);" & _
"offsetAtPoint hresult(long;long;int;long*);" & _
"selection hresult(long;long*;long*);" & _
"text hresult(long;long;bstr*);" & _
"textBeforeOffset hresult(long;int;long*;long*;bstr*);" & _
"textAfterOffset hresult(long;int;long*;long*;bstr*);" & _
"textAtOffset hresult(long;int;long*;long*;bstr*);" & _
"removeSelection hresult(long);" & _
"setCaretOffset hresult(long);" & _
"setSelection hresult(long;long;long);" & _
"nCharacters hresult(long*);" & _
"scrollSubstringTo hresult(long;long;int);" & _
"scrollSubstringToPoint hresult(long;long;int;long;long);" & _
"newText hresult(ptr*);" & _
"oldText hresult(ptr*);"

Global Const $sIID_IAccessibleText2 = "{9690A9CC-5C80-4DF5-852E-2D5AE4189A54}"
Global Const $tIID_IAccessibleText2 = CLSIDFromString( $sIID_IAccessibleText2 )
Global $dtagIAccessibleText2 = $dtagIAccessibleText & _ ; Inherits from IAccessibleText
"attributeRange hresult(long:bstr;long*;long*;bstr*);"

Global Const $sIID_IAccessibleHypertext = "{6B4F8BBF-F1F2-418A-B35E-A195BC4103B9}"
Global Const $tIID_IAccessibleHypertext = CLSIDFromString( $sIID_IAccessibleHypertext )
Global $dtagIAccessibleHypertext = $dtagIAccessibleText & _ ; Inherits from IAccessibleText
"nHyperlinks hresult(long*);" & _
"hyperlink hresult(long;ptr*);" & _
"hyperlinkIndex hresult(long;long*);"

Global Const $sIID_IAccessibleHypertext2 = "{CF64D89F-8287-4B44-8501-A827453A6077}"
Global Const $tIID_IAccessibleHypertext2 = CLSIDFromString( $sIID_IAccessibleHypertext2 )
Global $dtagIAccessibleHypertext2 = $dtagIAccessibleHypertext & _ ; Inherits from IAccessibleHypertext
"hyperlinks hresult(ptr*;long*);"

Global Const $sIID_IAccessibleHyperlink = "{01C20F2B-3DD2-400F-949F-AD00BDAB1D41}"
Global Const $tIID_IAccessibleHyperlink = CLSIDFromString( $sIID_IAccessibleHyperlink )
Global $dtagIAccessibleHyperlink = $dtagIAccessibleAction & _ ; Inherits from IAccessibleAction
"anchor hresult(long;variant*);" & _
"anchorTarget hresult(long;variant*);" & _
"startIndex hresult(long*);" & _
"endIndex hresult(long*);" & _
"valid hresult(int*);"

Global Const $sIID_IAccessibleImage = "{FE5ABB3D-615E-4F7B-909F-5F0EDA9E8DDE}"
Global Const $tIID_IAccessibleImage = CLSIDFromString( $sIID_IAccessibleImage )
Global $dtagIAccessibleImage = "description hresult(bstr*);" & _
"imagePosition hresult(int;long*;long*);" & _
"imageSize hresult(long*;long*);"

Global Const $sIID_IAccessibleRelation = "{7CDF86EE-C3DA-496A-BDA4-281B336E1FDC}"
Global Const $tIID_IAccessibleRelation = CLSIDFromString( $sIID_IAccessibleRelation )
Global $dtagIAccessibleRelation = "relationType hresult(bstr*);" & _
"localizedRelationType hresult(bstr*);" & _
"nTargets hresult(long*);" & _
"target hresult(long;ptr*);" & _
"targets hresult(long;ptr*;long*);"

Global Const $sIID_IAccessibleTable = "{35AD8070-C20C-4FB4-B094-F4F7275DD469}" ; Deprecated
Global Const $tIID_IAccessibleTable = CLSIDFromString( $sIID_IAccessibleTable )
Global $dtagIAccessibleTable = "accessibleAt hresult(long;long;ptr*);" & _
"caption hresult(ptr*);" & _
"childIndex hresult(long;long;long*);" & _
"columnDescription hresult(long;bstr*);" & _
"columnExtentAt hresult(long;long;long*);" & _
"columnHeader hresult(ptr*;long*);" & _
"columnIndex hresult(long;long*);" & _
"nColumns hresult(long*);" & _
"nRows hresult(long*);" & _
"nSelectedChildren hresult(long*);" & _
"nSelectedColumns hresult(long*);" & _
"nSelectedRows hresult(long*);" & _
"rowDescription hresult(long;bstr*);" & _
"rowExtentAt hresult(long;long;long*);" & _
"rowHeader hresult(ptr*;long*);" & _
"rowIndex hresult(long;long*);" & _
"selectedChildren hresult(long;ptr*;long*);" & _
"selectedColumns hresult(long;ptr*;long*);" & _
"selectedRows hresult(long;ptr*;long*);" & _
"summary hresult(ptr*);" & _
"isColumnSelected hresult(long;int*);" & _
"isRowSelected hresult(long;int*);" & _
"isSelected hresult(long;long;int*);" & _
"selectRow hresult(long);" & _
"selectColumn hresult(long);" & _
"unselectRow hresult(long);" & _
"unselectColumn hresult(long);" & _
"rowColumnExtentsAtIndex hresult(long;long*;long*;long*;long*;int*);" & _
"modelChange hresult(ptr*);"

Global Const $sIID_IAccessibleTable2 = "{6167F295-06F0-4CDD-A1FA-02E25153D869}"
Global Const $tIID_IAccessibleTable2 = CLSIDFromString( $sIID_IAccessibleTable2 )
Global $dtagIAccessibleTable2 = "cellAt hresult(long;long;ptr*);" & _
"caption hresult(ptr*);" & _
"columnDescription hresult(long;bstr*);" & _
"nColumns hresult(long*);" & _
"nRows hresult(long*);" & _
"nSelectedCells hresult(long*);" & _
"nSelectedColumns hresult(long*);" & _
"nSelectedRows hresult(long*);" & _
"rowDescription hresult(long;bstr*);" & _
"selectedCells hresult(ptr*;long*);" & _
"selectedColumns hresult(ptr*;long*);" & _
"selectedRows hresult(ptr*;long*);" & _
"summary hresult(ptr*);" & _
"isColumnSelected hresult(long;int*);" & _
"isRowSelected hresult(long;int*);" & _
"selectRow hresult(long);" & _
"selectColumn hresult(long);" & _
"unselectRow hresult(long);" & _
"unselectColumn hresult(long);" & _
"modelChange hresult(ptr*);"

Global Const $sIID_IAccessibleTableCell = "{594116B1-C99F-4847-AD06-0A7A86ECE645}"
Global Const $tIID_IAccessibleTableCell = CLSIDFromString( $sIID_IAccessibleTableCell )
Global $dtagIAccessibleTableCell = "columnExtent hresult(long*);" & _
"columnHeaderCells hresult(ptr*;long*);" & _
"columnIndex hresult(long*);" & _
"rowExtent hresult(long*);" & _
"rowHeaderCells hresult(ptr*;long*);" & _
"rowIndex hresult(long*);" & _
"isSelected hresult(int*);" & _
"rowColumnExtents hresult(long*;long*;long*;long*;int*);" & _
"table hresult(ptr*);"

Global Const $sIID_IAccessibleValue = "{35855B5B-C566-4FD0-A7B1-E65465600394}"
Global Const $tIID_IAccessibleValue = CLSIDFromString( $sIID_IAccessibleValue )
Global $dtagIAccessibleValue = "currentValue hresult(variant*);" & _
"setCurrentValue hresult(variant);" & _
"maximumValue hresult(variant*);" & _
"minimumValue hresult(variant*);"
