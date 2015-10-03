; First load *_Configuration, then Customizable_*_Configuration
#Include <Configuration\Gui_Configuration>
#Include <Configuration\Game_Configuration>

#Include <Configuration\Customizable_Gui_Configuration>
#Include <Configuration\Customizable_Game_Configuration>

class Configuration {
	gui := new CustomizableGuiConfiguration()
}
