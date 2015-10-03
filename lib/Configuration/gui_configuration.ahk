#Include <Configuration\Abstract_Configuration>

class GuiConfiguration extends AbstractConfiguration {
	section := "gui"
	
	xSplash() {
		value := this.getSetting("xSplash")
		
		if(value == "SCREEN_CENTER") {
			return A_ScreenWidth // 2 - this.wSplash() // 2
		}
		
		return value
	}
	
	ySplash() {
		value := this.getSetting("ySplash")

		if(value = "SCREEN_CENTER") {
			return A_ScreenHeight // 2 - 40
		}
	}
}
