; -----------------------------------------------------------------------------------------
; Clicker Heroes Sw1ft Bot Lib
; by Sw1ftb
; -----------------------------------------------------------------------------------------

#Include <Configuration>
#Include <Game>
#Include <Gui>

class Bot {
	;global ProgressBar, ProgressBarTime ; progress bar controls
	
	
	; -----------------------------------------------------------------------------------------
	; -- Mandatory Configuration
	; -----------------------------------------------------------------------------------------

	browserTopMargin := 230

	; Note: There are currently issues with both Chrome and the new Windows 10 browser Edge!

	; -----------------------------------------------------------------------------------------
	; -- Optional Settings
	; -----------------------------------------------------------------------------------------

	fullScreenOption := false ; Steam borderless fullscreen option

	; Note: You need to turn on the "Full Screen" option in Clicker Heroes for this option to work.


	; -----------------------------------------------------------------------------------------
	; -- Mandatory Configuration
	; -----------------------------------------------------------------------------------------

	irisLevel := 1029 ; try to keep your Iris within 1001 levels of your optimal zone

	; Clicker Heroes Ancients Optimizer @ http://s3-us-west-2.amazonaws.com/clickerheroes/ancientssoul.html

	; Use the optimizer to set the optimal level and time:
	optimalLevel := 2000
	speedRunTime := 29 ; minutes (usually between 28 and 30 minutes)

	; In the Heroes tab you can verify that you are using the optimal ranger.
	gildedRanger := 6 ; the number of your main guilded ranger
	; 1:Dread Knight, 2:Atlas, 3:Terra, 4:Phthalo, 5:Banana, 6:Lilin, 7:Cadmia, 8:Alabaster, 9:Astraea

	; -----------------------------------------------------------------------------------------
	; -- Optional Settings
	; -----------------------------------------------------------------------------------------

	; -- Speed run ----------------------------------------------------------------------------

	; If the script starts on the 2nd ranger too early (before lvl 100) or too late (after lvl 200), adjust this setting.
	firstStintAdjustment := 0 ; Add or remove time (in seconds) to or from the first hero.

	activateSkillsAtStart := true ; usually needed in the late game to get going after ascending

	hybridMode := false ; chain a deep run when the speed run finish

	ascDownClicks := 26 ; # of down clicks needed to get the ascension button center:ish (after a full speed run)




	debug := false ; when set to "true", you can press Alt+F3 to show some debug info (also copied into your clipboard)

	; -- Deep run -----------------------------------------------------------------------------

	deepRunTime := 60 ; minutes

	clickableHuntDelay := 15 ; hunt for a clickable every 15s
	stopHuntThreshold := 30 ; stop hunt when this many minutes remain of a deep run

	; Number of gilds to move over at a time
	reGildCount := 100 ; don't set this higher than 100 if you plan on moving gilds during a deep run
	reGildRanger := gildedRanger + 1 

	deepRunClicks := true ; click the monster during a deep run?

	; -- Init run -----------------------------------------------------------------------------

	; A list of clicks needed to scroll down 4 heroes at a time, starting from the top.
	initDownClicks := [0,0,0,0,0,0]

	; This y coordinate is supposed to keep itself inside the top lvl up button when scrolling down according to the above "clicking pattern".
	yLvlInit := 000

	; Manual configuration (if not using the assistant):
	; 1. Ascend with a "clickable" available.
	; 2. Click Alt+F1 (the script should pick up the clickable).
	; 3. Scroll down to the bottom. What ranger is last?
	; 4. From the list below, pick the matching settings:

	; Astraea      [6,5,6,5,6,3], 241 (Iris > 2010)
	; Alabaster    [6,6,6,5,6,3], 227 (Iris > 1760)
	; Alabaster    [6,5,6,6,6,3], 260 (Iris > 1760)
	; Alabaster    [5,6,6,5,6,3], 293 (Iris > 1760)
	; Cadmia       [6,6,6,6,6,3], 240 (Iris > 1510)
	; Lilin        [6,6,6,6,6,3], 285 (Iris > 1260)
	; Banana       [6,7,6,7,6,3], 240 (Iris > 1010)
	; Phthalo      [6,7,7,6,7,3], 273 (Iris > 760)
	; Terra        [7,7,7,7,7,3], 240 (Iris > 510)
	; Atlas        [7,7,7,8,7,3], 273 (Iris > 260)
	; Dread Knight [7,8,7,8,7,4], 257

