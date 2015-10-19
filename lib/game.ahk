#Include <Debug_Client>
#Include <Settings_Dialog>
#Include <Coordinate_Store>

class Game {
	; -- Coordinates --------------------------------------------------------------------------

	; Ascension button
	xAsc := 310
	yAsc := 434

	buttonSize := 35

	; Ascend Yes button
	xYes := 500
	yYes := 445

	; Scrollbar

	top2BottomClicks := 46

	xGilded := 95
	yGilded := 582

	xGildedClose := 1090
	yGildedClose := 54
	
	__New(gui, configuration) {
		this.full_configuration := configuration
		this.gui := gui
		this.client := new DebugClient(this.gui, configuration)
		this.configuration := configuration.game
		this.coordinates := new CoordinateStore()
	}
	
	; --------------- Game Elements ----------------------
	
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

	clickRelic() {
		this.coordinates.relic().click(this.client)
		this.delay(4)
	}
	
	clickHero() {
		this.coordinates.hero().click(this.client)
	}
	
	clickRanger(idx) {
		this.coordinates.getCoordinate("Ranger_" . idx).click(this.client)
	}
	
	; -------------------- Tabs ---------------------------

	switchToCombatTab() {
		this.coordinates.combat_tab().click(this.client)
		this.delay(4)
	}

	switchToAncientTab() {
		this.coordinates.ancient_tab().click(this.client)
		this.delay(2)
	}

	switchToRelicTab() {
		this.coordinates.relic_tab().click(this.client)
		this.delay(2)
	}
	
	; ------------------ Scrollbar -------------------------

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
		this.delay(2)
	}

	scrollDown(clickCount:=1) {
		this.coordinates.scrollbar_down_button().click(this.client, clickCount)
		this.delay(2)
	}

	; Scroll down fix when at bottom and scroll bar don't update correctly
	scrollWayDown(clickCount:=1) {
		this.scrollUp()
		this.scrollDown(clickCount + 1)
		sleep % this.nextHeroDelay * 1000
	}
	
	clickBuyAvailableUpdates() {
		this.coordinates.buyupgrades().click(this.client)
	}
	
	; ------------------- Buttons --------------------------
	openSettingsDialog() {
		settings_dialog := this.client.getSettingsDialog(this)
		settings_dialog.open()
		
		this.delay(3)
		return settings_dialog
	}

	openSalvageJunkPileDialog() {
		this.coordinates.salvageJunkButton().click(this.client)
		this.delay(4)

		destroy_coordinate := this.coordinates.salvageJunkDialogDestroyButton()
		destroy_func := destroy_coordinate.click.bind(destroy_coordinate, this.client)

		dialog := Object("confirm_destroy", destroy_func)

		return dialog 
	}

	screenShot() {
		this.client.screenShot()
	}
	
	; ---------------- Click Helpers -----------------------

	maxClick(xCoord, yCoord, clickCount:=1) {
		this.client.maxClick(xCoord, yCoord, clickCount)
		this.delay()
	}

	ctrlClick(xCoord, yCoord, clickCount:=1, sleepSome:=1) {
		this.client.ctrlClick(xCoord, yCoord, clickCount)

		if (sleepSome) {
			this.delay()
		}
	}
		
	delay(factor := 1) {
		sleep % this.configuration.zzz() * factor
	}
}