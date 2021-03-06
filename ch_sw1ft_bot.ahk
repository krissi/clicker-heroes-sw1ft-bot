; -----------------------------------------------------------------------------------------
; Clicker Heroes Sw1ft Bot
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Persistent
#NoEnv
#InstallKeybdHook

#Include %A_ScriptDir%
#Include ch_bot_lib.ahk

SetControlDelay, -1

scriptName=CH Sw1ft Bot
scriptVersion=2.32
minLibVersion=1.31

script := scriptName . " v" . scriptVersion

; Load default settings
#Include *i ch_bot_settings_default.ahk

; -----------------------------------------------------------------------------------------

if (libVersion != minLibVersion) {
	showWarningSplash("The bot lib version must be " . minLibVersion . "!")
	ExitApp
}

#Include *i ch_bot_settings.ahk

scheduleReload := false
scheduleStop := false

if (useConfigurationAssistant) {
	configurationAssistant()
}

clientCheck()
handleAutorun()

; -----------------------------------------------------------------------------------------
; -- Hotkeys (+=Shift, !=Alt, ^=Ctrl)
; -----------------------------------------------------------------------------------------

; Toggle all hotkeys
^+!F12::Suspend, Toggle
return

; Show the cursor position with Alt+Middle Mouse Button
!mbutton::
	mousegetpos, xpos, ypos
	msgbox,,% script,% "Cursor position: x" xpos-leftMarginOffset " y" ypos-topMarginOffset
return

; Pause/Unpause script
Pause::Pause
return

; Abort speed/deep runs and auto ascensions with Alt+Pause
!Pause::
	showSplashAlways("Aborting...")
	exitThread := true
	exitDRThread := true
return

; Quick tests:
; Ctrl+Alt+F1 should scroll down to the bottom
; Ctrl+Alt+F2 should switch to the relics tab and then back

^!F1::
	scrollToBottom()
return

^!F2::
	switchToRelicTab()
	switchToCombatTab()
return

; Alt+F1 to F4 are here to test the individual parts of the full speed run loop

!F1::
	getClickable()
return

!F2::
	initRun()
return

!F3::
	switchToCombatTab()
	speedRun()
return

!F4::
	ascend(autoAscend)
return

; Reload script with Alt+F5
!F5::
	global scheduleReload := true
	handleScheduledReload()
return

; Speed run loop.
; Use to farm Hero Souls
^F1::
	loopSpeedRun()
return

; Deep run.
; Use (after a speed run) to get a few new gilds every now and then
^F2::
	deepRun()
return

; Set previous ranger as re-gild target
^F6::
	reGildRanger := reGildRanger > rangers.MinIndex() ? reGildRanger-1 : reGildRanger
	showSplashAlways("Re-gild ranger set to " . rangers[reGildRanger])
return

; Set next ranger as re-gild target
^F7::
	reGildRanger := reGildRanger < rangers.MaxIndex() ? reGildRanger+1 : reGildRanger
	showSplashAlways("Re-gild ranger set to " . rangers[reGildRanger])
return

; Move "reGildCount" gilds to the target ranger (will pause the monster clicker if running)
^F8::
	critical
	playNotificationSound()
	msgbox, 4,% script,% "Move " . reGildCount . " gilds to " . rangers[reGildRanger] . "?"
	ifmsgbox no
		return
	regild(reGildRanger, reGildCount) ; will pause the monster clicker if running
return

; Autosave the game
^F11::
	critical
	monsterClickerPause()
	save()
return

; Toggle boolean (true/false) flags

+^F1::
	toggleFlag("autoAscend", autoAscend)
return

+^F2::
	toggleFlag("screenShotRelics", screenShotRelics)
return

+^F3::
	toggleFlag("playNotificationSounds", playNotificationSounds)
return

+^F4::
	toggleFlag("playWarningSounds", playWarningSounds)
return

+^F5::
	toggleFlag("showSplashTexts", showSplashTexts)
return

+^F11::
	toggleFlag("saveBeforeAscending", saveBeforeAscending)
return

+^F12::
	toggleFlag("debug", debug)
return

; Schedule reload script with Shift+F5
+F5::
	toggleFlag("scheduleReload", scheduleReload)
return

+Pause::
	toggleFlag("scheduleStop", scheduleStop)
return


; -----------------------------------------------------------------------------------------
; -- Functions
; -----------------------------------------------------------------------------------------

; Automatically configure initDownClicks and yLvlInit settings.
configurationAssistant() {
	global

	if (irisLevel < 145) {
		playWarningSound()
		msgbox,,% script,% "Your Iris do not fulfill the minimum level requirement of 145 or higher!"
		exit
	}

	if (irisThreshold(2010)) { ; Astraea
		initDownClicks := [6,5,6,5,6,3]
		yLvlInit := 241
	} else if (irisThreshold(1760)) { ; Alabaster
		initDownClicks := [6,6,5,6,6,3]
		yLvlInit := 259
	} else if (irisThreshold(1510)) { ; Cadmia
		initDownClicks := [6,6,6,6,6,3]
		yLvlInit := 240
	} else if (irisThreshold(1260)) { ; Lilin
		initDownClicks := [6,6,6,6,6,3]
		yLvlInit := 285
	} else if (irisThreshold(1010)) { ; Banana
		initDownClicks := [6,7,6,7,6,3]
		yLvlInit := 240
	} else if (irisThreshold(760)) { ; Phthalo
		initDownClicks := [6,7,7,6,7,3]
		yLvlInit := 273
	} else if (irisThreshold(510)) { ; Terra
		initDownClicks := [7,7,7,7,7,3]
		yLvlInit := 240
	} else if (irisThreshold(260)) { ; Atlas
		initDownClicks := [7,7,7,8,7,3]
		yLvlInit := 273
	} else { ; Dread Knight
		initDownClicks := [7,8,7,8,7,4]
		yLvlInit := 257
	}

	if (irisLevel < optimalLevel - 1001) {
		local levels := optimalLevel - 1001 - irisLevel
		playNotificationSound()
		msgbox,,% script,% "Your Iris is " . levels . " levels below the recommended ""optimal level - 1001"" rule."
	}
}

; Check if Iris is within a certain threshold that can cause a toggling behaviour between different settings
irisThreshold(lvl) {
	global
	local upperThreshold := lvl + 19
	local lowerThreshold := lvl - 20
	if (irisLevel >= lowerThreshold and irisLevel < upperThreshold) {
		playWarningSound()
		msgbox,,% script,% "Threshold proximity warning! You should level up your Iris to " . upperThreshold . " or higher."
	}
	return irisLevel > lvl
}

; Level up and upgrade all heroes
initRun() {
	global

	switchToCombatTab()
	clickPos(xHero, yHero) ; prevent fails

	upgrade(initDownClicks[1],2,,2) ; cid --> brittany
	upgrade(initDownClicks[2]) ; fisherman --> leon
	upgrade(initDownClicks[3]) ; seer --> mercedes
	upgrade(initDownClicks[4],,,,2) ; bobby --> king
	upgrade(initDownClicks[5],2,,,2) ; ice --> amenhotep
	upgrade(initDownClicks[6],,,2) ; beastlord --> shinatobe
	upgrade(0,,,,,true) ; grant & frostleaf

	scrollToBottom()
	buyAvailableUpgrades()
}

upgrade(times, cc1:=1, cc2:=1, cc3:=1, cc4:=1, skip:=false) {
	global

	if (!skip) {
		ctrlClick(xLvl, yLvlInit, cc1)
		ctrlClick(xLvl, yLvlInit + oLvl, cc2)
	}
	ctrlClick(xLvl, yLvlInit + oLvl*2, cc3)
	ctrlClick(xLvl, yLvlInit + oLvl*3, cc4)

	scrollDown(times)
}

loopSpeedRun() {
	global

	mode := hybridMode ? "hybrid" : "speed"
	showSplashAlways("Starting " . mode . " runs...")
	loop
	{
		getClickable()
		sleep % coinPickUpDelay * 1000
		initRun()
		if (activateSkillsAtStart) {
			activateSkills(speedRunStartCombo[2])
		}
		speedRun()
		if (hybridMode) {
			deepRun()
		}
		if (saveBeforeAscending) {
			save()
		}
		ascend(autoAscend)
		handleScheduledReload(true)
		handleScheduledStop()
	}
}

; All heroes/rangers are expected to "insta-kill" everything at max speed (i.e. around
; 7 minutes per 250 levels). Only the last 2-3 minutes should slow down slightly.
speedRun() {
	global

	local stint := 0
	local stints := 0
	local tMax := 7 * 60 ; seconds
	local lMax := 250 ; zones

	local lvlAdjustment := round(firstStintAdjustment * lMax / tMax)
	local zoneLvl := gildedRanger * lMax + lvlAdjustment ; approx zone lvl where we can buy our gilded ranger @ lvl 150
	local lvls := zoneLvl - irisLevel ; lvl's to get there

	local firstStintButton := 1
	local firstStintTime := 0
	local midStintTime := 0

	if (lvls > lMax + 2*60*lMax/tMax) ; add a mid stint if needed
	{
		midStintTime := tMax
		lvls -= lMax
		stints += 1
	} else if (lvls > lMax) {
		firstStintButton := 2
	}
	
	if (lvls > 0)
	{
		firstStintTime := ceil(lvls * tMax / lMax)
		stints += 1
	}

	local srDuration := speedRunTime * 60
	local totalClickDelay := ceil(srDuration / lvlUpDelay * zzz / 1000 + nextHeroDelay * stints)
	local lastStintTime := srDuration - firstStintTime - midStintTime - totalClickDelay
	stints += 1

	local lastStintButton := gildedRanger = 9 ? 3 : 2 ; special case for Astraea

	if (debug)
	{
		local nl := "`r`n"
		local s := "    " ; Reddit friendly formatting
		local output := ""
		output .= s . "irisLevel = " . irisLevel . nl
		output .= s . "optimalLevel = " . optimalLevel . nl
		output .= s . "speedRunTime = " . speedRunTime . nl
		output .= s . "gildedRanger = " . rangers[gildedRanger] . nl
		output .= s . "-----------------------------" . nl
		output .= s . "initDownClicks = "
		for i, e in initDownClicks {
			output .= e " "
		}
		output .= nl
		output .= s . "yLvlInit = " . yLvlInit . nl
		output .= s . "firstStintAdjustment = " . firstStintAdjustment . "s" . nl
		output .= s . "-----------------------------" . nl
		output .= s . "lvlAdjustment = " . lvlAdjustment . nl
		output .= s . "zoneLvl = " . zoneLvl . nl
		output .= s . "lvls = " . lvls . nl
		output .= s . "srDuration = " . formatSeconds(srDuration) . nl
		output .= s . "firstStintButton = " . firstStintButton . nl
		output .= s . "firstStintTime = " . formatSeconds(firstStintTime) . nl
		output .= s . "midStintTime = " . formatSeconds(midStintTime) . nl
		output .= s . "lastStintTime = " . formatSeconds(lastStintTime) . nl
		output .= s . "totalClickDelay = " . formatSeconds(totalClickDelay) . nl

		clipboard := % output
		msgbox % output
		return
	}

	showSplash("Starting speed run...")

	if (irisLevel < 2 * lMax + 10) ; Iris high enough to start with a ranger?
	{
		switchToCombatTab()
		scrollDown(initDownClicks[1])
		toggleMode() ; toggle to progression mode
		lvlUp(firstStintTime, 0, 3, ++stint, stints) ; nope, let's bridge with Samurai
		scrollToBottom()
	} else {
		scrollToBottom()
		toggleMode() ; toggle to progression mode
		if (firstStintTime > 0) {
			lvlUp(firstStintTime, 1, firstStintButton, ++stint, stints)
			scrollWayDown(3)
		}
	}
	if (midStintTime > 0) {
		lvlUp(midStintTime, 1, 2, ++stint, stints)
		scrollWayDown(2)
	}
	lvlUp(lastStintTime, 1, lastStintButton, ++stint, stints)

	showSplash("Speed run completed.")
}

deepRun() {
	global

	exitDRThread := false

	local drDuration := deepRunTime * 60
	local button := gildedRanger = 9 ? 3 : 2 ; special case for Astraea
	local y := yLvl + oLvl * (button - 1)

	showSplash("Starting deep run...")

	startMouseMonitoring()
	startProgress("Deep Run Progress", 0, drDuration // barUpdateDelay)
	if (deepRunClicks) {
		monsterClickerOn()
	}

	local comboDelay := deepRunCombo[1]
	local comboIndex := 2
	local stopHuntIndex := drDuration - stopHuntThreshold * 60
	local t := 0

	loop % drDuration
	{
		if (exitDRThread) {
			monsterClickerOff()
			stopProgress()
			stopMouseMonitoring()
			showSplashAlways("Deep run aborted!")
			exit
		}
		if (deepRunClicks) {
			clickPos(xMonster, yMonster)
		}
		if (mod(t, comboDelay) = 0) {
			activateSkills(deepRunCombo[comboIndex])
			comboIndex := comboIndex < deepRunCombo.MaxIndex() ? comboIndex+1 : 2
		}
		if (mod(t, lvlUpDelay) = 0) {
			ctrlClick(xLvl, y, 1, 0)
		}
		if (mod(t, clickableHuntDelay) = 0 and t < stopHuntIndex) {
			getClickable()
		}
		t += 1
		updateProgress(t // barUpdateDelay, drDuration - t)
		sleep 1000
	}

	if (deepRunClicks) {
		monsterClickerOff()
	}
	stopProgress()
	stopMouseMonitoring()

	showSplash("Deep run ended.")
	sleep 1000
}

monsterClickerOn() {
	send {shift down}{f1 down}{f1 up}{shift up}
}

monsterClickerPause() {
	send {shift down}{f2 down}{f2 up}{shift up}
}

monsterClickerOff() {
	send {shift down}{pause down}{pause up}{shift up}
}

lvlUp(seconds, buyUpgrades, button, stint, stints) {
	global

	exitThread := false
	local y := yLvl + oLvl * (button - 1)
	local title := "Speed Run Progress (" . stint . "/" . stints . ")"

	startMouseMonitoring()
	startProgress(title, 0, seconds // barUpdateDelay)

	if (buyUpgrades) {
		ctrlClick(xLvl, y)
		buyAvailableUpgrades()
	}
	maxClick(xLvl, y)

	local t := 0

	loop % seconds
	{
		if (exitThread) {
			stopProgress()
			stopMouseMonitoring()
			showSplashAlways("Speed run aborted!")
			exit
		}
		if (mod(t, lvlUpDelay) = 0) {
			ctrlClick(xLvl, y)
		}
		t += 1
		updateProgress(t // barUpdateDelay, seconds - t)
		sleep 1000
	}
	stopProgress()
	stopMouseMonitoring()
}

ascend(autoYes:=false) {
	global
	exitThread := false
	local extraClicks := 6
	local y := yAsc - extraClicks * buttonSize

	if (autoYes) {
		showWarningSplash(autoAscendDelay . " seconds till ASCENSION! (Abort with Alt+Pause)", autoAscendDelay)
		if (exitThread) {
			showSplashAlways("Ascension aborted!")
			exit
		}
	} else {
		playWarningSound()
		msgbox, 260,% script,Salvage Junk Pile & Ascend? ; default no
		ifmsgbox no
			exit
	}

	salvageJunkPile() ; must salvage junk relics before ascending

	switchToCombatTab()
	scrollDown(ascDownClicks)
	sleep % zzz * 2

	; Scrolling is not an exact science, hence we click above, center and below
	loop % 2 * extraClicks + 1
	{
		clickPos(xAsc, y)
		y += buttonSize
	}
	sleep % zzz * 4
	clickPos(xYes, yYes)
	sleep % zzz * 2
}

salvageJunkPile() {
	global

	switchToRelicTab()
	if (autoAscend && screenShotRelics) {
		clickPos(xRelic, yRelic) ; focus
		screenShot()
		clickPos(xRelic+100, yRelic) ; remove focus
	}
	clickPos(xSalvageJunk, ySalvageJunk)
	sleep % zzz * 4
	clickPos(xDestroyYes, yDestroyYes)
	sleep % zzz * 2
}

buyAvailableUpgrades() {
	global
	clickPos(xBuy, yBuy)
	sleep % zzz * 3
}

; Move "gildCount" gilds to given ranger
regild(ranger, gildCount) {
	global
	monsterClickerPause()
	switchToCombatTab()
	scrollToBottom()

	clickPos(xGilded, yGilded)
	sleep % zzz * 2

	ControlSend,, {shift down}, % winName
	clickPos(rangerPositions[ranger].x, rangerPositions[ranger].y, gildCount)
	sleep % 1000 * gildCount/100*5
	ControlSend,, {shift up}, % winName

	clickPos(xGildedClose, yGildedClose)
	sleep % zzz * 2
}

; Toggle between farm and progression modes
toggleMode() {
	global
	ControlSend,, {a down}{a up}, % winName
	sleep % zzz
}

activateSkills(skills) {
	global
	clickPos(xHero, yHero) ; prevent fails
	loop,parse,skills,-
	{
		ControlSend,,% A_LoopField, % winName
		sleep 100
	}
	sleep 1000
}

startMouseMonitoring() {
	setTimer, checkMousePosition, 250
}

stopMouseMonitoring() {
	setTimer, checkMousePosition, off
}


handleScheduledReload(autorun := false) {
	global
	if(scheduleReload) {
		showSplashAlways("Reloading bot...", 1)

		autorun_flag := autorun = true ? "/autorun" : ""
		Run "%A_AhkPath%" /restart "%A_ScriptFullPath%" %autorun_flag%
	}
}

handleScheduledStop() {
	global
	if(scheduleStop) {
		showSplashAlways("Stopping speedruns...", 1)
		scheduleStop := false
		exit
	}
}

handleAutorun() {
	global
	param_1 = %1%
	if(param_1 = "/autorun") {
		showSplashAlways("Autorun speedruns...")
		loopSpeedrun()
	}
}


; -----------------------------------------------------------------------------------------
; -- Subroutines
; -----------------------------------------------------------------------------------------

; Safety zone around the in-game tabs (that triggers an automatic script pause when breached)
checkMousePosition:
	MouseGetPos,,, window
	if (window = WinExist(winName)) {
		WinActivate
		MouseGetPos, x, y

		xL := getAdjustedX(xSafetyZoneL)
		xR := getAdjustedX(xSafetyZoneR)
		yT := getAdjustedY(ySafetyZoneT)
		yB := getAdjustedY(ySafetyZoneB)

		if (x > xL && x < xR && y > yT && y < yB) {
			playNotificationSound()
			msgbox,,% script,Click safety pause engaged. Continue?
		}
	}
return

