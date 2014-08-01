#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include "CUIAutomation2.au3"

;~ Version 0.41 + Declared all variables
;~ Version 0.42 july 23rd 2014
;~ - Changed: Added all properties of ui automation to use in expressions
;~            syntax:= "name:=((Zoeken.*)|(Find.*)); ControlType:=Button; acceleratorkey:=Ctrl\+F"
;~ - Changed: _UIA_getAllPropertyValues rewritten based on properties array



; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 thru 3.3.11.5
; Language ......: English (language independent)
; Description ...: Brings UI automation to AutoIt.
; Author(s) .....: junkew
; Copyright .....: Copyright (C) 2013,2014. All rights reserved.
; License .......: GPL or BSD which either of the two fits to your purpose
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;
; ===============================================================================================================================

; #UIAWrappers_CONSTANTS# ===================================================================================================================
;~ Some core default variables frequently to use in wrappers/helpers/global objects and pointers
; ===============================================================================================================================
;~ Global $objUIAutomation          ;Deprecated
;~ Global $oDesktop, $pDesktop      ;Deprecated
;~ Global $oTW, $pTW                ;Deprecated globals Used frequently for treewalking
;~ Global $oUIElement, $pUIElement  ;Used frequently to get an element

Global $UIA_oUIAutomation			;The main library core CUI automation reference
Global $UIA_oDesktop, $UIA_pDesktop	;Desktop will be frequently the starting point

Global $UIA_oUIElement, $UIA_pUIElement  ;Used frequently to get an element

Global $UIA_oTW, $UIA_pTW		 ;Generic treewalker which is allways available
Global $UIA_oTRUECondition       ;TRUE condition easy to be available for treewalking

Global $UIA_Vars                 ;Hold global UIA data in a dictionary object
Global $UIA_DefaultWaitTime=200  ;Frequently it makes sense to have a small waiting time to have windows rebuild, could be set to 0 if good synch is happening

;~ Global $UIA_oParent              ;TODO: Fix later, seems not be able to add parent as an object to DD object $UIA_Vars
Global $UIA_oMainwindow          ;TODO: Fix later, seems not be able to add parent as an object to DD object $UIA_Vars
;~ Global $UIA_oContext             ;TODO: Fix later, seems not be able to add parent as an object to DD object $UIA_Vars


; ===================================================================================================================

; #CONSTANTS# ===================================================================================================================
Local Const $UIA_tryMax=3		 ;Retry
local const $UIA_CFGFileName="UIA.CFG"

;~ Loglevels that can be used in scripting following log4j defined standard
Local const $UIA_Log_Wrapper=5, $_UIA_Log_trace=10, $_UIA_Log_debug=20, $_UIA_Log_info=30, $_UIA_Log_warn =40, $_UIA_Log_error=50, $_UIA_Log_fatal=60
; ===================================================================================================================


_UIA_Init()

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_Init
; Description ...: Initializes the basic stuff for the UI Automation library of MS
; Syntax.........: _UIA_Init()
; Parameters ....: none
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
func _UIA_Init()
	local $UIA_pTRUECondition

;~ 	Dictionary object to store a lot of handy global data
	$UIA_vars=ObjCreate("Scripting.Dictionary")
	$UIA_Vars.comparemode=2 ; Text comparison case insensitive

;~ Check if We can find configuration from file(s)
	_UIA_LoadConfiguration()

;~ The main object with acces to the windows automation api 3.0
	$UIA_oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation)
	If IsObj($UIA_oUIAutomation) = 0 Then
;~ 		msgbox(1,"UI automation failed", "UI Automation failed",10)
		Return SetError(1, 0, 0)
	EndIf

;~ Try to get the desktop as a generic reference/global for all samples
	$UIA_oUIAutomation.GetRootElement($UIA_pDesktop)
	$UIA_oDesktop = ObjCreateInterface($UIA_pDesktop, $sIID_IUIAutomationElement,$dtagIUIAutomationElement)
	If IsObj($UIA_oDesktop) = 0 Then
		msgbox(1,"UI automation desktop failed", "Fatal: UI Automation desktop failed",10)
		Return SetError(2, 0, 0)
	EndIf
;~ 	_UIA_Debug("At least it seems I have the desktop as a frequently used starting point" 	& "[" &_UIA_getPropertyValue($UIA_oDesktop, $UIA_NamePropertyId) & "][" &_UIA_getPropertyValue($UIA_oDesktop, $UIA_ClassNamePropertyId) & "]" & @CRLF, , $UIA_Log_Wrapper)

;~ Have a treewalker available to easily walk around the element trees
	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	$UIA_oTW=ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
    If IsObj($UIA_oTW) = 0 Then
        msgbox(1,"UI automation treewalker failed", "UI Automation failed to setup treewalker",10)
    EndIf

;~ 	Create a true condition for easy reference in treewalkers
	$UIA_oUIAutomation.CreateTrueCondition($UIA_pTrueCondition)
    $UIA_oTRUECondition=ObjCreateInterface($UIA_pTrueCondition, $sIID_IUIAutomationCondition,$dtagIUIAutomationCondition)

	return 1
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_LoadConfiguration
; Description ...: Load all settings from a CFG file
; Syntax.........: _UIA_LoadConfiguration()
; Parameters ....: none
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
func _UIA_LoadConfiguration()

	_UIA_setVar("RTI.ACTIONCOUNT",0)

	;~ 	Some settings to use as a default
	_UIA_setVar("Global.Debug",true)
	_UIA_setVar("Global.Debug.File",true)
	_UIA_setVar("Global.Highlight",true)

;~ 	Check if we can find a configuration file and load it from that file
	if fileexists($UIA_CFGFileName) Then
		_UIA_LoadCFGFile($UIA_CFGFileName)
	EndIf
;~ 		_UIA_Debug("Script name " & stringinstr(@scriptname),  $UIA_Log_Wrapper)
EndFunc

func _UIA_loadCFGFile($strFname )
	Local $var
	Local $sections, $values, $strKey, $strVal, $i, $j

	$sections=IniReadSectionNames($strFName)

	If @error Then
		_UIA_DEBUG("Error occurred on reading " & $strFName & @CRLF,  $UIA_Log_Wrapper)
	Else
;~ 		Load all settings into the dictionary
		For $i = 1 To $sections[0]
			$values=IniReadSection($strFName, $sections[$i])
			If @error Then
				_UIA_DEBUG("Error occurred on reading " & $strFName & @CRLF, $UIA_Log_Wrapper)
			Else
			;~ 		Load all settings into the dictionary
				For $j = 1 To $values[0][0]
					$strKey=$sections[$i] & "." & $values[$j][0]
					$strVal=$values[$j][1]

					if stringlower($strVal)="true" then $strVal=True
					if stringlower($strVal)="false" then $strVal=False
					if stringlower($strVal)="on" then $strVal=true
					if stringlower($strVal)="off" then $strVal=False

					if stringlower($strVal)="minimized" then $strVal=@SW_minimize
					if stringlower($strVal)="maximized" then $strVal=@SW_maximize
					if stringlower($strVal)="normal" then $strVal=@SW_restore

					$strval=stringreplace($strval,"%windowsdir%", @windowsdir)
					$strval=stringreplace($strval,"%programfilesdir%", @programfilesdir)

;~ 					_UIA_DEBUG("Key: [" & $strKey & "] Value: [" &  $strVal & "]" & @CRLF, $UIA_Log_Wrapper)
					_UIA_setvar($strKey,$strVal)
				Next
			EndIf
		Next
	endif
EndFunc

;~ Propertynames to match to numeric values, all names will be lowercased in actual usage case insensitive
;~ local $UIA_propertiesSupportedArray[11][3]=[ _
;~ 	["name",$UIA_NamePropertyId], _
;~ 	["title",$UIA_NamePropertyId], _
;~ 	["automationid",$UIA_AutomationIdPropertyId], _
;~ 	["classname", $UIA_ClassNamePropertyId], _
;~ 	["class", $UIA_ClassNamePropertyId], _
;~ 	["iaccessiblevalue",$UIA_LegacyIAccessibleValuePropertyId], _
;~ 	["iaccessiblechildId", $UIA_LegacyIAccessibleChildIdPropertyId], _
;~ 	["controltype", $UIA_ControlTypePropertyId,1], _
;~ 	["processid", $UIA_ProcessIdPropertyId], _
;~ 	["acceleratorkey", $UIA_AcceleratorKeyPropertyId], _
;~     ["isoffscreen",$UIA_IsOffscreenPropertyId]	_
;~ ]

;~ 23 july added all propertyids