	; E.g. if Phthalo is last, you set initDownClicks to [6,7,7,6,7,3] and yLvlInit to 273.
	; In this case your Iris level should be somewhere between 760 and 1010.

	; 5. Now click Alt+F2 (the script should level up and upgrade all heroes from Cid to Frostleaf).

	; If some heroes where missed, make sure you have picked the suggested setting for your Iris level.
	; If you are close to one of these Iris irisThresholds, you should move above it with some margin. 
	; E.g if your Iris is at 489, you should level it to at least 529, pick the setting for Terra,
	; reload the script (Alt+F5), ascend with a clickable and try Alt+F2 again.

	; -- Look & Feel --------------------------------------------------------------------------

	; true or false
	showProgressBar := true

	; Progress bar width and position
	wProgressBar := 325
	xProgressBar := 20
	yProgressBar := 20

	; If you run with a dual/tripple monitor setup, you can move windows
	; right or left by adding or subtracting A_ScreenWidth from the x-parameters.

	; Left monitor example:
	; xSplash := A_ScreenWidth // 2 - wSplash // 2 - A_ScreenWidth
	; xProgressBar := 20 - A_ScreenWidth

	; -- Skill Combos -------------------------------------------------------------------------

	; 1 - Clickstorm, 2 - Powersurge, 3 - Lucky Strikes, 4 - Metal Detector, 5 - Golden Clicks
	; 6 - The Dark Ritual, 7 - Super Clicks, 8 - Energize, 9 - Reload

	; Test with tools/combo_tester.ahk

	comboStart := [15*60, "8-1-2-3-4-5-7-6-9"]
	comboEDR := [2.5*60, "2-3-4-5-7-8-6-9", "", "", "", "", "", "8-9-2-3-4-5-7", "2", "2", "2-3-4", "2", "2"]
	comboEGolden := [2.5*60, "8-5-2-3-4-7-6-9", "2", "2", "2-3-4", "2", "2"] ; energize 3 (dmg) or 5 (gold)
	comboGoldenLuck := [2.5*60, "6-2-3-5-8-9", "2-3-4-5-7", "2", "2", "2-3-4", "2", "2"]

	speedRunStartCombo := comboStart
	deepRunCombo := comboGoldenLuck


	exitThread := false
	exitDRThread := false

	lvlUpDelay := 5 ; time (in seconds) between lvl up clicks
	barUpdateDelay := 30 ; time (in seconds) between progress bar updates
	coinPickUpDelay := 6 ; time (in seconds) needed to pick up all coins from a clickable
	nextHeroDelay := 6 ; extra gold farm delay (in seconds) between heroes





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

	__New(script_name) {
		this.tempFiles := []

		configuration := new Configuration()

		this.configuration := configuration.bot
		this.gui := new Gui(script_name, configuration)
		this.game := new Game(this.gui, configuration)
		
		if (this.configuration.useConfigurationAssistant()) {
			this.configurationAssistant()
		}
	}

	__Delete() {
		this.cleanupTempfiles()
	}

	; ===================================================================
	; ======================== Public Interface =========================
	; ===================================================================
	saveGame() {
		fileName := "savegames\ch" . A_NowUTC . ".txt"
		
		savegame :=	this.getSavegame()
		this.writeFile(fileName, savegame)
	}

