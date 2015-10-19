class Client {
	; All the script coordinates are based on these four default dimensions.
	chWidth := 1136
	chHeight := 640
	chMargin := 8
	chTopMargin := 30

	chTotalWidth := this.chWidth + this.chMargin * 2
	chTotalHeight := this.chHeight + this.chMargin + this.chTopMargin

	; Calculated
	leftMarginOffset := 0
	topMarginOffset := 0

	; Calculated
	aspectRatio := 1
	hBorder := 0
	vBorder := 0

	__New(gui, configuration) {
		this.gui := gui
		this.configuration := configuration.client
		this.clientCheck()
	}
	
	clientCheck() {
		global
		WinGet, activeWinId, ID, A ; remember current active window...
		if (A_TitleMatchMode = 3) {
			this.calculateSteamAspectRatio() ; Steam
		} else {
			this.calculateBrowserOffsets() ; Browser
			this.fullScreenOption := false
		}
		WinActivate, ahk_id %activeWinId% ; ... and restore focus back
	}
	
	chWinId() {
		IfWinExist, % this.configuration.windowName()
		{
			WinGet, chWinId, ID
			return chWinId
		}

		throw "Cannot get HWND"
	}

	updateClientPosition() {
		hwnd := this.chWinId()
		WinGetPos, x, y, w, h, ahk_id %hwnd%

		this.client_x := x
		this.client_y := y
		this.client_w := w
		this.client_h := h
	}
	
	pid() {
		hwnd := this.hwnd()
		WinGet, pid, PID, ahk_id %hwnd%
		return pid
	}
	
	calculateBrowserOffsets() {
		MsgBox % "todo"

		this.updateClientPosition()
		this.gui.showSplash("Calculating browser offsets...", 2, 0)

		leftMargin := (this.w - this.chWidth) // 2
		leftMarginOffset := this.leftMargin - this.chMargin
		topMarginOffset := this.browserTopMargin - this.chTopMargin
	}

	calculateSteamAspectRatio() {
		this.updateClientPosition()

		; Fullscreen sanity checks
		if (this.fullScreenOption) {
			if (this.client_w <> A_ScreenWidth || this.client_h <> A_ScreenHeight) {
				this.gui.showWarningSplash("Set the fullScreenOption to false in the bot lib file.")
				return
			}
		} else if (this.client_w = A_ScreenWidth && this.client_h = A_ScreenHeight) {
			this.gui.showWarningSplash("Set the fullScreenOption to true in the bot lib file.")
			return
		}

		if (this.w != this.chTotalWidth || this.h != this.chTotalHeight) {
			this.gui.showSplash("Calculating Steam aspect ratio...", 2, 0)

			winWidth := this.fullScreenOption ? this.client_w : this.client_w - 2 * this.chMargin
			winHeight := this.fullScreenOption ? this.client_h : this.client_h - this.chTopMargin - this.chMargin
			horizontalAR := winWidth/this.chWidth
			verticalAR := winHeight/this.chHeight

			; Take the lowest aspect ratio and calculate border size
			if (horizontalAR < verticalAR) {
				this.aspectRatio := horizontalAR
				this.vBorder := (winHeight - this.chHeight * this.aspectRatio) // 2
			} else {
				this.aspectRatio := verticalAR
				this.hBorder := (winWidth - this.chWidth * this.aspectRatio) // 2
			}
		}
	}
	
	clickPos(xCoord, yCoord, clickCount:=1) {
		xAdj := this.getAdjustedX(xCoord)
		yAdj := this.getAdjustedY(yCoord)
		chWinId := this.chWinId()
		
		ControlClick, x%xAdj% y%yAdj%, ahk_id %chWinId%,,, %clickCount%, NA
	}
	
	maxClick(xCoord, yCoord, clickCount:=1) {
		ControlSend,, {shift down}{q down}, % this.winName
		this.clickPos(xCoord, yCoord, clickCount)
		ControlSend,, {q up}{shift up}, % this.winName
	}

	ctrlClickPos(xCoord, yCoord, clickCount:=1) {
		ControlSend,, {ctrl down}, % this.winName
		this.clickPos(xCoord, yCoord, clickCount)
		ControlSend,, {ctrl up}, % this.winName
	}

	getAdjustedX(x) {
		leftMargin := this.fullScreenOption ? 0 : this.chMargin + this.leftMarginOffset
		return round(this.aspectRatio*(x - this.chMargin) + leftMargin + this.hBorder)
	}

	getAdjustedY(y) {
		topMargin := this.fullScreenOption ? 0 : this.chTopMargin + this.topMarginOffset
		return round(this.aspectRatio*(y - this.chTopMargin) + topMargin + this.vBorder)
	}
	
	screenShot() {
		if (A_TitleMatchMode = 3) { ; Steam only
			WinGet, activeWinId, ID, A ; remember current active window...
			WinActivate, % this.winName
			send {f12 down}{f12 up} ; screenshot
			sleep % 200
			WinActivate, ahk_id %activeWinId% ; ... and restore focus back
		}
	}
	
	getSettingsDialog(game) {
		return new SettingsDialog(this, game.coordinates, this.configuration)
	}
}