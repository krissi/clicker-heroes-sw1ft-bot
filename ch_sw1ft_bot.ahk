; -----------------------------------------------------------------------------------------
; Clicker Heroes Sw1ft Bot
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Persistent
#NoEnv
#InstallKeybdHook

SetTitleMatchMode, 3 ; Steam [3] or browser [regex] version?

#Include <Bot>

SetControlDelay, -1

scriptName=CH Sw1ft Bot
scriptVersion=2.41

script := scriptName . " v" . scriptVersion

scheduleReload := false
scheduleStop := false

; -----------------------------------------------------------------------------------------


bot := new Bot(script)

if (deepRunClicks) {
	Run, "%A_ScriptDir%\monster_clicker.ahk",, UseErrorLevel
	if (ErrorLevel != 0) {
		gui.playWarningSound()
    	msgbox,,% script,% "Failed to auto-start monster_clicker.ahk (system error code = " . A_LastError . ")!"
	}
}

bot.handleAutorun()

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
	bot.game.scrollToBottom()
return

^!F2::
	bot.game.switchToRelicTab()
	bot.game.switchToCombatTab()
return

; Alt+F1 to F4 are here to test the individual parts of the full speed run loop

!F1::
	bot.game.getClickable()
return

!F2::
	initRun()
return

!F3::
	bot.switchToCombatTab()
	speedRun()
return

!F4::
	bot.ascend(autoAscend)
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
	bot.toggleFlag("scheduleStop", scheduleStop)
return

; Deep run
; Use (after a speed run)
^F2::
	deepRun()
return

; Open the Ancients Optimizer and auto-import game save data
^F5::
	bot.openAncientsOptimizer()
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
	bot.regild(reGildRanger, reGildCount) ; will pause the monster clicker if running
return

; Autosave the game
^F11::
	critical
	bot.monsterClickerPause()
	bot.save()
return

; Toggle boolean (true/false) flags

+^F1::
	bot.toggleFlag("autoAscend", autoAscend)
return

+^F2::
	bot.toggleFlag("screenShotRelics", screenShotRelics)
return

+^F5::
	bot.toggleFlag("scheduleReload", scheduleReload)
return

+^F6::
	bot.toggleFlag("playNotificationSounds", playNotificationSounds)
return

+^F7::
	bot.toggleFlag("playWarningSounds", playWarningSounds)
return

+^F8::
	bot.toggleFlag("showSplashTexts", showSplashTexts)
return

+^F11::
	bot.toggleFlag("saveBeforeAscending", saveBeforeAscending)
return

+^F12::
	bot.toggleFlag("debug", debug)
return

; -----------------------------------------------------------------------------------------
; -- Functions
; -----------------------------------------------------------------------------------------

; Level up and upgrade all heroes
initRun() {
	global

	bot.switchToCombatTab()
	bot.clickPos(xHero, yHero) ; prevent fails

	bot.upgrade(initDownClicks[1],2,,2) ; cid --> brittany
	bot.upgrade(initDownClicks[2]) ; fisherman --> leon
	bot.upgrade(initDownClicks[3]) ; seer --> mercedes
	bot.upgrade(initDownClicks[4],,,,2) ; bobby --> king
	bot.upgrade(initDownClicks[5],2,,,2) ; ice --> amenhotep
	bot.upgrade(initDownClicks[6],,,2) ; beastlord --> shinatobe
	bot.upgrade(0,,,,,true) ; grant & frostleaf

	bot.scrollToBottom()
	bot.buyAvailableUpgrades()
}

upgrade(times, cc1:=1, cc2:=1, cc3:=1, cc4:=1, skip:=false) {
	global

	if (!skip) {
		bot.ctrlClick(xLvl, yLvlInit, cc1)
		bot.ctrlClick(xLvl, yLvlInit + oLvl, cc2)
	}
	bot.ctrlClick(xLvl, yLvlInit + oLvl*2, cc3)
	bot.ctrlClick(xLvl, yLvlInit + oLvl*3, cc4)

	bot.scrollDown(times)
}

