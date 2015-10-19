#Include <Client>
#Include <SetTimerF>

class DebugClient extends Client {
	static windowColor := "EEAA99"

	__New(args*) {
		base.__New(args*)
		this.createCanvas()

		this.dots := []
		SetTimerF(this.cleanupDots, 250, Object(1, this))
	}

	clickPos(x, y, clickCount := 1) {
		this.setPixel(this.getAdjustedX(x), this.getAdjustedY(y), "red")
		base.clickPos(x, y, clickCount)
	}

	; -------------------- Graphic methods --------------------------
	createCanvas() {
		this.updateClientPositions()

		client_x := this.client_x
		client_y := this.client_y
		client_w := this.client_w
		client_h := this.client_h
		windowColor := this.windowColor

		Gui, DebugClient:Color, %windowColor%
		Gui DebugClient:+LastFound +AlwaysOnTop +ToolWindow
		WinSet, Transparent, 150
		WinSet, ExStyle, +0x20
		Gui DebugClient:-Caption
		Gui, DebugClient:Show, w%client_w% h%client_h% x%client_x% y%client_y%, CH Debug Client

		Process, Exist
		WinGet, canvasHwnd, ID, %p_title% ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%
		this.canvasHwnd := canvasHwnd
	}

	setPixel(p_x, p_y, p_color := false, p_size := 5) {
		static total
		total++

		if(p_color == false)
			p_color := this.windowColor
		else
			this.dots.push([A_TickCount, p_x, p_y])

		Gui, DebugClient:Add, Progress, % "x" ( p_x-1 ) " y" ( p_y-1 ) " w" ( p_size+2 ) " h" ( p_size+2 ) " background" p_color
		
		canvasHwnd := this.canvasHwnd

		; WS_EX_STATICEDGE	
		Control, ExStyle, -0x20000, msctls_progress32%total%, ahk_id %canvasHwnd% 
		
		WinSet, Redraw,, ahk_id %canvasHwnd%
	}

	cleanupDots(debug_client, maxDotAge := 2000) {
		for idx, dot_info in debug_client.dots {
			if(dot_info[1] < (A_TickCount -maxDotAge)) {
				debug_client.setPixel(dot_info[2], dot_info[3])
				debug_client.dots.delete(idx)
			}
		}
	}
}