local $UIA_propertiesSupportedArray[115][2]=[ _
["title",$UIA_NamePropertyId], _                                       ; Alternate propertyname
["class", $UIA_ClassNamePropertyId], _									; Alternate propertyname
["iaccessiblevalue",$UIA_LegacyIAccessibleValuePropertyId], _			; Alternate propertyname
["iaccessiblechildId", $UIA_LegacyIAccessibleChildIdPropertyId], _		; Alternate propertyname
["RuntimeId",$UIA_RuntimeIdPropertyId], _
["BoundingRectangle",$UIA_BoundingRectanglePropertyId], _
["ProcessId",$UIA_ProcessIdPropertyId], _
["ControlType",$UIA_ControlTypePropertyId], _
["LocalizedControlType",$UIA_LocalizedControlTypePropertyId], _
["Name",$UIA_NamePropertyId], _
["AcceleratorKey",$UIA_AcceleratorKeyPropertyId], _
["AccessKey",$UIA_AccessKeyPropertyId], _
["HasKeyboardFocus",$UIA_HasKeyboardFocusPropertyId], _
["IsKeyboardFocusable",$UIA_IsKeyboardFocusablePropertyId], _
["IsEnabled",$UIA_IsEnabledPropertyId], _
["AutomationId",$UIA_AutomationIdPropertyId], _
["ClassName",$UIA_ClassNamePropertyId], _
["HelpText",$UIA_HelpTextPropertyId], _
["ClickablePoint",$UIA_ClickablePointPropertyId], _
["Culture",$UIA_CulturePropertyId], _
["IsControlElement",$UIA_IsControlElementPropertyId], _
["IsContentElement",$UIA_IsContentElementPropertyId], _
["LabeledBy",$UIA_LabeledByPropertyId], _
["IsPassword",$UIA_IsPasswordPropertyId], _
["NativeWindowHandle",$UIA_NativeWindowHandlePropertyId], _
["ItemType",$UIA_ItemTypePropertyId], _
["IsOffscreen",$UIA_IsOffscreenPropertyId], _
["Orientation",$UIA_OrientationPropertyId], _
["FrameworkId",$UIA_FrameworkIdPropertyId], _
["IsRequiredForForm",$UIA_IsRequiredForFormPropertyId], _
["ItemStatus",$UIA_ItemStatusPropertyId], _
["IsDockPatternAvailable",$UIA_IsDockPatternAvailablePropertyId], _
["IsExpandCollapsePatternAvailable",$UIA_IsExpandCollapsePatternAvailablePropertyId], _
["IsGridItemPatternAvailable",$UIA_IsGridItemPatternAvailablePropertyId], _
["IsGridPatternAvailable",$UIA_IsGridPatternAvailablePropertyId], _
["IsInvokePatternAvailable",$UIA_IsInvokePatternAvailablePropertyId], _
["IsMultipleViewPatternAvailable",$UIA_IsMultipleViewPatternAvailablePropertyId], _
["IsRangeValuePatternAvailable",$UIA_IsRangeValuePatternAvailablePropertyId], _
["IsScrollPatternAvailable",$UIA_IsScrollPatternAvailablePropertyId], _
["IsScrollItemPatternAvailable",$UIA_IsScrollItemPatternAvailablePropertyId], _
["IsSelectionItemPatternAvailable",$UIA_IsSelectionItemPatternAvailablePropertyId], _
["IsSelectionPatternAvailable",$UIA_IsSelectionPatternAvailablePropertyId], _
["IsTablePatternAvailable",$UIA_IsTablePatternAvailablePropertyId], _
["IsTableItemPatternAvailable",$UIA_IsTableItemPatternAvailablePropertyId], _
["IsTextPatternAvailable",$UIA_IsTextPatternAvailablePropertyId], _
["IsTogglePatternAvailable",$UIA_IsTogglePatternAvailablePropertyId], _
["IsTransformPatternAvailable",$UIA_IsTransformPatternAvailablePropertyId], _
["IsValuePatternAvailable",$UIA_IsValuePatternAvailablePropertyId], _
["IsWindowPatternAvailable",$UIA_IsWindowPatternAvailablePropertyId], _
["ValueValue",$UIA_ValueValuePropertyId], _
["ValueIsReadOnly",$UIA_ValueIsReadOnlyPropertyId], _
["RangeValueValue",$UIA_RangeValueValuePropertyId], _
["RangeValueIsReadOnly",$UIA_RangeValueIsReadOnlyPropertyId], _
["RangeValueMinimum",$UIA_RangeValueMinimumPropertyId], _
["RangeValueMaximum",$UIA_RangeValueMaximumPropertyId], _
["RangeValueLargeChange",$UIA_RangeValueLargeChangePropertyId], _
["RangeValueSmallChange",$UIA_RangeValueSmallChangePropertyId], _
["ScrollHorizontalScrollPercent",$UIA_ScrollHorizontalScrollPercentPropertyId], _
["ScrollHorizontalViewSize",$UIA_ScrollHorizontalViewSizePropertyId], _
["ScrollVerticalScrollPercent",$UIA_ScrollVerticalScrollPercentPropertyId], _
["ScrollVerticalViewSize",$UIA_ScrollVerticalViewSizePropertyId], _
["ScrollHorizontallyScrollable",$UIA_ScrollHorizontallyScrollablePropertyId], _
["ScrollVerticallyScrollable",$UIA_ScrollVerticallyScrollablePropertyId], _
["SelectionSelection",$UIA_SelectionSelectionPropertyId], _
["SelectionCanSelectMultiple",$UIA_SelectionCanSelectMultiplePropertyId], _
["SelectionIsSelectionRequired",$UIA_SelectionIsSelectionRequiredPropertyId], _
["GridRowCount",$UIA_GridRowCountPropertyId], _
["GridColumnCount",$UIA_GridColumnCountPropertyId], _
["GridItemRow",$UIA_GridItemRowPropertyId], _
["GridItemColumn",$UIA_GridItemColumnPropertyId], _
["GridItemRowSpan",$UIA_GridItemRowSpanPropertyId], _
["GridItemColumnSpan",$UIA_GridItemColumnSpanPropertyId], _
["GridItemContainingGrid",$UIA_GridItemContainingGridPropertyId], _
["DockDockPosition",$UIA_DockDockPositionPropertyId], _
["ExpandCollapseExpandCollapseState",$UIA_ExpandCollapseExpandCollapseStatePropertyId], _
["MultipleViewCurrentView",$UIA_MultipleViewCurrentViewPropertyId], _
["MultipleViewSupportedViews",$UIA_MultipleViewSupportedViewsPropertyId], _
["WindowCanMaximize",$UIA_WindowCanMaximizePropertyId], _
["WindowCanMinimize",$UIA_WindowCanMinimizePropertyId], _
["WindowWindowVisualState",$UIA_WindowWindowVisualStatePropertyId], _
["WindowWindowInteractionState",$UIA_WindowWindowInteractionStatePropertyId], _
["WindowIsModal",$UIA_WindowIsModalPropertyId], _
["WindowIsTopmost",$UIA_WindowIsTopmostPropertyId], _
["SelectionItemIsSelected",$UIA_SelectionItemIsSelectedPropertyId], _
["SelectionItemSelectionContainer",$UIA_SelectionItemSelectionContainerPropertyId], _
["TableRowHeaders",$UIA_TableRowHeadersPropertyId], _
["TableColumnHeaders",$UIA_TableColumnHeadersPropertyId], _
["TableRowOrColumnMajor",$UIA_TableRowOrColumnMajorPropertyId], _
["TableItemRowHeaderItems",$UIA_TableItemRowHeaderItemsPropertyId], _
["TableItemColumnHeaderItems",$UIA_TableItemColumnHeaderItemsPropertyId], _
["ToggleToggleState",$UIA_ToggleToggleStatePropertyId], _
["TransformCanMove",$UIA_TransformCanMovePropertyId], _
["TransformCanResize",$UIA_TransformCanResizePropertyId], _
["TransformCanRotate",$UIA_TransformCanRotatePropertyId], _
["IsLegacyIAccessiblePatternAvailable",$UIA_IsLegacyIAccessiblePatternAvailablePropertyId], _
["LegacyIAccessibleChildId",$UIA_LegacyIAccessibleChildIdPropertyId], _
["LegacyIAccessibleName",$UIA_LegacyIAccessibleNamePropertyId], _
["LegacyIAccessibleValue",$UIA_LegacyIAccessibleValuePropertyId], _
["LegacyIAccessibleDescription",$UIA_LegacyIAccessibleDescriptionPropertyId], _
["LegacyIAccessibleRole",$UIA_LegacyIAccessibleRolePropertyId], _
["LegacyIAccessibleState",$UIA_LegacyIAccessibleStatePropertyId], _
["LegacyIAccessibleHelp",$UIA_LegacyIAccessibleHelpPropertyId], _
["LegacyIAccessibleKeyboardShortcut",$UIA_LegacyIAccessibleKeyboardShortcutPropertyId], _
["LegacyIAccessibleSelection",$UIA_LegacyIAccessibleSelectionPropertyId], _
["LegacyIAccessibleDefaultAction",$UIA_LegacyIAccessibleDefaultActionPropertyId], _
["AriaRole",$UIA_AriaRolePropertyId], _
["AriaProperties",$UIA_AriaPropertiesPropertyId], _
["IsDataValidForForm",$UIA_IsDataValidForFormPropertyId], _
["ControllerFor",$UIA_ControllerForPropertyId], _
["DescribedBy",$UIA_DescribedByPropertyId], _
["FlowsTo",$UIA_FlowsToPropertyId], _
["ProviderDescription",$UIA_ProviderDescriptionPropertyId], _
["IsItemContainerPatternAvailable",$UIA_IsItemContainerPatternAvailablePropertyId], _
["IsVirtualizedItemPatternAvailable",$UIA_IsVirtualizedItemPatternAvailablePropertyId], _
["IsSynchronizedInputPatternAvailable",$UIA_IsSynchronizedInputPatternAvailablePropertyId] _
]


