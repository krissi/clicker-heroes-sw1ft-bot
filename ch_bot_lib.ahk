; -----------------------------------------------------------------------------------------
; Clicker Heroes Sw1ft Bot Lib
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Include <Configuration>
#Include <Game>

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
	
	__New(script_name) {
		configuration := new Configuration()

		this.gui := new Gui(script_name, configuration.gui)
		this.game := new Game(this.gui)
	}

	; -----------------------------------------------------------------------------------------
	; -- Functions
	; -----------------------------------------------------------------------------------------



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


}

; -----------------------------------------------------------------------------------------

; Load system default settings
#Include system\ch_bot_lib_default_settings.ahk

IfNotExist, ch_bot_lib_settings.ahk
{
	FileCopy, system\ch_bot_lib_default_settings.ahk, ch_bot_lib_settings.ahk
}

#Include *i ch_bot_lib_settings.ahk