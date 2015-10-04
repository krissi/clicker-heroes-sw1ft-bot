class Gui {
	__New(title, configuration) {
		this.title := title
		this.configuration := configuration.gui
	}
	
	playNotificationSound() {
		if (this.configuration.playNotificationSounds()) {
			SoundPlay, %A_WinDir%\Media\Windows User Account Control.wav
		}
	}

	playWarningSound() {
		if (this.configuration.playWarningSounds()) {
			SoundPlay, %A_WinDir%\Media\tada.wav
		}
	}

	showSplashAlways(text, seconds:=2) {
		this.showSplash(text, seconds, 1, 1)
	}

	showWarningSplash(text, seconds:=5) {
		this.showSplash(text, seconds, 2, 1)
	}

	showSplash(text, seconds:=2, sound:=1, showAlways:=0) {
		if (seconds > 0) {
			if (this.configuration.showSplashTexts() or showAlways) {
				progress,% "w" this.configuration.wSplash() " x" this.configuration.xSplash() " y" this.configuration.ySplash() " zh0 fs10", %text%,,% this.title
			}
			if (sound = 1) {
				this.configuration.playNotificationSounds()
			} else if (sound = 2) {
				this.configuration.playWarningSounds()
			}
			sleep % seconds * 1000
			progress, off
		}
	}
}

