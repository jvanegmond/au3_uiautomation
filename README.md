au3_uiautomation
================
UI Automation is a somewhat neglected part of AutoIt. The goal for this project is simple: Get the UI Automation library in tip-top shape for inclusion in the AutoIt core libraries, as well as making it a simpler to use this library without understanding UIA core concepts.

Until this is production ready, please use http://www.autoitscript.com/forum/topic/153520-iuiautomation-ms-framework-automate-chrome-ff-ie/

This is the approach taken for this project:

- Start with the latest release of UIAutomation
- Move functions to wherever appropriate and delete functions with prejudice
- Create additional functions which match AutoIt native Control* and Win* functions with UIA implementations
- As a final step, upgrade spy to work in a more similar way to AutoIt's spy

The library is now split in these two smaller libraries:

**UIAWrappers.au3**: 

Thin wrapper over UIAutomation. To work with this file you require knowledge of UI Automation concepts. An example of a function in this file might be \_\_UIA_CreatePattern which takes a UIA object and a pattern id and returns the full pattern ready to be used (or sets @error).

**UIAutomation.au3**: 

New thick wrapper over UIAWrappers.au3. You require little to no knowledge of UI Automation concepts and only familiarity with AutoIt Control* and Win* functions is recommended (but not required). An example of a function in this file might be \_UIA_ControlSetText which takes a window handle, a control id (with exact AutoIt syntax) and the text that you want to set. This function then deals with getting a reference to the window via UIA, the control and the value pattern required to set the text.

Additionally, a small unit testing library is being developed as part of this project called assert.au3. You may find it in the Tests folder.
