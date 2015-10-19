#Include <Abstract_Start_Strategy>

class ClickableStartStrategy extends AbstractStartStrategy {
	doubleUpgradeHeroes := [1, 3, 16, 17, 20, 23]
	
	run() {
		local clickCount
		
		this.init()
		
		loop % 24 {
			clickCount := this.doDoubleClick(A_Index) ? 2 : 1
			this.clickHero(A_Index, clickCount)
		}
		
		this.clickHero(27)
		this.clickHero(28)
		
		this.game.scrollToBottom()	
		this.game.clickBuyAvailableUpdates()	
	}
	
	doDoubleClick(hero) {
		Loop % this.doubleUpgradeHeroes.Length() {
			if(this.doubleUpgradeHeroes[A_Index] == hero) {
				return true
			}
		}
		
		return false
	}
}