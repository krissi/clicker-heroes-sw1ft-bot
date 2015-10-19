class AbstractStartStrategy {
	__New(game, gui, configuration) {
		this.game := game
		this.gui := gui
		this.configuration := configuration
	}
	
	init() {
		this.game.switchToCombatTab()
		this.game.clickHero()
		this.currentPage := 1
		
		this.configurationAssistant()
	}
	
	clickHero(heroNum, clickCount := 1) {
		local heroNumOnPage := mod((heroNum -1), 4) +1
		local heroPage := floor((heroNum -1) / 4) +1
		
		local xLvl := this.configuration.Lvl_X()
		local oLvl := this.configuration.Lvl_Offset()
		local yLvlInit := this.yLvlInit
		
		if(this.currentPage > heroPage) {
			throw "Scrolling upwards not implemented"
		}
		
		while(heroPage > this.currentPage) {
			this.game.scrollDown(this.initDownClicks[this.currentPage])
			this.currentPage := this.currentPage +1
		}

		this.game.client.ctrlClickPos(xLvl, yLvlInit + oLvl * (heroNumOnPage -1), clickCount)
	}
	
	; Automatically configure initDownClicks and yLvlInit settings.
	configurationAssistant() {
		local irisLevel := this.configuration.irisLevel()
		local optimalLevel := this.configuration.optimalLevel()
		
		if (irisLevel < 145) {
			this.gui.playWarningSound()
			msgbox,,% script,% "Your Iris do not fulfill the minimum level requirement of 145 or higher!"
			exit
		}

		if (this.irisThreshold(2010)) { ; Astraea
			this.initDownClicks := [6,5,6,5,6,3]
			this.yLvlInit := 241
		} else if (this.irisThreshold(1760)) { ; Alabaster
			; [6,6,6,5,6,3], 227
			; [6,5,6,6,6,3], 260
			; [5,6,6,5,6,3], 293
			this.initDownClicks := [6,6,6,5,6,3]
			this.yLvlInit := 227
		} else if (this.irisThreshold(1510)) { ; Cadmia
			this.initDownClicks := [6,6,6,6,6,3]
			this.yLvlInit := 240
		} else if (this.irisThreshold(1260)) { ; Lilin
			this.initDownClicks := [6,6,6,6,6,3]
			this.yLvlInit := 285
		} else if (this.irisThreshold(1010)) { ; Banana
			this.initDownClicks := [6,7,6,7,6,3]
			this.yLvlInit := 240
		} else if (this.irisThreshold(760)) { ; Phthalo
			this.initDownClicks := [6,7,7,6,7,3]
			this.yLvlInit := 273
		} else if (this.irisThreshold(510)) { ; Terra
			this.initDownClicks := [7,7,7,7,7,3]
			this.yLvlInit := 240
		} else if (this.irisThreshold(260)) { ; Atlas
			this.initDownClicks := [7,7,7,8,7,3]
			this.yLvlInit := 273
		} else { ; Dread Knight
			this.initDownClicks := [7,8,7,8,7,4]
			this.yLvlInit := 257
		}

		if (irisLevel < optimalLevel - 1001) {
			levels := optimalLevel - 1001 - irisLevel
			this.gui.playNotificationSound()
			msgbox,,% script,% "Your Iris is " . levels . " levels below the recommended ""optimal level - 1001"" rule."
		}
	}

	; Check if Iris is within a certain threshold that can cause a toggling behaviour between different settings
	irisThreshold(lvl) {
		local irisLevel := this.configuration.irisLevel()
		local optimalLevel := this.configuration.optimalLevel()
		
		upperThreshold := lvl + 19
		lowerThreshold := lvl - 20
		if (irisLevel >= lowerThreshold and irisLevel < upperThreshold) {
			this.gui.playWarningSound()
			msgbox,,% script,% "Threshold proximity warning! You should level up your Iris to " . upperThreshold . " or higher."
		}
		return irisLevel > lvl
	}
}
