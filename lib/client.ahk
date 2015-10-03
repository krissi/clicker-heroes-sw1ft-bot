class Client {
	winName := "Clicker Heroes"
	
	chWinId := ""

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

	__New(gui) {
		this.gui := gui
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
	
	calculateBrowserOffsets() {
		global
		;winName := Lvl.*Clicker Heroes.*
		IfWinExist, % this.winName
		{
			this.gui.showSplash("Calculating browser offsets...", 2, 0)
			WinActivate
			WinGetPos, x, y, w, h
			WinGet, chWinId, ID, A

			local leftMargin := (w - chWidth) // 2
			leftMarginOffset := leftMargin - chMargin
			topMarginOffset := browserTopMargin - chTopMargin
		} else {
			this.gui.showWarningSplash("Clicker Heroes started in browser?")
		}
	}

	calculateSteamAspectRatio() {
		global
		
		IfWinExist, % this.winName
		{
			WinActivate
			WinGetPos, x, y, w, h
			WinGet, local_chWinId, ID, A
			this.chWinId := local_chWinId
			
			; Fullscreen sanity checks
			if (this.fullScreenOption) {
				if (w <> A_ScreenWidth || h <> A_ScreenHeight) {
					this.gui.showWarningSplash("Set the fullScreenOption to false in the bot lib file.")
					return
				}
			} else if (w = A_ScreenWidth && h = A_ScreenHeight) {
				this.gui.showWarningSplash("Set the fullScreenOption to true in the bot lib file.")
				return
			}

			if (w != this.chTotalWidth || h != this.chTotalHeight) {
				this.gui.showSplash("Calculating Steam aspect ratio...", 2, 0)

				local winWidth := this.fullScreenOption ? w : w - 2 * this.chMargin
				local winHeight := this.fullScreenOption ? h : h - this.chTopMargin - this.chMargin
				local horizontalAR := winWidth/this.chWidth
				local verticalAR := winHeight/this.chHeight

				; Take the lowest aspect ratio and calculate border size
				if (horizontalAR < verticalAR) {
					this.aspectRatio := horizontalAR
					this.vBorder := (winHeight - this.chHeight * this.aspectRatio) // 2
				} else {
					this.aspectRatio := verticalAR
					this.hBorder := (winWidth - this.chWidth * this.aspectRatio) // 2
				}
			}
		} else {
			this.gui.showWarningSplash("Clicker Heroes started?")
		}
	}
	
	clickPos(xCoord, yCoord, clickCount:=1) {
		xAdj := this.getAdjustedX(xCoord)
		yAdj := this.getAdjustedY(yCoord)
		chWinId := this.chWinId
		
		ControlClick, x%xAdj% y%yAdj%, ahk_id %chWinId%,,, %clickCount%, NA
	}

	getAdjustedX(x) {
		global
		local leftMargin := this.fullScreenOption ? 0 : this.chMargin + this.leftMarginOffset
		return round(this.aspectRatio*(x - this.chMargin) + leftMargin + this.hBorder)
	}

	getAdjustedY(y) {
		global
		local topMargin := this.fullScreenOption ? 0 : this.chTopMargin + this.topMarginOffset
		return round(this.aspectRatio*(y - this.chTopMargin) + topMargin + this.vBorder)
	}

}