loopSpeedRun() {
	global

	mode := hybridMode ? "hybrid" : "speed"
	gui.showSplashAlways("Starting " . mode . " runs...")
	loop
	{
		bot.getClickable()
		sleep % coinPickUpDelay * 1000
		initRun()
		if (activateSkillsAtStart) {
			bot.activateSkills(speedRunStartCombo[2])
		}
		speedRun()
		if (hybridMode) {
			deepRun()
		}
		if (saveBeforeAscending) {
			bot.save()
		}
		bot.ascend(autoAscend)
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

	local lvlAdjustment := bot.round(firstStintAdjustment * lMax / tMax)
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
		firstStintTime := bot.ceil(lvls * tMax / lMax)
		stints += 1
	}

	local srDuration := speedRunTime * 60
	local totalClickDelay := bot.ceil(srDuration / lvlUpDelay * zzz / 1000 + nextHeroDelay * stints)
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
		output .= s . "srDuration = " . bot.formatSeconds(srDuration) . nl
		output .= s . "firstStintButton = " . firstStintButton . nl
		output .= s . "firstStintTime = " . bot.formatSeconds(firstStintTime) . nl
		output .= s . "midStintTime = " . bot.formatSeconds(midStintTime) . nl
		output .= s . "lastStintTime = " . bot.formatSeconds(lastStintTime) . nl
		output .= s . "totalClickDelay = " . bot.formatSeconds(totalClickDelay) . nl

		clipboard := % output
		msgbox % output
		return
	}

	gui.showSplash("Starting speed run...")

	if (irisLevel < 2 * lMax + 10) ; Iris high enough to start with a ranger?
	{
		bot.switchToCombatTab()
		bot.scrollDown(initDownClicks[1])
		bot.toggleMode() ; toggle to progression mode
		bot.lvlUp(firstStintTime, 0, 3, ++stint, stints) ; nope, let's bridge with Samurai
		bot.scrollToBottom()
	} else {
		bot.scrollToBottom()
		bot.toggleMode() ; toggle to progression mode
		if (firstStintTime > 0) {
			bot.lvlUp(firstStintTime, 1, firstStintButton, ++stint, stints)
			bot.scrollWayDown(3)
		}
	}
	if (midStintTime > 0) {
		bot.lvlUp(midStintTime, 1, 2, ++stint, stints)
		bot.scrollWayDown(2)
	}
	bot.lvlUp(lastStintTime, 1, lastStintButton, ++stint, stints)

	gui.showSplash("Speed run completed.")
}

deepRun() {
	global

	exitDRThread := false

	local drDuration := deepRunTime * 60
	local button := gildedRanger = 9 ? 3 : 2 ; special case for Astraea
	local y := yLvl + oLvl * (button - 1)

	gui.showSplash("Starting deep run...")

	bot.startMouseMonitoring()
	bot.startProgress("Deep Run Progress", 0, drDuration // barUpdateDelay)
	bot.monsterClickerOn()

	local comboDelay := deepRunCombo[1]
	local comboIndex := 2
	local stopHuntIndex := drDuration - stopHuntThreshold * 60
	local t := 0

	loop % drDuration
	{
		if (exitDRThread) {
			bot.monsterClickerOff()
			bot.stopProgress()
			bot.stopMouseMonitoring()
			gui.showSplashAlways("Deep run aborted!")
			exit
		}
		if (deepRunClicks) {
			bot.clickPos(xMonster, yMonster)
		}
		if (mod(t, comboDelay) = 0) {
			bot.activateSkills(deepRunCombo[comboIndex])
			comboIndex := comboIndex < deepRunCombo.bot.MaxIndex() ? comboIndex+1 : 2
		}
		if (mod(t, lvlUpDelay) = 0) {
			bot.ctrlClick(xLvl, y, 1, 0)
		}
		if (mod(t, clickableHuntDelay) = 0 and t < stopHuntIndex) {
			bot.getClickable()
		}
		t += 1
		bot.updateProgress(t // barUpdateDelay, drDuration - t)
		sleep 1000
	}

	bot.monsterClickerOff()
	bot.stopProgress()
	bot.stopMouseMonitoring()

	gui.showSplash("Deep run ended.")
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
		bot.gui.showSplashAlways("Reloading bot...", 1)

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
		bot.loopSpeedrun()
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

		xL := bot.getAdjustedX(xSafetyZoneL)
		xR := bot.getAdjustedX(xSafetyZoneR)
		yT := bot.getAdjustedY(ySafetyZoneT)
		yB := bot.getAdjustedY(ySafetyZoneB)

		if (x > xL && x < xR && y > yT && y < yB) {
			gui.playNotificationSound()
			msgbox,,% script,Click safety pause engaged. Continue?
		}
	}
return