local $UIA_ControlArray[41][3]= [ _
["UIA_AppBarControlTypeId",50040 ,"Identifies the AppBar control type. Supported starting with Windows 8.1."], _
["UIA_ButtonControlTypeId",50000 ,"Identifies the Button control type."], _
["UIA_CalendarControlTypeId",50001 ,"Identifies the Calendar control type."], _
["UIA_CheckBoxControlTypeId",50002 ,"Identifies the CheckBox control type."], _
["UIA_ComboBoxControlTypeId",50003 ,"Identifies the ComboBox control type."], _
["UIA_CustomControlTypeId",50025 ,"Identifies the Custom control type. For more information, see Custom Properties, Events, and Control Patterns."], _
["UIA_DataGridControlTypeId",50028 ,"Identifies the DataGrid control type."], _
["UIA_DataItemControlTypeId",50029 ,"Identifies the DataItem control type."], _
["UIA_DocumentControlTypeId",50030 ,"Identifies the Document control type."], _
["UIA_EditControlTypeId",50004 ,"Identifies the Edit control type."], _
["UIA_GroupControlTypeId",50026 ,"Identifies the Group control type."], _
["UIA_HeaderControlTypeId",50034 ,"Identifies the Header control type."], _
["UIA_HeaderItemControlTypeId",50035 ,"Identifies the HeaderItem control type."], _
["UIA_HyperlinkControlTypeId",50005 ,"Identifies the Hyperlink control type."], _
["UIA_ImageControlTypeId",50006 ,"Identifies the Image control type."], _
["UIA_ListControlTypeId",50008 ,"Identifies the List control type."], _
["UIA_ListItemControlTypeId",50007 ,"Identifies the ListItem control type."], _
["UIA_MenuBarControlTypeId",50010 ,"Identifies the MenuBar control type."], _
["UIA_MenuControlTypeId",50009 ,"Identifies the Menu control type."], _
["UIA_MenuItemControlTypeId",50011 ,"Identifies the MenuItem control type."], _
["UIA_PaneControlTypeId",50033 ,"Identifies the Pane control type."], _
["UIA_ProgressBarControlTypeId",50012 ,"Identifies the ProgressBar control type."], _
["UIA_RadioButtonControlTypeId",50013 ,"Identifies the RadioButton control type."], _
["UIA_ScrollBarControlTypeId",50014 ,"Identifies the ScrollBar control type."], _
["UIA_SemanticZoomControlTypeId",50039 ,"Identifies the SemanticZoom control type. Supported starting with Windows 8."], _
["UIA_SeparatorControlTypeId",50038 ,"Identifies the Separator control type."], _
["UIA_SliderControlTypeId",50015 ,"Identifies the Slider control type."], _
["UIA_SpinnerControlTypeId",50016 ,"Identifies the Spinner control type."], _
["UIA_SplitButtonControlTypeId",50031 ,"Identifies the SplitButton control type."], _
["UIA_StatusBarControlTypeId",50017 ,"Identifies the StatusBar control type."], _
["UIA_TabControlTypeId",50018 ,"Identifies the Tab control type."], _
["UIA_TabItemControlTypeId",50019 ,"Identifies the TabItem control type."], _
["UIA_TableControlTypeId",50036 ,"Identifies the Table control type."], _
["UIA_TextControlTypeId",50020 ,"Identifies the Text control type."], _
["UIA_ThumbControlTypeId",50027 ,"Identifies the Thumb control type."], _
["UIA_TitleBarControlTypeId",50037 ,"Identifies the TitleBar control type."], _
["UIA_ToolBarControlTypeId",50021 ,"Identifies the ToolBar control type."], _
["UIA_ToolTipControlTypeId",50022 ,"Identifies the ToolTip control type."], _
["UIA_TreeControlTypeId",50023 ,"Identifies the Tree control type."], _
["UIA_TreeItemControlTypeId",50024 ,"Identifies the TreeItem control type."], _
["UIA_WindowControlTypeId",50032 ,"Identifies the Window control type."] _
]

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getControlName
; Description ...: Transforms the number of a control to a readable name
; Syntax.........: _UIA_getControlName($controlID)
; Parameters ....: $controlID
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
func _UIA_getControlName($controlID)
	Local $i
	seterror(1,0,0)
	for $i=0 to ubound($UIA_ControlArray)-1
		if ($UIA_ControlArray[$i][1]=$controlID) then
			return $UIA_ControlArray[$i][0]
		endIf
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getControlId
; Description ...: Transforms the name of a controltype to an id
; Syntax.........: _UIA_getControlId($controlName)
; Parameters ....: $controlName
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
func _UIA_getControlID($controlName)
	local $tName, $i
	$tName=stringupper($controlName)
	if stringleft($tname,3)<>"UIA" Then
		$tName="UIA_" & $tName & "CONTROLTYPEID"
	endif
	seterror(1,0,0)
	for $i=0 to ubound($UIA_ControlArray)-1
		if (stringupper($UIA_ControlArray[$i][0])=$tName) then
			return $UIA_ControlArray[$i][1]
		endIf
	Next
EndFunc

; ## Internal use just to find the location of the property name in the property array##
func _UIA_getPropertyIndex($propName)
	Local $i
	for $i=0 to ubound($UIA_propertiesSupportedArray,1)-1
		if stringlower($UIA_propertiesSupportedArray[$i][0])=stringlower($propName) Then
			return $i
		endif
	next
	_UIA_Debug("[FATAL] : property you use is having invalid name:=" & $propname &@CRLF,$UIA_Log_Wrapper)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_setVar($varName, $varValue)
; Description ...: Just sets a variable to a certain value
; Syntax.........: _UIA_setVar("Global.UIADebug",True)
; Parameters ....: $varName  - A name for a variable
;				   $varValue - A value to assign to the variable
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
;~ Just set a value in a dictionary object

func _UIA_setVar($varName, $varValue)
	if $UIA_VARS.exists($varName) Then
		$UIA_Vars($varName)=$varvalue
	Else
		$UIA_Vars.add($varName, $VarValue)
	endif
EndFunc

Func _UIA_setVarsFromArray(ByRef $_array, $prefix="")
	Local $iRow
    If Not IsArray($_array) Then Return 0
    For $iRow = 0 To ubound($_array,1)-1
        _UIA_setVar($prefix & $_array[$iRow][0], $_array[$iRow][1])
    Next
EndFunc

Func _UIA_launchScript(ByRef $_scriptArray)
	Local $iLine
    If Not IsArray($_scriptArray) Then
		Return SetError(1,0,0)
	EndIf

    For $iLine = 0 To ubound($_scriptArray,1)-1
		if ($_scriptArray[$iLine][0]<>"") Then
			_UIA_action($_scriptArray[$iLine][0],$_scriptArray[$iLine][1],$_scriptArray[$iLine][2],$_scriptArray[$iLine][3],$_scriptArray[$iLine][4],$_scriptArray[$iLine][5])
		endif
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getVar($varName)
; Description ...: Just returns a value as set before
; Syntax.........: _UIA_getVar("Global.UIADebug")
; Parameters ....: $varName  - A name for a variable
; Return values .: Success      - Returns the value of the variable
;                  Failure		- Returns "*** ERROR ***" and sets error to 1
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
;~ Just get a value in a dictionary object
func _UIA_getVar($varName)
	if $UIA_VARS.exists($varName) Then
		return $UIA_Vars($varName)
	Else
		SetError(1) ;~ Not defined in repository
		return "*** ERROR ***" & $varname
	endif
EndFunc

;~ ** TODO: Not needed??? **
Func _UIA_getVars2Array($prefix="")
	Local $keys, $it, $i
	_UIA_debug($uia_vars.count-1 & @CRLF, $UIA_Log_Wrapper)
	$keys=$uia_vars.keys
	$it=$uia_vars.items
	for $i=0 to $uia_vars.count-1
		_UIA_debug("[" & $keys[$i] & "]:=[" & $it[$i] & "]"  & @CRLF, $UIA_Log_Wrapper)
	Next

EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getPropertyValue($obj, $id)
; Description ...: Just return a single property or if its an array string them together
; Syntax.........: _UIA_getPropertyValue
; Parameters ....: $obj - An UI Element object
;				   $id - A reference to the property id
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
;~ Just return a single property or if its an array string them together
func _UIA_getPropertyValue($obj, $id)
	local $tval
	local $tStr
	Local $i

	if not isobj($obj) Then
		seterror(1,0,0)
		return "** NO PROPERTYVALUE DUE TO NONEXISTING OBJECT **"
	EndIf

	$obj.GetCurrentPropertyValue($Id,$tVal)
  	$tStr="" & $tVal
	if isarray($tVal) Then
		$tStr=""
		for $i=0 to ubound($tval)-1
			$tStr=$tStr & $tVal[$i]
			if $i <> ubound($tVal)-1 Then
				$tStr=$tStr & ";"
			endif
		Next
		return $tStr
	endIf
	return $tStr
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getAllPropertyValues($UIA_oUIElement)
; Description ...: Just return all properties as a string
; Syntax.........: _UIA_getPropertyValues
; Parameters ....: $obj - An UI Element object
;				   $id - A reference to the property id
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
; ~ Just get all available properties for desktop/should work on all IUIAutomationElements depending on ControlTypePropertyID they work yes/no
; ~ Just make it a very long string name:= value pairs
func _UIA_getAllPropertyValues($UIA_oUIElement)
	local $tStr, $tVal, $tSeparator
	$tStr=""
	$tSeparator = @crLF  ; To make sure its not a value you normally will get back for values