	openAncientsOptimizer() {
		templateFileName := "system\ancients_optimizer_loader.html"
		FileRead, loaderSourceTemplate, %templateFileName%

		loaderFileName := A_Temp . "\ch_ao_" . A_NowUTC . ".html"

		savegame :=	this.getSavegame()
		loaderSource := StrReplace(loaderSourceTemplate, "#####SAVEGAME#####", savegame)

		this.tempFiles.Push(loaderFileName)
		this.writeFile(loaderFileName, loaderSource)

		Run, %loaderFileName%
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
		this.game.switchToRelicTab()

		focusRelic := this.configuration.screenShotRelics() || this.configuration.displayRelicsDuration() > 0
		if (focusRelic) {
			this.game.clickRelic()
		}

		if (this.configuration.screenShotRelics()) {
			this.game.screenShot()
		}

		if (! this.gui.userDoesAllow("Salvaging junk in " . this.configuration.displayRelicsDuration() . " seconds! (Abort with Alt+Pause)", this.configuration.displayRelicsDuration())) {
			this.gui.showSplashAlways("Salvage aborted!")
			exit
		}

		dialog := this.game.openSalvageJunkPileDialog()
		this.game.delay(4)

		dialog.confirm_destroy()
		this.game.delay(2)
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

	toggleFlag(flagName, byref flag) {
		flag := !flag
		flagValue := flag ? "On" : "Off"
		this.gui.showSplashAlways("Toggled " . flagName . " " . flagValue)
	}

	; ===================================================================
	; ======================== Private Interface ========================
	; ===================================================================

	; Automatically configure initDownClicks and yLvlInit settings.
	configurationAssistant() {
		irisLevel := this.configuration.irisLevel()
		optimalLevel := this.configuration.optimalLevel()
		
		if (irisLevel < 145) {
			this.gui.playWarningSound()
			msgbox,,% script,% "Your Iris do not fulfill the minimum level requirement of 145 or higher!"
			exit
		}

		if (this.irisThreshold(2010)) { ; Astraea
			initDownClicks := [6,5,6,5,6,3]
			yLvlInit := 241
		} else if (this.irisThreshold(1760)) { ; Alabaster
			; [6,6,6,5,6,3], 227
			; [6,5,6,6,6,3], 260
			; [5,6,6,5,6,3], 293
			initDownClicks := [6,6,6,5,6,3]
			yLvlInit := 227
		} else if (this.irisThreshold(1510)) { ; Cadmia
			initDownClicks := [6,6,6,6,6,3]
			yLvlInit := 240
		} else if (this.irisThreshold(1260)) { ; Lilin
			initDownClicks := [6,6,6,6,6,3]
			yLvlInit := 285
		} else if (this.irisThreshold(1010)) { ; Banana
			initDownClicks := [6,7,6,7,6,3]
			yLvlInit := 240
		} else if (this.irisThreshold(760)) { ; Phthalo
			initDownClicks := [6,7,7,6,7,3]
			yLvlInit := 273
		} else if (this.irisThreshold(510)) { ; Terra
			initDownClicks := [7,7,7,7,7,3]
			yLvlInit := 240
		} else if (this.irisThreshold(260)) { ; Atlas
			initDownClicks := [7,7,7,8,7,3]
			yLvlInit := 273
		} else { ; Dread Knight
			initDownClicks := [7,8,7,8,7,4]
			yLvlInit := 257
		}

		if (irisLevel < optimalLevel - 1001) {
			levels := optimalLevel - 1001 - irisLevel
			this.gui.playNotificationSound()
			msgbox,,% script,% "Your Iris is " . levels . " levels below the recommended ""optimal level - 1001"" rule."
		}
	}

	; Check if Iris is within a certain threshold that can cause a toggling behaviour between different settings
	irisThreshold(lvl) {
		irisLevel := this.configuration.irisLevel()
		optimalLevel := this.configuration.optimalLevel()
		
		upperThreshold := lvl + 19
		lowerThreshold := lvl - 20
		if (irisLevel >= lowerThreshold and irisLevel < upperThreshold) {
			this.gui.playWarningSound()
			msgbox,,% script,% "Threshold proximity warning! You should level up your Iris to " . upperThreshold . " or higher."
		}
		return irisLevel > lvl
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

	openSaveDialog() {
		settings_dialog := this.game.openSettingsDialog()
		settings_dialog.openSaveDialog()
		this.game.delay(10)
		
		return settings_dialog
	}

	getSavegame() {
		OriginalClipboard := ClipboardAll
		Clipboard =
		
		settings_dialog := this.openSaveDialog()
		
		ClipWait
		savegame := Clipboard
		
		this.game.delay(4)
		settings_dialog.closeSaveDialog()
		
		Clipboard := OriginalClipboard
		OriginalClipboard =
		
		settings_dialog.close()
		return savegame
	}
	
	writeFile(filename, contents) {
		FileDelete, %filename%
		FileAppend, %contents%, %filename%
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

	cleanupTempfiles() {
		for idx, filename in this.tempFiles
			FileDelete, %filename%
	}
}
