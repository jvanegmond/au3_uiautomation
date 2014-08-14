Func Assert($expected, $actual, $message = "")
	$equal = ($expected == $actual)

	If $equal Then
		Return
	EndIf

	ConsoleWriteError("Assert failed. Expected <" & $expected & "> Actual <" & $actual & ">")
	If $message <> "" Then
		ConsoleWriteError("Msg: " & $message)
	EndIf
	ConsoleWriteError(@CRLF)
	Exit 1
EndFunc

Func AssertIsType($var, $type, $message = "")
	Assert(VarGetType($var), $type, $message)
EndFunc

Func AssertRegisterCleanup($func)

EndFunc