;~ 	changed in v0.42
	for $i=0 to ubound($UIA_propertiesSupportedArray)-1
		$tVal=_UIA_getPropertyValue($UIA_oUIElement, $UIA_propertiesSupportedArray[$i][1])
		if $tVal <> "" then
		$tStr=$tStr & "UIA_" & $UIA_propertiesSupportedArray[$i][0] & ":= <" & $tVal & ">" & $tSeparator
		EndIf
	next
		#cs
	$tStr=$tStr & "UIA_AcceleratorKeyPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_AcceleratorKeyPropertyId) & $tSeparator ; Shortcut key for the element's default action.
	$tStr=$tStr & "UIA_AccessKeyPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_AccessKeyPropertyId) & $tSeparator ; Keys used to move focus to a control.
	$tStr=$tStr & "UIA_AriaPropertiesPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_AriaPropertiesPropertyId) & $tSeparator ; A collection of Accessible Rich Internet Application (ARIA) properties, each consisting of a name/value pair delimited by ‘-’ and ‘ ; ’ (for example, ("checked=true ; disabled=false").
	$tStr=$tStr & "UIA_AriaRolePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_AriaRolePropertyId) & $tSeparator ; ARIA role information.
	$tStr=$tStr & "UIA_AutomationIdPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_AutomationIdPropertyId) & $tSeparator ; UI Automation identifier.
	$tStr=$tStr & "UIA_BoundingRectanglePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_BoundingRectanglePropertyId) & $tSeparator ; Coordinates of the rectangle that completely encloses the element.
	$tStr=$tStr & "UIA_ClassNamePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ClassNamePropertyId) & $tSeparator ; Class name of the element as assigned by the control developer.
	$tStr=$tStr & "UIA_ClickablePointPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ClickablePointPropertyId) & $tSeparator ; Screen coordinates of any clickable point within the control.
	$tStr=$tStr & "UIA_ControllerForPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ControllerForPropertyId) & $tSeparator ; Array of elements controlled by the automation element that supports this property.
	$tStr=$tStr & "UIA_ControlTypePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ControlTypePropertyId) & $tSeparator ; Control Type of the element.
	$tStr=$tStr & "UIA_CulturePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_CulturePropertyId) & $tSeparator ; Locale identifier of the element.
	$tStr=$tStr & "UIA_DescribedByPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_DescribedByPropertyId) & $tSeparator ; Array of elements that provide more information about the element.
	$tStr=$tStr & "UIA_DockDockPositionPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_DockDockPositionPropertyId) & $tSeparator ; Docking position.
	$tStr=$tStr & "UIA_ExpandCollapseExpandCollapseStatePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ExpandCollapseExpandCollapseStatePropertyId) & $tSeparator ; The expand/collapse state.
	$tStr=$tStr & "UIA_FlowsToPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_FlowsToPropertyId) & $tSeparator ; Array of elements that suggest the reading order after the corresponding element.
	$tStr=$tStr & "UIA_FrameworkIdPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_FrameworkIdPropertyId) & $tSeparator ; Underlying UI framework that the element is part of.
	$tStr=$tStr & "UIA_GridColumnCountPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridColumnCountPropertyId) & $tSeparator ; Number of columns.
	$tStr=$tStr & "UIA_GridItemColumnPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridItemColumnPropertyId) & $tSeparator ; Column the item is in.
	$tStr=$tStr & "UIA_GridItemColumnSpanPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridItemColumnSpanPropertyId) & $tSeparator ; number of columns that the item spans.
	$tStr=$tStr & "UIA_GridItemContainingGridPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridItemContainingGridPropertyId) & $tSeparator ; UI Automation provider that implements IGridProvider and represents the container of the cell or item.
	$tStr=$tStr & "UIA_GridItemRowPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridItemRowPropertyId) & $tSeparator ; Row the item is in.
	$tStr=$tStr & "UIA_GridItemRowSpanPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridItemRowSpanPropertyId) & $tSeparator ; Number of rows that the item spzns.
	$tStr=$tStr & "UIA_GridRowCountPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_GridRowCountPropertyId) & $tSeparator ; Number of rows.
	$tStr=$tStr & "UIA_HasKeyboardFocusPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_HasKeyboardFocusPropertyId) & $tSeparator ; Whether the element has the keyboard focus.
	$tStr=$tStr & "UIA_HelpTextPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_HelpTextPropertyId) & $tSeparator ; Additional information about how to use the element.
	$tStr=$tStr & "UIA_IsContentElementPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsContentElementPropertyId) & $tSeparator ; Whether the element appears in the content view of the automation element tree.
	$tStr=$tStr & "UIA_IsControlElementPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsControlElementPropertyId) & $tSeparator ; Whether the element appears in the control view of the automation element tree.
	$tStr=$tStr & "UIA_IsDataValidForFormPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsDataValidForFormPropertyId) & $tSeparator ; Whether the data in a form is valid.
	$tStr=$tStr & "UIA_IsDockPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsDockPatternAvailablePropertyId) & $tSeparator ; Whether the Dock control pattern is available on the element.
	$tStr=$tStr & "UIA_IsEnabledPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsEnabledPropertyId) & $tSeparator ; Whether the control is enabled.
	$tStr=$tStr & "UIA_IsExpandCollapsePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsExpandCollapsePatternAvailablePropertyId) & $tSeparator ; Whether the ExpandCollapse control pattern is available on the element.
	$tStr=$tStr & "UIA_IsGridItemPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsGridItemPatternAvailablePropertyId) & $tSeparator ; Whether the GridItem control pattern is available on the element.
	$tStr=$tStr & "UIA_IsGridPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsGridPatternAvailablePropertyId) & $tSeparator ; Whether the Grid control pattern is available on the element.
	$tStr=$tStr & "UIA_IsInvokePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsInvokePatternAvailablePropertyId) & $tSeparator ; Whether the Invoke control pattern is available on the element.
	$tStr=$tStr & "UIA_IsItemContainerPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsItemContainerPatternAvailablePropertyId) & $tSeparator ; Whether the ItemContainer control pattern is available on the element.
	$tStr=$tStr & "UIA_IsKeyboardFocusablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsKeyboardFocusablePropertyId) & $tSeparator ; Whether the element can accept the keyboard focus.
	$tStr=$tStr & "UIA_IsLegacyIAccessiblePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsLegacyIAccessiblePatternAvailablePropertyId) & $tSeparator ; Whether the LegacyIAccessible control pattern is available on the control.
	$tStr=$tStr & "UIA_IsMultipleViewPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsMultipleViewPatternAvailablePropertyId) & $tSeparator ; Whether the pattern is available on the control.
	$tStr=$tStr & "UIA_IsOffscreenPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsOffscreenPropertyId) & $tSeparator ; Whether the element is scrolled or collapsed out of view.
	$tStr=$tStr & "UIA_IsPasswordPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsPasswordPropertyId) & $tSeparator ; Whether the element contains protected content or a password.
	$tStr=$tStr & "UIA_IsRangeValuePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsRangeValuePatternAvailablePropertyId) & $tSeparator ; Whether the RangeValue pattern is available on the control.
	$tStr=$tStr & "UIA_IsRequiredForFormPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsRequiredForFormPropertyId) & $tSeparator ; Whether the element is a required field on a form.
	$tStr=$tStr & "UIA_IsScrollItemPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsScrollItemPatternAvailablePropertyId) & $tSeparator ; Whether the ScrollItem control pattern is available on the element.
	$tStr=$tStr & "UIA_IsScrollPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsScrollPatternAvailablePropertyId) & $tSeparator ; Whether the Scroll control pattern is available on the element.
	$tStr=$tStr & "UIA_IsSelectionItemPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsSelectionItemPatternAvailablePropertyId) & $tSeparator ; Whether the SelectionItem control pattern is available on the element.
	$tStr=$tStr & "UIA_IsSelectionPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsSelectionPatternAvailablePropertyId) & $tSeparator ; Whether the pattern is available on the element.
	$tStr=$tStr & "UIA_IsSynchronizedInputPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsSynchronizedInputPatternAvailablePropertyId) & $tSeparator ; Whether the SynchronizedInput control pattern is available on the element.
	$tStr=$tStr & "UIA_IsTableItemPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsTableItemPatternAvailablePropertyId) & $tSeparator ; Whether the TableItem control pattern is available on the element.
	$tStr=$tStr & "UIA_IsTablePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsTablePatternAvailablePropertyId) & $tSeparator ; Whether the Table conntrol pattern is available on the element.
	$tStr=$tStr & "UIA_IsTextPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsTextPatternAvailablePropertyId) & $tSeparator ; Whether the Text control pattern is available on the element.
	$tStr=$tStr & "UIA_IsTogglePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsTogglePatternAvailablePropertyId) & $tSeparator ; Whether the Toggle control pattern is available on the element.
	$tStr=$tStr & "UIA_IsTransformPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsTransformPatternAvailablePropertyId) & $tSeparator ; Whether the Transform control pattern is available on the element.
	$tStr=$tStr & "UIA_IsValuePatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsValuePatternAvailablePropertyId) & $tSeparator ; Whether the Value control pattern is available on the element.
	$tStr=$tStr & "UIA_IsVirtualizedItemPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsVirtualizedItemPatternAvailablePropertyId) & $tSeparator ; Whether the VirtualizedItem control pattern is available on the element.
	$tStr=$tStr & "UIA_IsWindowPatternAvailablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_IsWindowPatternAvailablePropertyId) & $tSeparator ; Whether the Window control pattern is available on the element.
	$tStr=$tStr & "UIA_ItemStatusPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ItemStatusPropertyId) & $tSeparator ; Control-specific status.
	$tStr=$tStr & "UIA_ItemTypePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ItemTypePropertyId) & $tSeparator ; Description of the item type, such as "Document File" or "Folder".
	$tStr=$tStr & "UIA_LabeledByPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LabeledByPropertyId) & $tSeparator ; Element that contains the text label for this element.
	$tStr=$tStr & "UIA_LegacyIAccessibleChildIdPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleChildIdPropertyId) & $tSeparator ; MSAA child ID of the element.
	$tStr=$tStr & "UIA_LegacyIAccessibleDefaultActionPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleDefaultActionPropertyId) & $tSeparator ; MSAA default action.
	$tStr=$tStr & "UIA_LegacyIAccessibleDescriptionPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleDescriptionPropertyId) & $tSeparator ; MSAA description.
	$tStr=$tStr & "UIA_LegacyIAccessibleHelpPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleHelpPropertyId) & $tSeparator ; MSAA help string.
	$tStr=$tStr & "UIA_LegacyIAccessibleKeyboardShortcutPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleKeyboardShortcutPropertyId) & $tSeparator ; MSAA shortcut key.
	$tStr=$tStr & "UIA_LegacyIAccessibleNamePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleNamePropertyId) & $tSeparator ; MSAA name.
	$tStr=$tStr & "UIA_LegacyIAccessibleRolePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleRolePropertyId) & $tSeparator ; MSAA role.
	$tStr=$tStr & "UIA_LegacyIAccessibleSelectionPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleSelectionPropertyId) & $tSeparator ; MSAA selection.
	$tStr=$tStr & "UIA_LegacyIAccessibleStatePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleStatePropertyId) & $tSeparator ; MSAA state.
	$tStr=$tStr & "UIA_LegacyIAccessibleValuePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LegacyIAccessibleValuePropertyId) & $tSeparator ; MSAA value.
	$tStr=$tStr & "UIA_LocalizedControlTypePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_LocalizedControlTypePropertyId) & $tSeparator ; Localized string describing the control type of element.
	$tStr=$tStr & "UIA_MultipleViewCurrentViewPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_MultipleViewCurrentViewPropertyId) & $tSeparator ; Current view state of the control.
	$tStr=$tStr & "UIA_MultipleViewSupportedViewsPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_MultipleViewSupportedViewsPropertyId) & $tSeparator ; Supported control-specific views.
	$tStr=$tStr & "UIA_NamePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_NamePropertyId) & $tSeparator ; Name of the control.
	$tStr=$tStr & "UIA_NativeWindowHandlePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_NativeWindowHandlePropertyId) & $tSeparator ; Underlying HWND of the element, if one exists.
	$tStr=$tStr & "UIA_OrientationPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_OrientationPropertyId) & $tSeparator ; Orientation of the element.
	$tStr=$tStr & "UIA_ProcessIdPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ProcessIdPropertyId) & $tSeparator ; Identifier of the process that the element resides in.
	$tStr=$tStr & "UIA_ProviderDescriptionPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ProviderDescriptionPropertyId) & $tSeparator ; Description of the UI Automation provider.
	$tStr=$tStr & "UIA_RangeValueIsReadOnlyPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RangeValueIsReadOnlyPropertyId) & $tSeparator ; Whether the value is read-only.
	$tStr=$tStr & "UIA_RangeValueLargeChangePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RangeValueLargeChangePropertyId) & $tSeparator ; Amount by which the value is adjusted by input such as PgDn.
	$tStr=$tStr & "UIA_RangeValueMaximumPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RangeValueMaximumPropertyId) & $tSeparator ; Maximum value in the range.
	$tStr=$tStr & "UIA_RangeValueMinimumPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RangeValueMinimumPropertyId) & $tSeparator ; Minimum value in the range.
	$tStr=$tStr & "UIA_RangeValueSmallChangePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RangeValueSmallChangePropertyId) & $tSeparator ; Amount by which the value is adjusted by input such as an arrow key.
	$tStr=$tStr & "UIA_RangeValueValuePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RangeValueValuePropertyId) & $tSeparator ; Current value.
	$tStr=$tStr & "UIA_RuntimeIdPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_RuntimeIdPropertyId) & $tSeparator ; Run time identifier of the element.
	$tStr=$tStr & "UIA_ScrollHorizontallyScrollablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ScrollHorizontallyScrollablePropertyId) & $tSeparator ; Whether the control can be scrolled horizontally.
	$tStr=$tStr & "UIA_ScrollHorizontalScrollPercentPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ScrollHorizontalScrollPercentPropertyId) & $tSeparator ; How far the element is currently scrolled.
	$tStr=$tStr & "UIA_ScrollHorizontalViewSizePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ScrollHorizontalViewSizePropertyId) & $tSeparator ; The viewable width of the control.
	$tStr=$tStr & "UIA_ScrollVerticallyScrollablePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ScrollVerticallyScrollablePropertyId) & $tSeparator ; Whether the control can be scrolled vertically.
	$tStr=$tStr & "UIA_ScrollVerticalScrollPercentPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ScrollVerticalScrollPercentPropertyId) & $tSeparator ; How far the element is currently scrolled.
	$tStr=$tStr & "UIA_ScrollVerticalViewSizePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ScrollVerticalViewSizePropertyId) & $tSeparator ; The viewable height of the control.
	$tStr=$tStr & "UIA_SelectionCanSelectMultiplePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_SelectionCanSelectMultiplePropertyId) & $tSeparator ; Whether multiple items can be in the selection.
	$tStr=$tStr & "UIA_SelectionIsSelectionRequiredPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_SelectionIsSelectionRequiredPropertyId) & $tSeparator ; Whether at least one item must be in the selection at all times.
	$tStr=$tStr & "UIA_SelectionselectionPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_SelectionselectionPropertyId) & $tSeparator ; The items in the selection.
	$tStr=$tStr & "UIA_SelectionItemIsSelectedPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_SelectionItemIsSelectedPropertyId) & $tSeparator ; Whether the item can be selected.
	$tStr=$tStr & "UIA_SelectionItemSelectionContainerPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_SelectionItemSelectionContainerPropertyId) & $tSeparator ; The control that contains the item.
	$tStr=$tStr & "UIA_TableColumnHeadersPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TableColumnHeadersPropertyId) & $tSeparator ; Collection of column header providers.
	$tStr=$tStr & "UIA_TableItemColumnHeaderItemsPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TableItemColumnHeaderItemsPropertyId) & $tSeparator ; Column headers.
	$tStr=$tStr & "UIA_TableRowHeadersPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TableRowHeadersPropertyId) & $tSeparator ; Collection of row header providers.
	$tStr=$tStr & "UIA_TableRowOrColumnMajorPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TableRowOrColumnMajorPropertyId) & $tSeparator ; Whether the table is primarily organized by row or column.
	$tStr=$tStr & "UIA_TableItemRowHeaderItemsPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TableItemRowHeaderItemsPropertyId) & $tSeparator ; Row headers.
	$tStr=$tStr & "UIA_ToggleToggleStatePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ToggleToggleStatePropertyId) & $tSeparator ; The toggle state of the control.
	$tStr=$tStr & "UIA_TransformCanMovePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TransformCanMovePropertyId) & $tSeparator ; Whether the element can be moved.
	$tStr=$tStr & "UIA_TransformCanResizePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TransformCanResizePropertyId) & $tSeparator ; Whether the element can be resized.
	$tStr=$tStr & "UIA_TransformCanRotatePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_TransformCanRotatePropertyId) & $tSeparator ; Whether the element can be rotated.
	$tStr=$tStr & "UIA_ValueIsReadOnlyPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ValueIsReadOnlyPropertyId) & $tSeparator ; Whether the value is read-only.
	$tStr=$tStr & "UIA_ValueValuePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_ValueValuePropertyId) & $tSeparator ; Current value.
	$tStr=$tStr & "UIA_WindowCanMaximizePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_WindowCanMaximizePropertyId) & $tSeparator ; Whether the window can be maximized.
	$tStr=$tStr & "UIA_WindowCanMinimizePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_WindowCanMinimizePropertyId) & $tSeparator ; Whether the window can be minimized.
	$tStr=$tStr & "UIA_WindowIsModalPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_WindowIsModalPropertyId) & $tSeparator ; Whether the window is modal.
	$tStr=$tStr & "UIA_WindowIsTopmostPropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_WindowIsTopmostPropertyId) & $tSeparator ; Whether the window is on top of other windows.
	$tStr=$tStr & "UIA_WindowWindowInteractionStatePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_WindowWindowInteractionStatePropertyId) & $tSeparator ; Whether the window can receive input.
	$tStr=$tStr & "UIA_WindowWindowVisualStatePropertyId :=" &_UIA_getPropertyValue($UIA_oUIElement, $UIA_WindowWindowVisualStatePropertyId) & $tSeparator ; Whether the window is maximized, minimized, or restored (normal).
#ce
return $tStr
endFunc


## Internal USE ##
; Draw rectangle on screen.
Func _UIA_DrawRect($tLeft, $tRight, $tTop, $tBottom, $color = 0xFF, $PenWidth = 4)
    Local $hDC, $hPen, $obj_orig, $x1, $x2, $y1, $y2
    $x1 = $tLeft
    $x2 = $tRight
    $y1 = $tTop
    $y2 = $tBottom
    $hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
    $hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color)
    $obj_orig = _WinAPI_SelectObject($hDC, $hPen)

    _WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1) ; horizontal to right
    _WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2) ; vertical down on right
    _WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2) ; horizontal to left right
    _WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1) ; vertical up on left

    ; clear resources
    _WinAPI_SelectObject($hDC, $obj_orig)
    _WinAPI_DeleteObject($hPen)
    _WinAPI_ReleaseDC(0, $hDC)
EndFunc   ;==>_DrawtRect

;~ Small helper function to get an object out of a treeSearch based on the name / title
;~ Not possible to match on multiple properties then findall should be used
func _UIA_getFirstObjectOfElement($obj,$str,$treeScope)
	local $tResult, $tVal, $iTry, $t
	local $pCondition, $oCondition
 	local $propertyID
	Local $i

;~ 	Split a description into multiple subdescription/properties
	$tResult=stringsplit($str,":=",1)

;~ If there is only 1 value without a property assume the default property name to use for identification
	if $tResult[0]=1 Then
		$propertyID=$UIA_NamePropertyId
		$tVal=$str
	Else
		for $i=0 to ubound($UIA_propertiesSupportedArray)-1
			if $UIA_propertiesSupportedArray[$i][0]=stringlower($tResult[1]) Then
				_UIA_Debug("matched: " & $UIA_propertiesSupportedArray[$i][0] & $UIA_propertiesSupportedArray[$i][1] & @crlf, $UIA_Log_Wrapper)
				$propertyID=$UIA_propertiesSupportedArray[$i][1]

;~ 				Some properties expect a number (otherwise system will break)
				switch $UIA_propertiesSupportedArray[$i][1]
					case $UIA_ControlTypePropertyId
						$tVal=number($tResult[2])
					case else
						$tVal=$tResult[2]
				endswitch
			endif
		next
	EndIf

	_UIA_Debug("Matching: " & $PropertyId & " for " & $tVal & @CRLF, $UIA_Log_Wrapper)

;~ Tricky when numeric values to pass
	$UIA_oUIAutomation.createPropertyCondition($PropertyId, $tVal, $pCondition)

	$oCondition=ObjCreateInterface($pCondition,$sIID_IUIAutomationPropertyCondition,$dtagIUIAutomationPropertyCondition)

	$iTry=1
	$UIA_oUIElement=""
	while not isobj($UIA_oUIElement) and $iTry<= $UIA_tryMax
		$t=$obj.Findfirst($TreeScope,$oCondition,$UIA_pUIElement)
		$UIA_oUIElement=ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		if not isobj($UIA_oUIElement) Then
			sleep(100)
			$iTry=$iTry+1
		endif
	WEnd

	if isobj($UIA_oUIElement) Then
;~ 		_UIA_Debug("UIA found the element" & @CRLF, $UIA_Log_Wrapper)
		if _UIA_getVar("Global.Highlight")= true Then
			_UIA_Highlight($UIA_oUIElement)
		EndIf

		return $UIA_oUIElement
	Else
;~ 		_UIA_Debug("UIA failing ** NOT ** found the element" & @CRLF, $UIA_Log_Wrapper)
		if _UIA_getVar("Global.Debug")= true Then
			_UIA_DumpThemAll($obj, $treescope)
		EndIf

		return ""
	endif

EndFunc


;~ Find it by using a findall array of the UIA framework
func _UIA_getObjectByFindAll($obj, $str, $treescope,$p1=0)
	dim $pCondition, $pTrueCondition
	dim $pElements, $iLength

	local $tResult
	local $propertyID
	local $tPos
	local $relPos
	local $relIndex=0
	local $tMatch
	local $tStr
	local $properties2Match[1][2]   ;~ All properties of the expression to match in a normalized form
	local $parentHandle   ;~ Handle to get the parent of the element available

	Local $allProperties, $propertyCount, $propName, $propValue, $bAdd, $index, $i, $arrSize, $j
	Local $objParent, $propertyActualValue, $propertyVal, $oAutomationElementArray, $matchCount

