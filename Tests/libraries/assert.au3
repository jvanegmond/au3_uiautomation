; Fail the test without providing any conditions
Func AssertFail($message = "")
	ConsoleWriteError("Assert failed. Test failed.")
	If $message <> "" Then
		ConsoleWriteError(" Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc

; Ends the test with the result that it is inconclusive without providing any conditions
Func AssertInconclusive($message = "")
	ConsoleWriteError("Assert failed. Test inconclusive.")
	If $message <> "" Then
		ConsoleWriteError(" Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc

; Checks if $expected and $actual are equal (case sensitive for strings)
Func AssertAreEqual($expected, $actual, $message = "")
	If Not ($expected == $actual) Then
		_AssertFail($expected, $actual, $message)
	EndIf
EndFunc

; Checks if $expected and $actual are not equal (case sensitive for strings)
Func AssertNotEqual($notExpected, $actual, $message = "")
	If $notExpected == $actual Then
		ConsoleWriteError("Assert failed. Not expected <" & $notExpected & "> Actual <" & $actual & ">")
		If $message <> "" Then
			ConsoleWriteError(" Msg: " & $message)
		EndIf
		ConsoleWriteError(@CRLF)
		Exit 1
	EndIf
EndFunc

; Checks if $var is of $type type by checking VarGetType($var) = $type
Func AssertIsType($var, $type, $message = "")
	$actualType = VarGetType($var)
	If Not ($actualType = $type) Then
		_AssertFail($type, $actualType, $message)
	EndIf
EndFunc

; Asserts whether $actual is true otherwise fails the test
Func AssertIsTrue($actual, $message = "")
	If Not $actual Then
		_AssertFail(True, $actual, $message)
	EndIf
EndFunc

; Asserts whether $actual is false otherwise fails the test
Func AssertIsFalse($actual, $message = "")
	If $actual Then
		_AssertFail(False, $actual, $message)
	EndIf
EndFunc

; Internal
Func _AssertFail($expected, $actual, $message = "")
	ConsoleWriteError("Assert failed. Expected <" & $expected & "> Actual <" & $actual & ">")
	If $message <> "" Then
		ConsoleWriteError(" Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc