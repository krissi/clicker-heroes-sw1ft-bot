; -----------------------------------------------------------------------------------------
; Clicker Heroes Sw1ft Bot
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Persistent
#NoEnv
#InstallKeybdHook

#Include <Gui>
#Include ch_bot_lib.ahk


SetControlDelay, -1

scriptName=CH Sw1ft Bot
scriptVersion=2.41
minLibVersion=1.32

script := scriptName . " v" . scriptVersion

#Include <Configuration>

configuration := new Configuration()

gui := new Gui(script, configuration.gui)

scheduleReload := false
scheduleStop := false

; -----------------------------------------------------------------------------------------

; Load system default settings
#Include system\ch_bot_default_settings.ahk

IfNotExist, ch_bot_settings.ahk
{
	FileCopy, system\ch_bot_default_settings.ahk, ch_bot_settings.ahk
}

; Load user settings
#Include *i ch_bot_settings.ahk

bot_lib := new ChBotLib(gui)

if (bot_lib.libVersion != minLibVersion) {
	gui.showWarningSplash("The bot lib version must be " . minLibVersion . "!")
	ExitApp
}

if (useConfigurationAssistant) {
	bot_lib.configurationAssistant()
}

if (deepRunClicks) {
	Run, "%A_ScriptDir%\monster_clicker.ahk",, UseErrorLevel
	if (ErrorLevel != 0) {
		gui.playWarningSound()
    	msgbox,,% script,% "Failed to auto-start monster_clicker.ahk (system error code = " . A_LastError . ")!"
	}
}

bot_lib.handleAutorun()

; -----------------------------------------------------------------------------------------
; -- Hotkeys (+=Shift, !=Alt, ^=Ctrl)
; -----------------------------------------------------------------------------------------

; Suspend/Unsuspend all other Hotkeys
^Esc::Suspend, Toggle
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
	gui.showSplashAlways("Aborting...")
	exitThread := true
	exitDRThread := true
return

; Quick tests:
; Ctrl+Alt+F1 should scroll down to the bottom
; Ctrl+Alt+F2 should switch to the relics tab and then back

^!F1::
	bot_lib.scrollToBottom()
return

^!F2::
	bot_lib.switchToRelicTab()
	bot_lib.switchToCombatTab()
return

; Alt+F1 to F4 are here to test the individual parts of the full speed run loop

!F1::
	bot_lib.getClickable()
return

!F2::
	initRun()
return

!F3::
	bot_lib.switchToCombatTab()
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

; Speed run loop
^F1::
	loopSpeedRun()
return

; Stop looping when current speed run finishes with Shift+Pause
+Pause::
	bot_lib.toggleFlag("scheduleStop", scheduleStop)
return

; Deep run
; Use (after a speed run)
^F2::
	deepRun()
return

; Open the Ancients Optimizer and auto-import game save data
^F5::
	openAncientsOptimizer()
return

; Set previous ranger as re-gild target
^F6::
	reGildRanger := reGildRanger > rangers.MinIndex() ? reGildRanger-1 : reGildRanger
	gui.showSplashAlways("Re-gild ranger set to " . rangers[reGildRanger])
return

; Set next ranger as re-gild target
^F7::
	reGildRanger := reGildRanger < rangers.MaxIndex() ? reGildRanger+1 : reGildRanger
	gui.showSplashAlways("Re-gild ranger set to " . rangers[reGildRanger])
return

; Move "reGildCount" gilds to the target ranger (will pause the monster clicker if running)
^F8::
	critical
	gui.playNotificationSound()
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
	bot_lib.toggleFlag("autoAscend", autoAscend)
return

+^F2::
	bot_lib.toggleFlag("screenShotRelics", screenShotRelics)
return

+^F5::
	bot_lib.toggleFlag("scheduleReload", scheduleReload)
return

+^F6::
	bot_lib.toggleFlag("playNotificationSounds", playNotificationSounds)
return

+^F7::
	bot_lib.toggleFlag("playWarningSounds", playWarningSounds)
return

+^F8::
	bot_lib.toggleFlag("showSplashTexts", showSplashTexts)
return

+^F11::
	bot_lib.toggleFlag("saveBeforeAscending", saveBeforeAscending)
return

+^F12::
	bot_lib.toggleFlag("debug", debug)
return

; -----------------------------------------------------------------------------------------
; -- Functions
; -----------------------------------------------------------------------------------------

