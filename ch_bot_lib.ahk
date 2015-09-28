; -----------------------------------------------------------------------------------------
; Clicker Heroes Sw1ft Bot Lib
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Include <Client>

class ChBotLib {
	libVersion := 1.32

	;global ProgressBar, ProgressBarTime ; progress bar controls

	exitThread := false
	exitDRThread := false

	zzz := 200 ; sleep delay (in ms) after a click
	lvlUpDelay := 5 ; time (in seconds) between lvl up clicks
	barUpdateDelay := 30 ; time (in seconds) between progress bar updates
	coinPickUpDelay := 6 ; time (in seconds) needed to pick up all coins from a clickable
	nextHeroDelay := 6 ; extra gold farm delay (in seconds) between heroes

	dialogBoxClass := "#32770"

	; -- Coordinates --------------------------------------------------------------------------

	; Top LVL UP button when scrolled to the bottom
	xLvl := 100
	yLvl := 285
	oLvl := 107 ; offset to next button

	; Ascension button
	xAsc := 310
	yAsc := 434

	buttonSize := 35

	; Ascend Yes button
	xYes := 500
	yYes := 445

	xCombatTab := 50
	yCombatTab := 130

	xAncientTab := 297
	yAncientTab := 130

	xRelicTab := 380
	yRelicTab := 130

	xRelic := 103
	yRelic := 380

	xSalvageJunk := 280
	ySalvageJunk := 470

	xDestroyYes := 500
	yDestroyYes := 430

	; Scrollbar
	xScroll := 554
	yUp := 219
	yDown := 653
	top2BottomClicks := 46

	xGilded := 95
	yGilded := 582

	xGildedClose := 1090
	yGildedClose := 54

	rangers := ["Dread Knight", "Atlas", "Terra", "Phthalo", "Banana", "Lilin", "Cadmia", "Alabaster", "Astraea"]

	rangerPositions() {
		rangerPositions := {}
		rangerPositions[1] := {x:180, y:435}
		rangerPositions[2] := {x:380, y:435}
		rangerPositions[3] := {x:580, y:435}
		rangerPositions[4] := {x:780, y:435}
		rangerPositions[5] := {x:980, y:435}
		rangerPositions[6] := {x:180, y:495}
		rangerPositions[7] := {x:380, y:495}
		rangerPositions[8] := {x:580, y:495}
		rangerPositions[9] := {x:780, y:495}

		return rangerPositions
	}

	; Buy Available Upgrades button
	xBuy := 300
	yBuy := 582

	xHero := 474
	yHero := 227

	xMonster := 920
	yMonster := 164

	; Tab safety zone (script will pause when entering)
	xSafetyZoneL := 8
	xSafetyZoneR := 505
	ySafetyZoneT := 104
	ySafetyZoneB := 154

	; The wrench
	xSettings := 1121
	ySettings := 52

	xSettingsClose := 961
	ySettingsClose := 52

	xSave := 286
	ySave := 112
	
	__New(gui) {
		this.gui := gui
		this.client := new Client(this.gui)
	}

	; -----------------------------------------------------------------------------------------
	; -- Functions
	; -----------------------------------------------------------------------------------------

	; No smart image recognition, so we click'em all!
	getClickable() {
		global
		; Break idle on purpose to get the same amount of gold every run
		loop 3 {
			this.clickPos(xMonster, yMonster)
		}
		this.clickPos(524, 487)
		this.clickPos(747, 431)
		this.clickPos(760, 380)
		this.clickPos(873, 512)
		this.clickPos(1005, 453)
		this.clickPos(1053, 443)
	}

	switchToCombatTab() {
		global
		this.clickPos(this.xCombatTab, this.yCombatTab)
		sleep % this.zzz * 4
	}

	switchToAncientTab() {
		global
		this.clickPos(this.xAncientTab, this.yAncientTab)
		sleep % this.zzz * 2
	}

	switchToRelicTab() {
		global
		this.clickPos(this.xRelicTab, this.yRelicTab)
		sleep % this.zzz * 2
	}

	scrollToTop() {
		global
		this.scrollUp(this.top2BottomClicks)
		sleep 1000
	}

	scrollToBottom() {
		global
		this.scrollDown(this.top2BottomClicks)
		sleep 1000
	}

	scrollUp(clickCount:=1) {
		global
		this.clickPos(this.xScroll, this.yUp, clickCount)
		sleep % zzz * 2
	}

	scrollDown(clickCount:=1) {
		global
		this.clickPos(this.xScroll, this.yDown, clickCount)
		sleep % this.zzz * 2
	}

	; Scroll down fix when at bottom and scroll bar don't update correctly
	scrollWayDown(clickCount:=1) {
		global
		this.scrollUp()
		this.scrollDown(clickCount + 1)
		sleep % this.nextHeroDelay * 1000
	}

	maxClick(xCoord, yCoord, clickCount:=1) {
		global
		ControlSend,, {shift down}{q down}, % this.winName
		this.clickPos(xCoord, yCoord, clickCount)
		ControlSend,, {q up}{shift up}, % this.winName
		sleep % zzz
	}

	ctrlClick(xCoord, yCoord, clickCount:=1, sleepSome:=1) {
		global
		ControlSend,, {ctrl down}, % this.winName
		this.clickPos(xCoord, yCoord, clickCount)
		ControlSend,, {ctrl up}, % this.winName
		if (sleepSome) {
			sleep % zzz
		}
	}

	clickPos(xCoord, yCoord, clickCount:=1) {
		this.client.clickPos(xCoord, yCoord, clickCount)
	}

	startProgress(title, min:=0, max:=100) {
		global
		if (showProgressBar) {
			gui, new
			gui, margin, 0, 0
			gui, font, s18
			gui, add, progress,% "w" wProgressBar " h28 range" min "-" max " -smooth vProgressBar"
			gui, add, text, w92 vProgressBarTime x+2
			gui, show,% "na x" xProgressBar " y" yProgressBar,% script " - " title
		}
	}

	updateProgress(position, remainingTime) {
		if (showProgressBar) {
			guicontrol,, ProgressBar,% position
			guicontrol,, ProgressBarTime,% this.formatSeconds(remainingTime)
		}
	}

	stopProgress() {
		if (showProgressBar) {
			gui, destroy
		}
	}

	formatSeconds(s) {
		time := 19990101 ; *Midnight* of an arbitrary date.
		time += %s%, seconds
		FormatTime, timeStr, %time%, HH:mm:ss
		return timeStr
	}

	secondsSince(startTime) {
		return (A_TickCount - startTime) // 1000
	}

	toggleFlag(flagName, byref flag) {
		flag := !flag
		flagValue := flag ? "On" : "Off"
		this.gui.showSplashAlways("Toggled " . flagName . " " . flagValue)
	}

	screenShot() {
		global
		if (A_TitleMatchMode = 3) { ; Steam only
			WinGet, activeWinId, ID, A ; remember current active window...
			WinActivate, % this.winName
			send {f12 down}{f12 up} ; screenshot
			sleep % zzz
			WinActivate, ahk_id %activeWinId% ; ... and restore focus back
		}
	}
}

; -----------------------------------------------------------------------------------------

; Load system default settings
#Include system\ch_bot_lib_default_settings.ahk

IfNotExist, ch_bot_lib_settings.ahk
{
	FileCopy, system\ch_bot_lib_default_settings.ahk, ch_bot_lib_settings.ahk
}

#Include *i ch_bot_lib_settings.ahk