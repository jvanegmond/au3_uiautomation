Local Const $testFolder = @ScriptDir & "\tests"

Local $numTestsPassed = 0, $numTestsFailed = 0

Local $tStart = TimerInit()
Local $hSearch = FileFindFirstFile($testFolder & "\*.au3")
While 1
	$file = FileFindNextFile($hSearch)
	If @error Then ExitLoop

	$iPID = Run(@AutoItExe & " /AutoIt3ExecuteScript """ & $testFolder & "\" & $file & """", $testFolder, @SW_HIDE, 8)

	ProcessWaitClose($iPID)
	$exitCode = @extended

	$result = StdoutRead($iPID)

	If $exitCode Then
		ConsoleWrite($file & " failed: " & @CRLF & "  " & StringStripWS($result, 1 + 2) & @CRLF & @CRLF)
		$numTestsFailed += 1
	Else
		$numTestsPassed += 1
	EndIf
WEnd

$secondsElapsed = Round(TimerDiff($tStart)/1000)
ConsoleWrite("Test run completed in " & Round(TimerDiff($tStart)/1000) & " " & ($secondsElapsed <> 1 ? "seconds" : "second") & "." & @CRLF)
ConsoleWrite("Tests passed: " & $numTestsPassed & ". Tests failed: " & $numTestsFailed & "." & @CRLF)

If $numTestsFailed > 0 Then
	Exit 1
EndIf