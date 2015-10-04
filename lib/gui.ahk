class GuiAborter {
	__New() {
		this.aborted := false
	}

	abort() {
		this.aborted := true
	}
}

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

	userDoesAllow(text, seconds := 5) {
		static TimeoutProgressbar, Cancel

		if(seconds == 0)
			return true

		msecs := seconds * 1000
		wSplash := this.configuration.wSplash()
		xSplash := this.configuration.xSplash()
		ySplash := this.configuration.ySplash()

		border := 10
		client_width := wSplash -(2*border)
		button_width := 100
		button_x := wSplash / 2 - button_width / 2

		aborter := new GuiAborter()
		abort_func := aborter.abort.bind(aborter)

		Gui, UserAbortSplash:Font, s10
		Gui, UserAbortSplash:Add, Text,% "x" border " y" border " w" client_width " center",% text
		Gui, UserAbortSplash:Add, Progress,% "x" border " hp w" client_width " h20 vTimeoutProgressbar range0-" msecs,% msecs
		Gui, UserAbortSplash:Add, Button,% "x" button_x " hp w" button_width " h30 vCancel", Abort !
		GuiControl UserAbortSplash:+g,Cancel, %abort_func%
		Gui, UserAbortSplash:Show,% "w" wSplash " x" xSplash " y" ySplash,% this.title

		endTicks := A_TickCount + seconds * 1000
		loop {
			sleep % 100
			GuiControl, UserAbortSplash:, TimeoutProgressbar,% (endTicks - A_TickCount)

			if(A_TickCount > endTicks || aborter.aborted)
				break 
		}

		Gui, UserAbortSplash:Destroy
		return !aborter.aborted
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

