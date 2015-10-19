class SimpleAscendStrategy {
	__New(game, gui, configuration) {
		this.game := game
		this.gui := gui
		this.configuration := configuration
	}
	
	run() {
		local extraClicks := this.configuration.ascensionExtraClicks()
		local buttonPos := this.game.coordinates.ascensionButton()
		local y := buttonPos.y - extraClicks * this.configuration.ascensionButtonSize()
		
		if (! this.gui.userDoesAllow("Ascending in " . this.configuration.autoAscendDelay() . " seconds! (Abort with Alt+Pause)", this.configuration.autoAscendDelay())) {
			this.gui.showSplashAlways("Ascension aborted!")
			exit
		}

		this.salvageJunkPile() ; must salvage junk relics before ascending

		this.game.switchToCombatTab()
		this.game.scrollDown(this.configuration.ascensionDownClicks())

		; Scrolling is not an exact science, hence we click above, center and below
		loop % 2 * extraClicks + 1
		{
			this.game.client.clickPos(buttonPos.x, y)
			y += this.configuration.ascensionButtonSize()
		}
		this.game.delay(4)
		this.game.coordinates.ascensionDialogAcceptButton().click(this.game.client)

		this.game.delay(2)
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
}