class Gui {
	playNotificationSounds := true
	playWarningSounds := true
	showSplashTexts := true
	xSplash := 10
	ySplash := 10
	wSplash := 100
	
	__New(title) {
		this.title := title
	}
	
	playNotificationSound() {
		if (playNotificationSounds) {
			SoundPlay, %A_WinDir%\Media\Windows User Account Control.wav
		}
	}

	playWarningSound() {
		if (this.playWarningSounds) {
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
		global

		if (seconds > 0) {
			if (this.showSplashTexts or this.showAlways) {
				progress,% "w" this.wSplash " x" this.xSplash " y" this.ySplash " zh0 fs10", %text%,,% this.title
			}
			if (sound = 1) {
				this.playNotificationSound()
			} else if (sound = 2) {
				this.playWarningSound()
			}
			sleep % seconds * 1000
			progress, off
		}
	}
}

