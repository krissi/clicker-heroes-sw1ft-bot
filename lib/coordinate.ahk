class Coordinate {
	__New(x, y) {
		this.x := x
		this.y := y
	}
	
	click(client, clickCount := 1) {
		client.clickPos(this.x, this.y, clickCount)
	}
}
