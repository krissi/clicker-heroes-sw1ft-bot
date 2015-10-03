#Include <Configuration\Abstract_Configuration>
#Include <Coordinate>

class CoordinateStore extends AbstractConfiguration {
	section := "coordinates"

	getCoordinate(coordinate_name) {
		x := this.getSetting(coordinate_name . "_X")
		y := this.getSetting(coordinate_name . "_Y")

		return new Coordinate(x, y)
	}

	__Call(method, args*) {
		if this[method]
			return this[method].(this, args*)
			
		return this.getCoordinate(method)
	}
}
