; Fail the test without providing any conditions
Func AssertFail($message = "", $iLine = @ScriptLineNumber)
	ConsoleWriteError("Assert failed on line " & $iLine & ". Test failed.")
	If $message <> "" Then
		ConsoleWriteError(" Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc

; Ends the test with the result that it is inconclusive without providing any conditions
Func AssertInconclusive($message = "", $iLine = @ScriptLineNumber)
	ConsoleWriteError("Assert failed on line " & $iLine & ". Test inconclusive.")
	If $message <> "" Then
		ConsoleWriteError(" Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc

; Checks if $expected and $actual are equal (case sensitive for strings)
Func AssertAreEqual($expected, $actual, $message = "", $iLine = @ScriptLineNumber)
	If Not ($expected == $actual) Then
		_AssertFail($expected, $actual, $message, $iLine)
	EndIf
EndFunc

; Checks if $expected and $actual are not equal (case sensitive for strings)
Func AssertNotEqual($notExpected, $actual, $message = "", $iLine = @ScriptLineNumber)
	If $notExpected == $actual Then
		ConsoleWriteError("Assert failed on line " & $iLine & ". Not expected <" & $notExpected & "> Actual <" & $actual & ">")
		If $message <> "" Then
			ConsoleWriteError(" Msg: " & $message)
		EndIf
		ConsoleWriteError(@CRLF)
		Exit 1
	EndIf
EndFunc

; Checks if $var is of $type type by checking VarGetType($var) = $type
Func AssertIsType($var, $type, $message = "", $iLine = @ScriptLineNumber)
	$actualType = VarGetType($var)
	If Not ($actualType = $type) Then
		_AssertFail($type, $actualType, $message, $iLine)
	EndIf
EndFunc

; Asserts whether $actual is true otherwise fails the test
Func AssertIsTrue($actual, $message = "", $iLine = @ScriptLineNumber)
	If Not $actual Then
		_AssertFail(True, $actual, $message, $iLine)
	EndIf
EndFunc

; Asserts whether $actual is false otherwise fails the test
Func AssertIsFalse($actual, $message = "", $iLine = @ScriptLineNumber)
	If $actual Then
		_AssertFail(False, $actual, $message, $iLine)
	EndIf
EndFunc

; Internal
Func _AssertFail($expected, $actual, $message, $iLine)
	ConsoleWriteError("Assert failed on line " & $iLine & ". Expected <" & $expected & "> Actual <" & $actual & ">")
	If $message <> "" Then
		ConsoleWriteError(" Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc