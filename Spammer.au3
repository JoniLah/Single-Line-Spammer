#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; MAIN GUI
#Region ### START Koda GUI section ###
$foSpammer = GUICreate("Spammer", 594, 224, 205, 128)
$grInterface = GUICtrlCreateGroup("Interface", 16, 8, 281, 201)
$inMsg = GUICtrlCreateInput("Enter a message", 152, 32, 129, 21, -1, BitOR($WS_EX_CLIENTEDGE,$WS_EX_STATICEDGE))
$inMsgNo = GUICtrlCreateInput("50", 152, 64, 129, 21, BitOR($ES_AUTOHSCROLL,$ES_NUMBER), BitOR($WS_EX_CLIENTEDGE,$WS_EX_STATICEDGE))
$inMsgDelay = GUICtrlCreateInput("1000", 152, 96, 129, 21, BitOR($ES_AUTOHSCROLL,$ES_NUMBER), BitOR($WS_EX_CLIENTEDGE,$WS_EX_STATICEDGE))
$btStart = GUICtrlCreateButton("Start", 40, 160, 241, 41, $WS_GROUP)
GUICtrlSetFont(-1, 12, 400, 0, "Cambria")
$laMsg = GUICtrlCreateLabel("Message: ", 40, 32, 53, 17)
$laMsgNo = GUICtrlCreateLabel("Amount of messages: ", 40, 64, 108, 17)
$laMsgDelay = GUICtrlCreateLabel("Delay (ms):", 40, 96, 56, 17)
$laMsgCountdown = GUICtrlCreateLabel("Countdown (s):", 40, 128, 75, 17)
$inMsgCountdown = GUICtrlCreateInput("5", 152, 128, 129, 21, BitOR($ES_AUTOHSCROLL,$ES_NUMBER), BitOR($WS_EX_CLIENTEDGE,$WS_EX_STATICEDGE))
GUICtrlCreateGroup("", -99, -99, 1, 1)
$gOptions = GUICtrlCreateGroup("Options", 304, 8, 273, 201)
$cbMsgNo = GUICtrlCreateCheckbox("Message number", 320, 32, 105, 17)
GUICtrlSetTip(-1, "Displays the messages number after the message")
$gEnter = GUICtrlCreateGroup("Enter", 320, 56, 121, 73)
$rEnBefore = GUICtrlCreateRadio("Before", 352, 88, 49, 17)
$rEnAfter = GUICtrlCreateRadio("After", 352, 104, 49, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$cbEnter = GUICtrlCreateCheckbox("Press enter", 336, 72, 73, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, "Presses enter before or after the message")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$gClick = GUICtrlCreateGroup("Click", 448, 56, 113, 73)
$cbClick = GUICtrlCreateCheckbox("Click", 464, 72, 41, 17)
GUICtrlSetTip(-1, "Clicks left mouse button before or after the message")
$rClBefore = GUICtrlCreateRadio("Before", 480, 88, 65, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$rClAfter = GUICtrlCreateRadio("After", 480, 104, 57, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$gRandomize = GUICtrlCreateGroup("Randomize", 320, 128, 241, 73)
$cbRandomized = GUICtrlCreateCheckbox("Randomized message", 328, 144, 121, 17)
$cbUpperCase = GUICtrlCreateCheckbox("Uppercase", 344, 160, 73, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$cbLowerCase = GUICtrlCreateCheckbox("Lowercase", 344, 176, 81, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$cbNumbers = GUICtrlCreateCheckbox("Numbers", 432, 176, 65, 17)
$cbSymbols = GUICtrlCreateCheckbox("Symbols", 496, 160, 57, 17)
$cbLetters = GUICtrlCreateCheckbox("Letters", 432, 160, 49, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$cbMsgLength = GUICtrlCreateCheckbox("Message length", 448, 32, 97, 17)
GUICtrlSetTip(-1, "Displays the messages length after the message")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $SpamAmount
Global $SpamNumber = 0
Global $SpamSpeed
Global $Message
Global $Paused
Global $LengthOfMessage
Global $Alphabet = False

While 1

	; Checks whether the "Press enter" is checked or not, and disable/enable the options below (and avoid flickering with basic GUICtrlSetState())
	If GUICtrlRead($cbEnter) == 1 Then
		If BitAND(GUICtrlGetState($rEnBefore),$GUI_DISABLE) Then GUICtrlSetState($rEnBefore,$GUI_ENABLE)
		If BitAND(GUICtrlGetState($rEnAfter),$GUI_DISABLE) Then GUICtrlSetState($rEnAfter,$GUI_ENABLE)
	Else
		If BitAND(GUICtrlGetState($rEnBefore),$GUI_ENABLE) Then GUICtrlSetState($rEnBefore,$GUI_DISABLE)
		If BitAND(GUICtrlGetState($rEnAfter),$GUI_ENABLE) Then GUICtrlSetState($rEnAfter,$GUI_DISABLE)
	EndIf

	; Checks whether the "Click" is checked or not, and disable/enable the options below (and avoid flickering with basic GUICtrlSetState())
	If GUICtrlRead($cbClick) == 1 Then
		If BitAND(GUICtrlGetState($rClBefore),$GUI_DISABLE) Then GUICtrlSetState($rClBefore,$GUI_ENABLE)
		If BitAND(GUICtrlGetState($rClAfter),$GUI_DISABLE) Then GUICtrlSetState($rClAfter,$GUI_ENABLE)
	Else
		If BitAND(GUICtrlGetState($rClBefore),$GUI_ENABLE) Then GUICtrlSetState($rClBefore,$GUI_DISABLE)
		If BitAND(GUICtrlGetState($rClAfter),$GUI_ENABLE) Then GUICtrlSetState($rClAfter,$GUI_DISABLE)
	EndIf

	; Checks whether the "Randomized message" is checked or not, and disable/enable the options below (and avoid flickering with basic GUICtrlSetState())
	If GUICtrlRead($cbRandomized) == 1 Then
		If BitAND(GUICtrlGetState($cbUpperCase),$GUI_DISABLE) Then GUICtrlSetState($cbUpperCase,$GUI_ENABLE)
		If BitAND(GUICtrlGetState($cbLowerCase),$GUI_DISABLE) Then GUICtrlSetState($cbLowerCase,$GUI_ENABLE)
		If BitAND(GUICtrlGetState($cbLetters),$GUI_DISABLE) Then GUICtrlSetState($cbLetters,$GUI_ENABLE)
		If BitAND(GUICtrlGetState($cbNumbers),$GUI_DISABLE) Then GUICtrlSetState($cbNumbers,$GUI_ENABLE)
		If BitAND(GUICtrlGetState($cbSymbols),$GUI_DISABLE) Then GUICtrlSetState($cbSymbols,$GUI_ENABLE)
	Else
		If BitAND(GUICtrlGetState($cbUpperCase),$GUI_ENABLE) Then GUICtrlSetState($cbUpperCase,$GUI_DISABLE)
		If BitAND(GUICtrlGetState($cbLowerCase),$GUI_ENABLE) Then GUICtrlSetState($cbLowerCase,$GUI_DISABLE)
		If BitAND(GUICtrlGetState($cbLetters),$GUI_ENABLE) Then GUICtrlSetState($cbLetters,$GUI_DISABLE)
		If BitAND(GUICtrlGetState($cbNumbers),$GUI_ENABLE) Then GUICtrlSetState($cbNumbers,$GUI_DISABLE)
		If BitAND(GUICtrlGetState($cbSymbols),$GUI_ENABLE) Then GUICtrlSetState($cbSymbols,$GUI_DISABLE)
	EndIf

	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btStart
			Local $CountDown = GUICtrlRead($inMsgCountdown) * 1000
			Sleep($CountDown)
			StartSpam()

	EndSwitch
WEnd


Func StartSpam()

	$SpamAmount = GUICtrlRead($inMsgNo)

	For $i = 1 To $SpamAmount

		; If "Click" and "Before" are checked
		If GUICtrlRead($cbClick) == 1 And GUICtrlRead($rClBefore) == 1 Then
			MouseClick("left")
		EndIf

		; If "Press enter" and "Before" are checked
		If GUICtrlRead($cbEnter) == 1 And GUICtrlRead($rEnBefore) == 1 Then
			Send("{ENTER}")
		EndIf

		$Message = GUICtrlRead($inMsg)
		$SpamSpeed = GUICtrlRead($inMsgDelay)
		$SpamNumber += 1

		If GUICtrlRead($cbRandomized) == 1 Then
			GenerateRandomWord()
		Else

			Send($Message, 1)

			If GUICtrlRead($cbMsgLength) == 1 Then
				$LengthOfMessage = StringLen($Message)
				Send("[")
				Send($LengthOfMessage)
				Send("]")
			EndIf

			If GUICtrlRead($cbMsgNo) == 1 Then
				Send("[")
				Send($SpamNumber)
				Send("]")
			EndIf

			; If "Press enter" and "After" are checked
			If GUICtrlRead($cbEnter) == 1 And GUICtrlRead($rEnAfter) == 1 Then
				Send("{ENTER}")
			EndIf

			; If "Click" and "After" are checked
			If GUICtrlRead($cbClick) == 1 And GUICtrlRead($rClAfter) == 1 Then
				MouseClick("left")
			EndIf

			Sleep($SpamSpeed)
		EndIf

	Next
		$SpamNumber = 0 ;Reset the number
		$LengthOfMessage = 0
EndFunc


Func GenerateRandomWord()


   Local $RandomLetter
   Local $SelectedLetter = 1000
   Local $LengthLetter = Random(5,20)
   Local $RandomizeCapital
   Local $RandomizeNumber
   Local $RandomizeSymbol
   Local $RoundedNumber


   Sleep(GUICtrlRead($inMsgDelay))

	If $SelectedLetter == 1000 Then

		; If "Click" and "Before" are checked
		If GUICtrlRead($cbClick) == 1 And GUICtrlRead($rClBefore) == 1 Then
			MouseClick("left")
		EndIf

		; If "Press enter" and "Before" are checked
		If GUICtrlRead($cbEnter) == 1 And GUICtrlRead($rEnBefore) == 1 Then
			Send("{ENTER}")
		EndIf

	   	For $i = 0 To $LengthLetter Step + 1

			$LengthOfMessage += 1

			$RandomizeNumber = Random(0,100)
			$RandomizeSymbol = Random(0,100)

			If GUICtrlRead($cbNumbers) == 1 And $RandomizeNumber <= 25 Then
				$SelectedLetter = Random(0,9)
				$SelectedLetter = Round($SelectedLetter)
			ElseIf GUICtrlRead($cbSymbols) == 1 And $RandomizeSymbol <= 25 Then
				$RandomLetter = Random(1,33)
				If $RandomLetter > 0 And $RandomLetter <= 1 Then
					$SelectedLetter = "!"
				EndIf
				If $RandomLetter > 1 And $RandomLetter <= 2 Then
					$SelectedLetter = '"'
				EndIf
				If $RandomLetter > 2 And $RandomLetter <= 3 Then
					$SelectedLetter = "#"
				EndIf
				If $RandomLetter > 3 And $RandomLetter <= 4 Then
					$SelectedLetter = "¤"
				EndIf
				If $RandomLetter > 4 And $RandomLetter <= 5 Then
					$SelectedLetter = "%"
				EndIf
				If $RandomLetter > 5 And $RandomLetter <= 6 Then
					$SelectedLetter = "&"
				EndIf
				If $RandomLetter > 6 And $RandomLetter <= 7 Then
					$SelectedLetter = "/"
				EndIf
				If $RandomLetter > 7 And $RandomLetter <= 8 Then
					$SelectedLetter = "("
				EndIf
				If $RandomLetter > 8 And $RandomLetter <= 9 Then
					$SelectedLetter = ")"
				EndIf
				If $RandomLetter > 9 And $RandomLetter <= 10 Then
					$SelectedLetter = "="
				EndIf
				If $RandomLetter > 10 And $RandomLetter <= 11 Then
					$SelectedLetter = "?"
				EndIf
				If $RandomLetter > 11 And $RandomLetter <= 12 Then
					$SelectedLetter = "`"
				EndIf
				If $RandomLetter > 12 And $RandomLetter <= 13 Then
					$SelectedLetter = "^"
				EndIf
				If $RandomLetter > 13 And $RandomLetter <= 14 Then
					$SelectedLetter = "*"
				EndIf
				If $RandomLetter > 14 And $RandomLetter <= 15 Then
					$SelectedLetter = "_"
				EndIf
				If $RandomLetter > 15 And $RandomLetter <= 16 Then
					$SelectedLetter = ":"
				EndIf
				If $RandomLetter > 16 And $RandomLetter <= 17 Then
					$SelectedLetter = ";"
				EndIf
				If $RandomLetter > 17 And $RandomLetter <= 18 Then
					$SelectedLetter = "@"
				EndIf
				If $RandomLetter > 18 And $RandomLetter <= 19 Then
					$SelectedLetter = "£"
				EndIf
				If $RandomLetter > 19 And $RandomLetter <= 20 Then
					$SelectedLetter = "$"
				EndIf
				If $RandomLetter > 20 And $RandomLetter <= 21 Then
					$SelectedLetter = "€"
				EndIf
				If $RandomLetter > 21 And $RandomLetter <= 22 Then
					$SelectedLetter = "{"
				EndIf
				If $RandomLetter > 22 And $RandomLetter <= 23 Then
					$SelectedLetter = "["
				EndIf
				If $RandomLetter > 23 And $RandomLetter <= 24 Then
					$SelectedLetter = "]"
				EndIf
				If $RandomLetter > 24 And $RandomLetter <= 25 Then
					$SelectedLetter = "}"
				EndIf
				If $RandomLetter > 25 And $RandomLetter <= 26 Then
					$SelectedLetter = "\"
				EndIf
				If $RandomLetter > 26 And $RandomLetter <= 27 Then
					$SelectedLetter = "~"
				EndIf
				If $RandomLetter > 27 And $RandomLetter <= 28 Then
					$SelectedLetter = "+"
				EndIf
				If $RandomLetter > 28 And $RandomLetter <= 29 Then
					$SelectedLetter = "´"
				EndIf
				If $RandomLetter > 29 And $RandomLetter <= 30 Then
					$SelectedLetter = "¨"
				EndIf
				If $RandomLetter > 30 And $RandomLetter <= 31 Then
					$SelectedLetter = "'"
				EndIf
				If $RandomLetter > 31 And $RandomLetter <= 32 Then
					$SelectedLetter = "."
				EndIf
				If $RandomLetter > 32 And $RandomLetter <= 33 Then
					$SelectedLetter = ","
				EndIf

			ElseIf GUICtrlRead($cbLetters) == 1 Then

				$RandomLetter = random(0,26)
				If $RandomLetter > 0 And $RandomLetter <= 1 Then
					$SelectedLetter = "a"
					$Alphabet = True
				EndIf
				If $RandomLetter > 1 And $RandomLetter <= 2 Then
					$SelectedLetter = "b"
					$Alphabet = True
				EndIf
				If $RandomLetter > 2 And $RandomLetter <= 3 Then
					$SelectedLetter = "c"
					$Alphabet = True
				EndIf
				If $RandomLetter > 3 And $RandomLetter <= 4 Then
					$SelectedLetter = "d"
					$Alphabet = True
				EndIf
				If $RandomLetter > 4 And $RandomLetter <= 5 Then
					$SelectedLetter = "e"
					$Alphabet = True
				EndIf
				If $RandomLetter > 5 And $RandomLetter <= 6 Then
					$SelectedLetter = "f"
					$Alphabet = True
				EndIf
				If $RandomLetter > 6 And $RandomLetter <= 7 Then
					$SelectedLetter = "g"
					$Alphabet = True
				EndIf
				If $RandomLetter > 7 And $RandomLetter <= 8 Then
					$SelectedLetter = "h"
					$Alphabet = True
				EndIf
				If $RandomLetter > 8 And $RandomLetter <= 9 Then
					$SelectedLetter = "i"
					$Alphabet = True
				EndIf
				If $RandomLetter > 9 And $RandomLetter <= 10 Then
					$SelectedLetter = "j"
					$Alphabet = True
				EndIf
				If $RandomLetter > 10 And $RandomLetter <= 11 Then
					$SelectedLetter = "k"
					$Alphabet = True
				EndIf
				If $RandomLetter > 11 And $RandomLetter <= 12 Then
					$SelectedLetter = "l"
					$Alphabet = True
				EndIf
				If $RandomLetter > 12 And $RandomLetter <= 13 Then
					$SelectedLetter = "m"
					$Alphabet = True
				EndIf
				If $RandomLetter > 13 And $RandomLetter <= 14 Then
					$SelectedLetter = "n"
					$Alphabet = True
				EndIf
				If $RandomLetter > 14 And $RandomLetter <= 15 Then
					$SelectedLetter = "o"
					$Alphabet = True
				EndIf
				If $RandomLetter > 15 And $RandomLetter <= 16 Then
					$SelectedLetter = "p"
					$Alphabet = True
				EndIf
				If $RandomLetter > 16 And $RandomLetter <= 17 Then
					$SelectedLetter = "q"
					$Alphabet = True
				EndIf
				If $RandomLetter > 17 And $RandomLetter <= 18 Then
					$SelectedLetter = "r"
					$Alphabet = True
				EndIf
				If $RandomLetter > 18 And $RandomLetter <= 19 Then
					$SelectedLetter = "s"
					$Alphabet = True
				EndIf
				If $RandomLetter > 19 And $RandomLetter <= 20 Then
					$SelectedLetter = "t"
					$Alphabet = True
				EndIf
				If $RandomLetter > 20 And $RandomLetter <= 21 Then
					$SelectedLetter = "u"
					$Alphabet = True
				EndIf
				If $RandomLetter > 21 And $RandomLetter <= 22 Then
					$SelectedLetter = "v"
					$Alphabet = True
				EndIf
				If $RandomLetter > 22 And $RandomLetter <= 23 Then
					$SelectedLetter = "w"
					$Alphabet = True
				EndIf
				If $RandomLetter > 23 And $RandomLetter <= 24 Then
					$SelectedLetter = "x"
					$Alphabet = True
				EndIf
				If $RandomLetter > 24 And $RandomLetter <= 25 Then
					$SelectedLetter = "y"
					$Alphabet = True
				EndIf
				If $RandomLetter > 25 And $RandomLetter <= 26 Then
					$SelectedLetter = "z"
					$Alphabet = True
				EndIf
			Else
				ConsoleWrite("Error: No letters selected! Program terminated.")
				ToolTip("No letters selected...")
				Sleep(1000)
				Exit
			EndIf

			; Checks whether the alphabet should be in uppercase or lowercase
			If GUICtrlRead($cbUpperCase) == 1 And $Alphabet == True Then
				If GUICtrlRead($cbLowerCase) == 1 Then
					$RandomizeCapital = random(0,100)
					If $RandomizeCapital <= 30 Then
						$SelectedLetter = StringUpper($SelectedLetter)
					EndIf
				Else
					$SelectedLetter = StringUpper($SelectedLetter)
				EndIf
			EndIf

			$Alphabet = False

			Send($SelectedLetter, 1)

		Next

		If GUICtrlRead($cbMsgLength) == 1 Then
			Send("[")
			Send($LengthOfMessage)
			Send("]")
		EndIf

		If GUICtrlRead($cbMsgNo) == 1 Then
			Send("[")
			Send($SpamNumber)
			Send("]")
		EndIf

		; If "Press enter" and "After" are checked
		If GUICtrlRead($cbEnter) == 1 And GUICtrlRead($rEnAfter) == 1 Then
			Send("{ENTER}")
		EndIf

		; If "Click" and "After" are checked
		If GUICtrlRead($cbClick) == 1 And GUICtrlRead($rClAfter) == 1 Then
			MouseClick("left")
		EndIf

		$LengthOfMessage = 0
	EndIf
EndFunc