;~ 	Split it first into multiple sections representing each property
	$allProperties=stringsplit($str,";",1)

;~ Redefine the array to have all properties that are used to identify
	$propertyCount=$allProperties[0]
	redim $properties2Match[$propertyCount][2]
	_UIA_Debug("_UIA_getObjectByFindAll " &  $str & $propertyCount & @crlf, $UIA_Log_Wrapper)
	for $i=1 to $allProperties[0]
		_UIA_Debug("  _UIA_getObjectByFindAll " &  $allProperties[$i] & @crlf, $UIA_Log_Wrapper)
		$tResult=stringsplit($allProperties[$i],":=",1)

		;~ Handle syntax without a property to have default name property:  Ok as Name:=Ok
		if $tResult[0]=1 Then
			$tResult[1]=stringstripws($tresult[1],3)
			$propName=$UIA_NamePropertyId
			$propValue=$allProperties[$i]

			$properties2Match[$i-1][0]=$propName
			$properties2Match[$i-1][1]=$propValue
		Else
			$tResult[1]=stringstripws($tresult[1],3)
			$tResult[2]=stringstripws($tresult[2],3)
			$propName=$tResult[1]
			$propValue=$tResult[2]

;~ Exclucde the properties with a specific meaning
			$bAdd=True
			if $propName="indexrelative" Then
				$relPos=$propValue
				$bAdd=False
			EndIf
			if ($propName="index") or ($propName="instance") Then
				$relIndex=$propValue
				$bAdd=False
			EndIf

			if $bAdd=true Then
				$index=_UIA_getPropertyIndex($propName)

;~ 				Some properties expect a number (otherwise system will break)
;~ TODO: Before not working due to beta of AutoIT
;~ _UIA_Debug("value before " & $propValue)
				switch $UIA_propertiesSupportedArray[$index][1]
					case $UIA_ControlTypePropertyId
						$propValue=number(_UIA_getControlID($propValue))
				endswitch
;~ _UIA_Debug("value after" & $propValue)

				_UIA_Debug("  adding index " &  $index & " name:" & $propname & " value:" & $propvalue & @crlf, $UIA_Log_Wrapper)

;~ Add it to the normalized array
				$properties2Match[$i-1][0]= $UIA_propertiesSupportedArray[$index][1]  ;~ store the propertyID (numeric value)
				$properties2Match[$i-1][1]= $propvalue

			endif
		endif
	Next