; Automatically configure initDownClicks and yLvlInit settings.
configurationAssistant() {
	global

	if (irisLevel < 145) {
		gui.playWarningSound()
		msgbox,,% script,% "Your Iris do not fulfill the minimum level requirement of 145 or higher!"
		exit
	}

	if (irisThreshold(2010)) { ; Astraea
		initDownClicks := [6,5,6,5,6,3]
		yLvlInit := 241
	} else if (irisThreshold(1760)) { ; Alabaster
		; [6,6,6,5,6,3], 227
		; [6,5,6,6,6,3], 260
		; [5,6,6,5,6,3], 293
		initDownClicks := [6,6,6,5,6,3]
		yLvlInit := 227
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
		gui.playNotificationSound()
		msgbox,,% script,% "Your Iris is " . levels . " levels below the recommended ""optimal level - 1001"" rule."
	}
}

; Check if Iris is within a certain threshold that can cause a toggling behaviour between different settings
irisThreshold(lvl) {
	global
	local upperThreshold := lvl + 19
	local lowerThreshold := lvl - 20
	if (irisLevel >= lowerThreshold and irisLevel < upperThreshold) {
		gui.playWarningSound()
		msgbox,,% script,% "Threshold proximity warning! You should level up your Iris to " . upperThreshold . " or higher."
	}
	return irisLevel > lvl
}

; Level up and upgrade all heroes
initRun() {
	global

	bot_lib.switchToCombatTab()
	bot_lib.clickPos(xHero, yHero) ; prevent fails

	bot_lib.upgrade(initDownClicks[1],2,,2) ; cid --> brittany
	bot_lib.upgrade(initDownClicks[2]) ; fisherman --> leon
	bot_lib.upgrade(initDownClicks[3]) ; seer --> mercedes
	bot_lib.upgrade(initDownClicks[4],,,,2) ; bobby --> king
	bot_lib.upgrade(initDownClicks[5],2,,,2) ; ice --> amenhotep
	bot_lib.upgrade(initDownClicks[6],,,2) ; beastlord --> shinatobe
	bot_lib.upgrade(0,,,,,true) ; grant & frostleaf

	bot_lib.scrollToBottom()
	bot_lib.buyAvailableUpgrades()
}

upgrade(times, cc1:=1, cc2:=1, cc3:=1, cc4:=1, skip:=false) {
	global

	if (!skip) {
		bot_lib.ctrlClick(xLvl, yLvlInit, cc1)
		bot_lib.ctrlClick(xLvl, yLvlInit + oLvl, cc2)
	}
	bot_lib.ctrlClick(xLvl, yLvlInit + oLvl*2, cc3)
	bot_lib.ctrlClick(xLvl, yLvlInit + oLvl*3, cc4)

	bot_lib.scrollDown(times)
}

loopSpeedRun() {
	global

	mode := hybridMode ? "hybrid" : "speed"
	gui.showSplashAlways("Starting " . mode . " runs...")
	loop
	{
		bot_lib.getClickable()
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
		handleScheduledStop()
		handleScheduledReload(true)
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

	local lvlAdjustment := bot_lib.round(firstStintAdjustment * lMax / tMax)
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
		firstStintTime := bot_lib.ceil(lvls * tMax / lMax)
		stints += 1
	}

	local srDuration := speedRunTime * 60
	local totalClickDelay := bot_lib.ceil(srDuration / lvlUpDelay * zzz / 1000 + nextHeroDelay * stints)
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
		output .= s . "srDuration = " . bot_lib.formatSeconds(srDuration) . nl
		output .= s . "firstStintButton = " . firstStintButton . nl
		output .= s . "firstStintTime = " . bot_lib.formatSeconds(firstStintTime) . nl
		output .= s . "midStintTime = " . bot_lib.formatSeconds(midStintTime) . nl
		output .= s . "lastStintTime = " . bot_lib.formatSeconds(lastStintTime) . nl
		output .= s . "totalClickDelay = " . bot_lib.formatSeconds(totalClickDelay) . nl

		clipboard := % output
		msgbox % output
		return
	}

	gui.showSplash("Starting speed run...")

	if (irisLevel < 2 * lMax + 10) ; Iris high enough to start with a ranger?
	{
		bot_lib.switchToCombatTab()
		bot_lib.scrollDown(initDownClicks[1])
		bot_lib.toggleMode() ; toggle to progression mode
		bot_lib.lvlUp(firstStintTime, 0, 3, ++stint, stints) ; nope, let's bridge with Samurai
		bot_lib.scrollToBottom()
	} else {
		bot_lib.scrollToBottom()
		bot_lib.toggleMode() ; toggle to progression mode
		if (firstStintTime > 0) {
			bot_lib.lvlUp(firstStintTime, 1, firstStintButton, ++stint, stints)
			bot_lib.scrollWayDown(3)
		}
	}
	if (midStintTime > 0) {
		bot_lib.lvlUp(midStintTime, 1, 2, ++stint, stints)
		bot_lib.scrollWayDown(2)
	}
	bot_lib.lvlUp(lastStintTime, 1, lastStintButton, ++stint, stints)

	gui.showSplash("Speed run completed.")
}

