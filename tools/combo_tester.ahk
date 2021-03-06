; -----------------------------------------------------------------------------------------
; Clicker Heroes Skill Combo Tester
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Persistent
#NoEnv

SetTitleMatchMode, regex ; Steam [3] or browser [regex] version?

; winName=Clicker Heroes ; Steam
winName=Lvl.*Clicker Heroes.* ; browser

comboEDR := [2.5*60, "2-3-4-5-7-8-6-9", "", "", "", "", "", "8-9-2-3-4-5-7", "2", "2", "2-3-4", "2", "2"]
comboEGolden := [2.5*60, "8-5-2-3-4-7-6-9", "2", "2", "2-3-4", "2", "2"] ; energize 3 (dmg) or 5 (gold)
comboGoldenLuck := [2.5*60, "6-2-3-5-8-9", "2-3-4-5-7", "2", "2", "2-3-4", "2", "2"]

comboHybridIdle := [15*60, "2-3-4-5-7-6-9-8"] ; energize >
comboHybridActive := [30, "5-2-4-6-7", "", "", "3-8-9", "", "", "2", "", "", "3-7", "", "1-2"] ; > golden clicks, 6 minutes

activeClicker := true ; set to false to add Clickstorm
testMode := true

; -----------------------------------------------------------------------------------------
; -- Hotkeys
; -----------------------------------------------------------------------------------------

F1::
	comboTester(comboEDR)
return

F2::
	comboTester(comboEGolden)
return

F3::
	comboTester(comboGoldenLuck)
return

F4::
	comboTester(comboHybridActive)
return

F5::
	Reload
return

comboTester(combo) {
	global activeClicker, testMode

	seconds := 31*60
	t := 0

	comboDelay := combo[1]
	comboIndex := 2

	output := ""

	while(t < seconds)
	{
		if (mod(t, comboDelay) = 0) {
			if (testMode and comboIndex = 2 and A_Index > 1) {
				output .= formatSeconds(t) . " : " . "repeat"
				break
			}
			skills := activeClicker ? combo[comboIndex] : StrReplace(combo[comboIndex], "2", "1-2")
			if (!testMode) {
				activateSkills(skills)
			}
			output .= formatSeconds(t) . " : " . skills . "`r`n"
			comboIndex := comboIndex < combo.MaxIndex() ? comboIndex+1 : 2
		}
		t += 1
		if (!testMode) {
			sleep 1000
		}
	}

	clipboard := % output
	msgbox % output
}

activateSkills(skills) {
	global
	loop,parse,skills,-
	{
		ControlSend,,% A_LoopField, % winName
		sleep 100
	}
	sleep 1000
}

formatSeconds(s) {
    time := 19990101 ; *Midnight* of an arbitrary date.
    time += %s%, seconds
	FormatTime, timeStr, %time%, mm:ss
    return timeStr
}