;~ Now walk thru the tree
;~ 	_UIA_Debug("_UIA_getObjectByFindAll walk thru the tree" &  $allProperties[0], $UIA_Log_Wrapper )
;~     $UIA_oUIAutomation.CreateTrueCondition($pTrueCondition)
;~     $oCondition=ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition,$dtagIUIAutomationCondition)
	$obj.FindAll($treescope, $UIA_oTRUECondition, $pElements)
    $oAutomationElementArray = ObjCreateInterFace($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	$matchCount=0

;~ 	If there are no childs found then there is nothing to search
	if isobj($oAutomationElementArray) Then
		;~ All elements to inspect are in this array
		$oAutomationElementArray.Length($iLength)
	Else
		_UIA_Debug("***** FATAL:???? _UIA_getObjectByFindAll no childarray found *****" &  @crlf, $UIA_Log_Wrapper)
		$iLength=0
	EndIf

;~ 		_UIA_Debug("_UIA_getObjectByFindAll walk thru the tree" &  $iLength )
    For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
        $UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

;~ 		_UIA_Debug("searching the Name is: <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
;~ 			& "Class   := <" & _UIA_getPropertyValue($UIA_oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
;~ 			& "controltype:= <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB & @CRLF, $UIA_Log_Wrapper)

;~		Walk thru all properties in the properties2Match array to match
;~		Normally not a big array just 1 - 5 elements frequently just 1
		$arrSize=ubound($properties2Match,1)-1
		for $j=0 to $arrSize
			$propertyID=$properties2Match[$j][0]
			$propertyVal=$properties2Match[$j][1]
            $propertyActualValue=""
;~ 			_UIA_Debug("   1    j:" & $j & "[" & $propertyID & "][" & $propertyVal & "][" & $propertyActualValue & "]" & $tMatch & @CRLF, $UIA_Log_Wrapper)

;~ 			Some properties expect a number (otherwise system will break)
;~ TODO: Replace button with the actual id

			switch $propertyId
				case $UIA_ControlTypePropertyId
					$propertyVal=number($propertyVal)
			endswitch

			$propertyActualValue=_UIA_getPropertyValue($UIA_oUIElement,$PropertyId)

;~ 			TODO: Tricky logic on numbers and strings
;~ 			if $propertyVal=0 Then
;~ 				if $propertyVal=$propertyActualValue Then
;~ 					$tMatch=1
;~ 				Else
;~ 					$tMatch=0
;~ 					_UIA_Debug("j:" & $j & "[" & $propertyID & "][" & $propertyVal & "][" & $propertyActualValue & "]" & $tMatch & @CRLF, $UIA_Log_Wrapper)
;~ 					ExitLoop
;~ 				EndIf
;~ 			Else
			$tMatch=stringregexp($propertyActualValue, $propertyVal,0)

;~ 			Filter so not to much logging happens
			if $propertyActualValue<>"" then
				_UIA_Debug("        j:" & $j & "[" & $propertyID & "][" & $propertyVal & "][" & $propertyActualValue & "]" & $tMatch & @CRLF, $UIA_Log_Wrapper)
			EndIf

			if $tMatch=0 Then
;~ 				Special situation could be that its non matching on regex but exact match is there
				if $propertyVal<>$propertyActualValue then ExitLoop
				$tMatch=1
			EndIf

		Next

		if $tMatch=1 Then
				if $relPos <> 0 Then
;~ 					_UIA_Debug("Relative position used", $UIA_Log_Wrapper)
					$oAutomationElementArray.GetElement($i+$relPos, $UIA_pUIElement)
					$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
				EndIf
				if $relIndex <> 0 Then
					$matchCount=$matchCount+1
					if $matchCount <> $relIndex then $tMatch=0
					_UIA_Debug("Index position used " & $relindex & $matchcount, $UIA_Log_Wrapper)
				EndIf

				if $tMatch=1 Then
;~ 					_UIA_Debug( " Found the Name is: <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
;~ 				    & "Class   := <" & _UIA_getPropertyValue($UIA_oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
;~ 					& "controltype:= <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB  _
;~ 					& " (" &  hex(_UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId)) &  ")" & @TAB & @CRLF, $UIA_Log_Wrapper)

					if _UIA_getVar("Global.Highlight")= true Then
						_UIA_Highlight($UIA_oUIElement)
					EndIf

					;~ Have the parent also available in the RTI
					;~ $UIA_oTW, $UIA_pTW
					$UIA_oTW.getparentelement($UIA_oUIElement,$parentHandle)
					$objParent=objcreateinterface($parentHandle,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
					If IsObj($objParent) = 0 Then
						_UIA_Debug("No parent " & @CRLF, $UIA_Log_Wrapper)
					Else
					_UIA_DEBUG("Storing parent for found object in RTI as RTI.PARENT" & @CRLF, $UIA_Log_Wrapper)
						_UIA_setVar("RTI.PARENT", $objParent)
;~ 						$UIA_oParent=$objParent
					EndIf

;~ 					Add element to runtime information object reference
					if isstring($p1) Then
						_UIA_DEBUG("Storing in RTI as RTI." & $p1 & @CRLF, $UIA_Log_Wrapper)
						_UIA_setVar("RTI." & stringupper($p1), $UIA_oUIElement)
					EndIf
					return $UIA_oUIElement
				endif
		EndIf
	Next

	if _UIA_getVar("Global.Debug")= true Then
		_UIA_DumpThemAll($obj, $treescope)
	EndIf
	return ""
endfunc

func _UIA_getPattern($obj,$patternID)
local $patternArray[21][3]=[ _
	[$UIA_ValuePatternId    , 			$sIID_IUIAutomationValuePattern    , 		$dtagIUIAutomationValuePattern], _
	[$UIA_InvokePatternId   , 			$sIID_IUIAutomationInvokePattern   , 		$dtagIUIAutomationInvokePattern], _
	[$UIA_SelectionPatternId, 			$sIID_IUIAutomationSelectionPattern, 		$dtagIUIAutomationSelectionPattern], _
    [$UIA_LegacyIAccessiblePatternId, 	$sIID_IUIAutomationLegacyIAccessiblePattern,$dtagIUIAutomationLegacyIAccessiblePattern], _
    [$UIA_SelectionItemPatternId, 		$sIID_IUIAutomationSelectionItemPattern,	$dtagIUIAutomationSelectionItemPattern], _
    [$UIA_RangeValuePatternId, 			$sIID_IUIAutomationRangeValuePattern,		$dtagIUIAutomationRangeValuePattern], _
	[$UIA_ScrollPatternId, 				$sIID_IUIAutomationScrollPattern,			$dtagIUIAutomationScrollPattern], _
	[$UIA_GridPatternId, 				$sIID_IUIAutomationGridPattern,				$dtagIUIAutomationGridPattern], _
	[$UIA_GridItemPatternId, 			$sIID_IUIAutomationGridItemPattern,			$dtagIUIAutomationGridItemPattern], _
	[$UIA_MultipleViewPatternId, 		$sIID_IUIAutomationMultipleViewPattern,		$dtagIUIAutomationMultipleViewPattern], _
	[$UIA_WindowPatternId, 				$sIID_IUIAutomationWindowPattern,			$dtagIUIAutomationWindowPattern], _
	[$UIA_DockPatternId, 				$sIID_IUIAutomationDockPattern,				$dtagIUIAutomationDockPattern], _
	[$UIA_TablePatternId, 				$sIID_IUIAutomationTablePattern,			$dtagIUIAutomationTablePattern], _
	[$UIA_TextPatternId, 				$sIID_IUIAutomationTextPattern,				$dtagIUIAutomationTextPattern], _
	[$UIA_TogglePatternId, 				$sIID_IUIAutomationTogglePattern,			$dtagIUIAutomationTogglePattern], _
	[$UIA_TransformPatternId, 			$sIID_IUIAutomationTransformPattern,		$dtagIUIAutomationTransformPattern], _
	[$UIA_ScrollItemPatternId, 			$sIID_IUIAutomationScrollItemPattern,		$dtagIUIAutomationScrollItemPattern], _
	[$UIA_ItemContainerPatternId, 		$sIID_IUIAutomationItemContainerPattern,	$dtagIUIAutomationItemContainerPattern], _
	[$UIA_VirtualizedItemPatternId, 	$sIID_IUIAutomationVirtualizedItemPattern,	$dtagIUIAutomationVirtualizedItemPattern], _
	[$UIA_SynchronizedInputPatternId, 	$sIID_IUIAutomationSynchronizedInputPattern,$dtagIUIAutomationSynchronizedInputPattern], _
	[$UIA_ExpandCollapsePatternId, 		$sIID_IUIAutomationExpandCollapsePattern, 	$dtagIUIAutomationExpandCollapsePattern] _
		]

    local $pPattern, $oPattern
    local $sIID_Pattern
	local $sdTagPattern
	local $i

	for $i=0 to ubound($patternArray)-1
		if $patternArray[$i][0]=$patternId Then
;~ 			consolewrite("Pattern identified " & @crlf)
			$sIID_Pattern=$patternArray[$i][1]
			$sdTagPattern=$patternArray[$i][2]
		EndIf
	next
;~ 	consolewrite($patternid & $sIID_Pattern & $sdTagPattern & @CRLF)

	$obj.getCurrentPattern($PatternId, $pPattern)
	$oPattern=objCreateInterface($pPattern, $sIID_Pattern, $sdtagPattern)
	if isobj($oPattern) Then
;~ 		consolewrite("UIA found the pattern" & @CRLF)
		return $oPattern
	Else
		_UIA_Debug("UIA WARNING ** NOT ** found the pattern" & @CRLF, $UIA_Log_Wrapper)
	endif
EndFunc

func _UIA_getTaskBar()
	return _UIA_getFirstObjectOfElement($UIA_oDesktop,"classname:=Shell_TrayWnd",$TreeScope_Children)
EndFunc

;~ func _UIA_action($obj, $strAction, $p1=0, $p2=0, $p3=0)
func _UIA_action($obj_or_string, $strAction, $p1=0, $p2=0, $p3=0, $p4=0)
	Local $obj
	local $tPattern
	local $x, $y
;~ 	local $objElement
    Local $controlType
	local $oElement
	local $parentHandle
	local $oTW
	Local $tPhysical, $startElement, $oStart, $pos, $tStr, $xx, $hwnd

;~ If we are giving a description then try to make an object first by looking from repository
;~ Otherwise assume an advanced description we should search under one of the previously referenced elements at runtime

	if isobj($obj_or_string) Then
		$oElement=$obj_or_string
		$obj=$obj_or_string
	else
		_UIA_DEBUG("_UIA_action: Finding object " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
		$tPhysical=_UIA_getVar($obj_or_string)
;~ If not found in repository assume its a physical description
		if @error=1 Then
;~ 		_UIA_DEBUG("Finding object (bypassing repository) with physical description " & $tPhysical & @CRLF, $UIA_Log_Wrapper)
			$tPhysical=$obj_or_string
		EndIf

;~ 		TODO: If its a physical description the searching should start at one of the last active elements or parent of that last active element
;~ 		else
;~ 			We found a reference try to make it an object
;~ 		_UIA_DEBUG("Finding object with physical description " & $tPhysical & @CRLF, $UIA_Log_Wrapper)

;~ TODO For the moment the context has to be set in mainscript
;~ Future tought on this to find it more based on the context of the previous actions (more complicated algorithm)

;~ if its a mainwindow reference find it under the desktop
		if stringinstr($obj_or_string,".mainwindow") Then

			$startElement="Desktop"
			$oStart=$UIA_oDesktop
;~ 			_UIA_DEBUG("Finding object under " & $startElement & @CRLF, $UIA_Log_Wrapper)
			_UIA_DEBUG("find 1 " & $tPhysical & @CRLF, $UIA_Log_Wrapper)

			$oElement=_UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_subtree,$obj_or_string)

;~ 			And store quick references to mainwindow
			_UIA_setVar("RTI.MAINWINDOW",$oElement)
;~ 			_UIA_setVar("RTI." & stringupper($obj_or_string),$oElement)
;~ 			$UIA_oMainWindow=$oElement

		else


;~ 			$xx=_UIA_getVars2Array()

			$oStart=_UIA_getVar("RTI.SEARCHCONTEXT")
			$startElement="RTI.SEARCHCONTEXT"
			if not isobj($oStart) Then
;~ 				$pos=stringinstr($obj_or_string,".",0,-1)
;~ TODO: Not sure if both backwards dot and forward dot to investigate
				$pos=stringinstr($obj_or_string,".")
				_UIA_DEBUG("_UIA_action: No RTI.SEARCHCONTEXT used for " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
				if $pos>0 Then
					$tStr="RTI." & stringleft(stringupper($obj_or_string),$pos-1) & ".MAINWINDOW"
				Else
					$tStr="RTI.MAINWINDOW"
				EndIf
				_UIA_DEBUG("_UIA_action: try for " & $tStr & @CRLF, $UIA_Log_Wrapper)


				$oStart=_UIA_getVar($tStr)
				$startElement=$tStr
;~ 					$oStart=$UIA_oMainWindow
				if not isobj($oStart) Then
					_UIA_DEBUG("_UIA_action: No RTI.MAINWINDOW used for " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
					$xx=_UIA_getVars2Array()

					$oStart=_UIA_getVar("RTI.PARENT")
					$startElement="RTI.PARENT"
;~ 					$oStart=$UIA_oParent     ;~TODO: Somehow not retrievable from the DD $UIA_Vars object
					if not isobj($oStart) Then
						_UIA_DEBUG("_UIA_action: No RTI.PARENT used for " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
						$startElement="Desktop"
						$oStart=$UIA_oDesktop
					endif
				endif

;~ 				$oStart=_UIA_getVar("RTI.MAINWINDOW")
;~ 				$startElement="RTI.MAINWINDOW"
;~ 				$oStart=$UIA_oMainWindow
			endif
			_UIA_DEBUG("_UIA_action: Finding object " & $obj_or_string &  " under " & $startElement & @CRLF, $UIA_Log_Wrapper)
			;~ 			_UIA_getVars2Array()
			_UIA_DEBUG("find 2 " & $tPhysical & @CRLF, $UIA_Log_Wrapper)
			$oElement=_UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_subtree)
		endif
	endif

;~ And just continue the action by setting the $obj value to an UIA element
	if isobj($oElement) Then
		$obj=$oElement
		_UIA_setVar("RTI.LASTELEMENT",$obj)
	Else
		_UIA_DEBUG("Not an object failing action " & $strAction & " on " & $obj_or_string & @CRLF , $UIA_Log_Wrapper)
		seterror(1)
		Return
	endif

	_UIA_setVar("RTI.ACTIONCOUNT",_UIA_getVar("RTI.ACTIONCOUNT")+1)
	_UIA_DEBUG("Action " & _UIA_getVar("RTI.ACTIONCOUNT") & " " & $strAction & " on " & $obj_or_string & @CRLF , $UIA_Log_Wrapper)

	$controlType=_UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId)

;~ Execute the given action
	switch $strAction
;~ 		All mouse click actions
		case "leftclick", "left", "click", "leftdoubleclick", "leftdouble", "doubleclick", _
			 "rightclick", "right",        "rightdoubleclick", "rightdouble", _
             "middleclick", "middle",      "middledoubleclick", "middledouble"

			local $clickAction="left"  ;~ Default action is the left mouse button
			local $clickCount=1      ;~ Default action is the single click

			if stringinstr($strAction, "right") then $clickAction="right"
			if stringinstr($strAction, "middle") then $clickAction="middle"
			if stringinstr($strAction, "double") then $clickCount=2

			;~ consolewrite("So you saw it selected but did not click" & @crlf)
			;~ still you can click as you now know the dimensions where to click
			dim $t
			$t=stringsplit(_UIA_getPropertyValue($obj, $UIA_BoundingRectanglePropertyId),";")
;~ 			consolewrite($t[1] & ";" & $t[2] & ";" & $t[3] & ";" & $t[4] & @crlf)
;~ 			_winapi_mouse_event($MOUSEEVENTF_ABSOLUTE + $MOUSEEVENTF_MOVE,$t[1],$t[2])
			$x=int($t[1]+($t[3]/2))
			$y=int($t[2]+$t[4]/2)

;~ Split into 2 actions for screenrecording purposes intentionally a slowdown
;~ Arguable that this delay should be configurable or removed on synchronizing differently in future
;~ 			First try to set the focus to make sure right window is active

;~ 	_UIA_DEBUG("Title is: <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_NamePropertyId) &  ">" & $clickcount & ":" & $clickaction & ":" & $x & ":" & $y & ":" & @CRLF, $UIA_Log_Wrapper)

;~ TODO: Check if setting focus should happen as it influences behavior before clicking
;~ Tricky when using setfocus on menuitems, seems to do the click already
;~ 			$obj.setfocus()

;~ 			Mouse should move to keep it as userlike as possible
			mousemove($x,$y,0)
;~ 			mouseclick($clickAction,Default,Default,$clickCount,0)
			mouseclick($clickAction,$x,$y,$clickCount,0)
			sleep($UIA_DefaultWaitTime)

		case "setvalue"

;~ TODO: Find out how to set title for a window with UIA commands
;~ winsettitle(hwnd(_UIA_getVar("RTI.calculator.HWND")),"","nicer")
;~ winsettitle("Naamloos - Kladblok","","This works better")

			if ($controltype=$UIA_WindowControlTypeId) then
				$hwnd=0
				$obj.CurrentNativeWindowHandle($hwnd)
				consolewrite($hwnd)
				winsettitle(hwnd($hwnd),"",$p1)
			Else
				$obj.setfocus()
				sleep($UIA_DefaultWaitTime)
				$tPattern=_UIA_getPattern($obj,$UIA_ValuePatternId)
				$tPattern.setvalue($p1)
			EndIf

		case "setvalue using keys"
			$obj.setfocus()
			send("^a")
			send($p1)
			sleep($UIA_DefaultWaitTime)
		case "sendkeys", "enterstring"
			$obj.setfocus()
			send($p1)
		case "invoke"
			$obj.setfocus()
			sleep($UIA_DefaultWaitTime)
			$tPattern=_UIA_getPattern($obj,$UIA_InvokePatternId)
			$tPattern.invoke()
		case "focus","setfocus"
			$obj.setfocus()
			sleep($UIA_DefaultWaitTime)
		case "searchcontext","context"
			_UIA_setVar("RTI.SEARCHCONTEXT",$obj)
		case "highlight"
			_UIA_Highlight($obj)
		case Else
	endswitch
EndFunc

;~ Just dumps all information under a certain object
func _UIA_DumpThemAll($oElementStart, $TreeScope)
;~  Get result with findall function alternative could be the treewalker
    Local $pCondition, $pTrueCondition, $oCondition, $oAutomationElementArray
	Local $pElements, $iLength, $i

	_UIA_Debug("***** Dumping tree *****" & @CRLF)

;~     $UIA_oUIAutomation.CreateTrueCondition($pTrueCondition)
;~     $oCondition=ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition,$dtagIUIAutomationCondition)

	$oElementStart.FindAll($TreeScope, $UIA_oTRUECondition, $pElements)

    $oAutomationElementArray = ObjCreateInterFace($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

;~ 	If there are no childs found then there is nothing to search
	if isobj($oAutomationElementArray) Then
		;~ All elements to inspect are in this array
		$oAutomationElementArray.Length($iLength)
	Else
		_UIA_Debug("***** FATAL:???? _UIA_DumpThemAll no childarray found *****" &  @crlf, $UIA_Log_Wrapper)
		$iLength=0
	EndIf

    For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
        $UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
        _UIA_Debug( "Title is: <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
				    & "Class   := <" & _UIA_getPropertyValue($UIA_oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
					& "controltype:= " _
					& "<" &  _UIA_getControlName(_UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId)) &  ">" & @TAB  _
					& ",<" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB  _
					& ", (" &  hex(_UIA_getPropertyValue($UIA_oUIElement,$UIA_ControlTypePropertyId)) &  ")" & @TAB _
					& ", acceleratorkey:= <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_AcceleratorKeyPropertyId) &  ">" & @TAB _
					& ", automationid:= <" &  _UIA_getPropertyValue($UIA_oUIElement,$UIA_AutomationIdPropertyId) &  ">" & @TAB & @CRLF)

	Next

EndFunc
;~ For the moment just dump to the consolewindow
;~ TODO: Differentiate between debug, error, warning, informational
func _UIA_Debug($s, $logLevel=0)
	local $logstr

	$logStr=@year & @mon & @MDay & "-" & @hour & @min & @sec & @MSEC
	$logstr=$logstr & " " & $s

	if _UIA_getVar("global.debug.file")=true Then
		filewrite("log.txt",$logStr)
	Else
		if _UIA_getVar("global.debug")=true Then
			consolewrite($logStr)
		EndIf
	endif
EndFunc

func _UIA_StartSUT($SUT_VAR)
	local $fullName=_UIA_getVar( $SUT_VAR & ".Fullname")
	local $processName=_UIA_getVar($SUT_VAR & ".processname")
	local $app2Start=$fullName & " " & _UIA_getVar($SUT_VAR & ".Parameters")
	local $workingDir= _UIA_getVar($SUT_VAR & ".Workingdir")
	local $windowState=_UIA_getVar($SUT_VAR & ".Windowstate")
    local $result, $result2   ; Holds the process id's
	Local $oSUT

;~ 	_UIA_Debug("SUT 1 Starting : " & $fullName & @CRLF, $UIA_Log_Wrapper)
	if fileexists($fullName) Then
;~ 		_UIA_Debug("SUT 2 Starting : " & $fullName & @CRLF, $UIA_Log_Wrapper)
;~ 		Only start new instance when not found
		$result2=processexists($processName)
		if $result2=0 Then
			_UIA_Debug("Starting : " & $app2Start & " from " & $workingDir, $UIA_Log_Wrapper)
			$result=run($app2Start,$workingDir, $windowState )
			$result2=ProcessWait($processName,60)
;~ 			sleep(500) ;~ Just to give the system some time to show everything
		EndIf

;~ Wait for the window to be there
		$oSUT=_UIA_getObjectByFindAll($UIA_oDesktop, "processid:=" & $result2, $treescope_children)
		if not isobj($oSUT) Then
			_UIA_Debug("No window found in SUT : " & $app2Start & " from " & $workingDir & @CRLF, $UIA_Log_Wrapper)
		Else
		;~ Add it to the Runtime Type Information
			_UIA_setVar("RTI." & $SUT_VAR & ".PID", $result2)
			_UIA_setVar("RTI." & $SUT_VAR & ".HWND", hex(_UIA_getPropertyValue($oSUT, $UIA_NativeWindowHandlePropertyId)))
;~ 			_UIA_DumpThemAll($oSUT,$treescope_subtree)
		EndIf
	Else
		_UIA_Debug("No clue where to find the system under test (SUT) on your system, please start manually:" & @CRLF, $UIA_Log_Wrapper )
		_UIA_Debug($app2Start & @CRLF, $UIA_Log_Wrapper)
	EndIf
EndFunc

func _UIA_Highlight($oElement)
	Local $t
	$t=stringsplit(_UIA_getPropertyValue($oElement, $UIA_BoundingRectanglePropertyId),";")
	_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
EndFunc

func _UIA_NiceString($str)
	local $tStr=$str
	$tstr=stringreplace($tStr," ","")
	$tstr=stringreplace($tStr,"\","")
	return $tStr
EndFunc


;~ ***** Experimental catching the events that are flowing around *****
;~ ;===============================================================================
;~ #interface "IUnknown"
;~ Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"
;~ ; Definition
;~ Global $dtagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
;~ 		"AddRef dword();" & _
;~ 		"Release dword();"
;~ ; List
;~ Global $ltagIUnknown = "QueryInterface;" & _
;~ 		"AddRef;" & _
;~ 		"Release;"
;~ ;===============================================================================
;~ ;===============================================================================
;~ #interface "IDispatch"
;~ Global Const $sIID_IDispatch = "{00020400-0000-0000-C000-000000000046}"
;~ ; Definition
;~ Global $dtagIDispatch = $dtagIUnknown & _
;~ 		"GetTypeInfoCount hresult(dword*);" & _
;~ 		"GetTypeInfo hresult(dword;dword;ptr*);" & _
;~ 		"GetIDsOfNames hresult(ptr;ptr;dword;dword;ptr);" & _
;~ 		"Invoke hresult(dword;ptr;dword;word;ptr;ptr;ptr;ptr);"
;~ ; List
;~ Global $ltagIDispatch = $ltagIUnknown & _
;~ 		"GetTypeInfoCount;" & _
;~ 		"GetTypeInfo;" & _
;~ 		"GetIDsOfNames;" & _
;~ 		"Invoke;"
;~ ;===============================================================================
;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name...........: UIA_ObjectFromTag($obj, $id)
;~ ; Description ...: Get an object from a DTAG
;~ ; Syntax.........:
;~ ; Parameters ....:
;~ ;
;~ ; Return values .: Success      - Returns 1
;~ ;                  Failure		- Returns 0 and sets @error on errors:
;~ ;                  |@error=1     - UI automation failed
;~ ;                  |@error=2     - UI automation desktop failed
;~ ; Author ........: TRANCEXX
;~ ; Modified.......:
;~ ; Remarks .......: None
;~ ; Related .......:
;~ ; Link ..........:
;~ ; Example .......: Yes
;~ ; ===============================================================================================================================
;~ http://www.autoitscript.com/forum/topic/153859-objevent-possible-with-addfocuschangedeventhandler/
;~ Func UIA_ObjectFromTag($sFunctionPrefix, $tagInterface, ByRef $tInterface)
;~     Local Const $tagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
;~             "AddRef dword();" & _
;~             "Release dword();"
;~     ; Adding IUnknown methods
;~     $tagInterface = $tagIUnknown & $tagInterface
;~     Local Const $PTR_SIZE = DllStructGetSize(DllStructCreate("ptr"))
;~     ; Below line really simple even though it looks super complex. It's just written weird to fit one line, not to steal your eyes
;~     Local $aMethods = StringSplit(StringReplace(StringReplace(StringReplace(StringReplace(StringTrimRight(StringReplace(StringRegExpReplace($tagInterface, "\h*(\w+)\h*(\w+\*?)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF), 1), "object", "idispatch"), "variant*", "ptr"), "hresult", "long"), "bstr", "ptr"), @LF, 3)
;~     Local $iUbound = UBound($aMethods)
;~     Local $sMethod, $aSplit, $sNamePart, $aTagPart, $sTagPart, $sRet, $sParams
;~     ; Allocation. Read http://msdn.microsoft.com/en-us/library/ms810466.aspx to see why like this (object + methods):
;~     $tInterface = DllStructCreate("ptr[" & $iUbound + 1 & "]")
;~     If @error Then Return SetError(1, 0, 0)
;~     For $i = 0 To $iUbound - 1
;~         $aSplit = StringSplit($aMethods[$i], "|", 2)
;~         If UBound($aSplit) <> 2 Then ReDim $aSplit[2]
;~         $sNamePart = $aSplit[0]
;~         $sTagPart = $aSplit[1]
;~         $sMethod = $sFunctionPrefix & $sNamePart
;~         $aTagPart = StringSplit($sTagPart, ";", 2)
;~         $sRet = $aTagPart[0]
;~         $sParams = StringReplace($sTagPart, $sRet, "", 1)
;~         $sParams = "ptr" & $sParams
;~         DllStructSetData($tInterface, 1, DllCallbackGetPtr(DllCallbackRegister($sMethod, $sRet, $sParams)), $i + 2) ; Freeing is left to AutoIt.
;~     Next
;~     DllStructSetData($tInterface, 1, DllStructGetPtr($tInterface) + $PTR_SIZE) ; Interface method pointers are actually pointer size away
;~     Return ObjCreateInterface(DllStructGetPtr($tInterface), "", $tagInterface, False) ; and first pointer is object pointer that's wrapped
;~ EndFunc