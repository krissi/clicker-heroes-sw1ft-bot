#Include <Client>
#Include <Coordinate_Store>

class Game {
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

	xRelic := 103
	yRelic := 380

	xSalvageJunk := 280
	ySalvageJunk := 470

	xDestroyYes := 500
	yDestroyYes := 430

	; Scrollbar

	top2BottomClicks := 46

	xGilded := 95
	yGilded := 582

	xGildedClose := 1090
	yGildedClose := 54
	
	zzz := 200 ; sleep delay (in ms) after a click

	__New(gui) {
			this.gui := gui
			this.client := new Client(this.gui)
			this.coordinates := new CoordinateStore()
	}
	
	; No smart image recognition, so we click'em all!
	getClickable() {
		; Break idle on purpose to get the same amount of gold every run
		monster := this.coordinates.monster().click(this.game, 3)

		Loop {
			try { ; Eat setting-not-found-errors to autodetect clickable count from configuration
				this.coordinates.getCoordinate("Clickable_" . A_Index).click(this.client)
			} catch e {
				if(e.What == "SETTING_NOT_FOUND") {
					break
				} else {
					throw e
				}
			}
		}
	}

	switchToCombatTab() {
		this.coordinates.combat_tab().click(this.client)
		sleep % this.zzz * 4
	}

	switchToAncientTab() {
		this.coordinates.ancient_tab().click(this.client)
		sleep % this.zzz * 2
	}

	switchToRelicTab() {
		this.coordinates.relic_tab().click(this.client)
		sleep % this.zzz * 2
	}

	scrollToTop() {
		this.scrollUp(this.top2BottomClicks)
		sleep 1000
	}

	scrollToBottom() {
		this.scrollDown(this.top2BottomClicks)
		sleep 1000
	}

	scrollUp(clickCount:=1) {
		this.coordinates.scrollbar_up_button().click(this.client, clickCount)
		sleep % zzz * 2
	}

	scrollDown(clickCount:=1) {
		this.coordinates.scrollbar_down_button().click(this.client, clickCount)
		sleep % this.zzz * 2
	}

	; Scroll down fix when at bottom and scroll bar don't update correctly
	scrollWayDown(clickCount:=1) {
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