deepRun() {
	global

	exitDRThread := false

	local drDuration := deepRunTime * 60
	local button := gildedRanger = 9 ? 3 : 2 ; special case for Astraea
	local y := yLvl + oLvl * (button - 1)

	gui.showSplash("Starting deep run...")

	bot_lib.startMouseMonitoring()
	bot_lib.startProgress("Deep Run Progress", 0, drDuration // barUpdateDelay)
	bot_lib.monsterClickerOn()

	local comboDelay := deepRunCombo[1]
	local comboIndex := 2
	local stopHuntIndex := drDuration - stopHuntThreshold * 60
	local t := 0

	loop % drDuration
	{
		if (exitDRThread) {
			bot_lib.monsterClickerOff()
			bot_lib.stopProgress()
			bot_lib.stopMouseMonitoring()
			gui.showSplashAlways("Deep run aborted!")
			exit
		}
		if (deepRunClicks) {
			bot_lib.clickPos(xMonster, yMonster)
		}
		if (mod(t, comboDelay) = 0) {
			bot_lib.activateSkills(deepRunCombo[comboIndex])
			comboIndex := comboIndex < deepRunCombo.bot_lib.MaxIndex() ? comboIndex+1 : 2
		}
		if (mod(t, lvlUpDelay) = 0) {
			bot_lib.ctrlClick(xLvl, y, 1, 0)
		}
		if (mod(t, clickableHuntDelay) = 0 and t < stopHuntIndex) {
			bot_lib.getClickable()
		}
		t += 1
		bot_lib.updateProgress(t // barUpdateDelay, drDuration - t)
		sleep 1000
	}

	bot_lib.monsterClickerOff()
	bot_lib.stopProgress()
	bot_lib.stopMouseMonitoring()

	gui.showSplash("Deep run ended.")
	sleep 1000
}

monsterClickerOn(isActive:=true) {
	global
	if (deepRunClicks) {
		send {shift down}{f1 down}{f1 up}{shift up}
	}
}

monsterClickerPause() {
	global
	if (deepRunClicks) {
		send {shift down}{f2 down}{f2 up}{shift up}
	}
}

monsterClickerOff() {
	global
	if (deepRunClicks) {
		send {shift down}{f3 down}{f3 up}{shift up}
	}
}

lvlUp(seconds, buyUpgrades, button, stint, stints) {
	global

	exitThread := false
	local y := yLvl + oLvl * (button - 1)
	local title := "Speed Run Progress (" . stint . "/" . stints . ")"

	bot_lib.startMouseMonitoring()
	bot_lib.startProgress(title, 0, seconds // barUpdateDelay)

	if (buyUpgrades) {
		bot_lib.ctrlClick(xLvl, y)
		bot_lib.buyAvailableUpgrades()
	}
	bot_lib.maxClick(xLvl, y)

	local t := 0

	loop % seconds
	{
		if (exitThread) {
			bot_lib.stopProgress()
			bot_lib.stopMouseMonitoring()
			gui.showSplashAlways("Speed run aborted!")
			exit
		}
		if (mod(t, lvlUpDelay) = 0) {
			bot_lib.ctrlClick(xLvl, y)
		}
		t += 1
		bot_lib.updateProgress(t // barUpdateDelay, seconds - t)
		sleep 1000
	}
	bot_lib.stopProgress()
	bot_lib.stopMouseMonitoring()
}

openSaveDialog() {
	global

	bot_lib.clickPos(xSettings, ySettings)
	sleep % zzz * 3
	bot_lib.clickPos(xSave, ySave)
	sleep % zzz * 4
}

save() {
	global
	local fileName := "ch" . A_NowUTC . ".txt"
	local newFileName := ""

	bot_lib.openSaveDialog()

	; Change the file name...
	if (saveMode = 1) {
		ControlSetText, Edit1, %fileName%, ahk_class %dialogBoxClass%
	} else {
		ControlSend, Edit1, %fileName%, ahk_class %dialogBoxClass%
	}
	sleep % zzz * 4
	; ... and double-check that it's correct
	ControlGetText, newFileName, Edit1, ahk_class %dialogBoxClass%
	if (newFileName = fileName) {
		ControlClick, %saveButtonClassNN%, ahk_class %dialogBoxClass%,,,, NA
	} else {
		ControlSend,, {esc}, ahk_class %dialogBoxClass%
	}

	sleep % zzz * 3
	bot_lib.clickPos(xSettingsClose, ySettingsClose)
}

openAncientsOptimizer() {
	global

	local templateFileName := "system\ancients_optimizer_loader.html"
	FileRead, loaderSourceTemplate, %templateFileName%

	local loaderFileName := A_Temp . "\ch_ao_" . A_NowUTC . ".html"
	local file = bot_lib.FileOpen(loaderFileName, "w")
	if !bot_lib.IsObject(file)
	{
		MsgBox % "Can't open " . loaderFileName . " for writing."
		return
	}

	bot_lib.openSaveDialog()

	; Abort saving. Clipboard is good enough
	ControlSend,, {esc}, ahk_class %dialogBoxClass%

	sleep % zzz * 3
	bot_lib.clickPos(xSettingsClose, ySettingsClose)

	; Write loader file
	local loaderSource := bot_lib.StrReplace(loaderSourceTemplate, "#####SAVEGAME#####", Clipboard)

    file.bot_lib.write(loaderSource)
    file.bot_lib.Close()

    Run, %loaderFileName%
    sleep % zzz * 5
    FileDelete, %loaderFileName%
}

ascend(autoYes:=false) {
	global
	exitThread := false
	local extraClicks := 6
	local y := yAsc - extraClicks * buttonSize

	if (autoYes) {
		if (autoAscendDelay > 0) {
			gui.showWarningSplash(autoAscendDelay . " seconds till ASCENSION! (Abort with Alt+Pause)", autoAscendDelay)
			if (exitThread) {
				exitThread := false
				gui.showSplashAlways("Ascension aborted!")
				exit
			}
		}
	} else {
		gui.playWarningSound()
		msgbox, 260,% script,Salvage Junk Pile & Ascend? ; default no
		ifmsgbox no
			exit
	}

	bot_lib.salvageJunkPile() ; must salvage junk relics before ascending

	bot_lib.switchToCombatTab()
	bot_lib.scrollDown(ascDownClicks)
	sleep % zzz * 2

	; Scrolling is not an exact science, hence we click above, center and below
	loop % 2 * extraClicks + 1
	{
		bot_lib.clickPos(xAsc, y)
		y += buttonSize
	}
	sleep % zzz * 4
	bot_lib.clickPos(xYes, yYes)
	sleep % zzz * 2
}

salvageJunkPile() {
	global

	bot_lib.switchToRelicTab()

	if (autoAscend) {
		if (screenShotRelics || displayRelicsDuration > 0) {
			bot_lib.clickPos(xRelic, yRelic) ; focus
		}

		if (screenShotRelics) {
			bot_lib.screenShot()
		}

		if (displayRelicsDuration > 0) {
			gui.showWarningSplash("Salvaging junk in " . displayRelicsDuration . " seconds! (Abort with Alt+Pause)", displayRelicsDuration)
			if (exitThread) {
				exitThread := false
				gui.showSplashAlways("Salvage aborted!")
				exit
			}
		}

		if (screenShotRelics || displayRelicsDuration > 0) {
			bot_lib.clickPos(xRelic+100, yRelic) ; remove focus
		}
	}

	bot_lib.clickPos(xSalvageJunk, ySalvageJunk)
	sleep % zzz * 4
	bot_lib.clickPos(xDestroyYes, yDestroyYes)
	sleep % zzz * 2
}

buyAvailableUpgrades() {
	global
	bot_lib.clickPos(xBuy, yBuy)
	sleep % zzz * 3
}

; Move "gildCount" gilds to given ranger
regild(ranger, gildCount) {
	global
	bot_lib.monsterClickerPause()
	bot_lib.switchToCombatTab()
	bot_lib.scrollToBottom()

	bot_lib.clickPos(xGilded, yGilded)
	sleep % zzz * 2

	ControlSend,, {shift down}, % winName
	bot_lib.clickPos(rangerPositions[ranger].x, rangerPositions[ranger].y, gildCount)
	sleep % 1000 * gildCount/100*5
	ControlSend,, {shift up}, % winName

	bot_lib.clickPos(xGildedClose, yGildedClose)
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
	bot_lib.clickPos(xHero, yHero) ; prevent fails
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
		gui.showSplashAlways("Reloading bot...", 1)

		autorun_flag := autorun = true ? "/autorun" : ""
		Run "%A_AhkPath%" /restart "%A_ScriptFullPath%" %autorun_flag%
	}
}

handleScheduledStop() {
	global
	if(scheduleStop) {
		gui.showSplashAlways("Scheduled stop. Exiting...")
		scheduleStop := false
		exit
	}
}

handleAutorun() {
	global
	param_1 = %1%
	if(param_1 = "/autorun") {
		gui.showSplash("Autorun speedruns...", 1)
		bot_lib.loopSpeedrun()
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

		xL := bot_lib.getAdjustedX(xSafetyZoneL)
		xR := bot_lib.getAdjustedX(xSafetyZoneR)
		yT := bot_lib.getAdjustedY(ySafetyZoneT)
		yB := bot_lib.getAdjustedY(ySafetyZoneB)

		if (x > xL && x < xR && y > yT && y < yB) {
			gui.playNotificationSound()
			msgbox,,% script,Click safety pause engaged. Continue?
		}
	}
return
