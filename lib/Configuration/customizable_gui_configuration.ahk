#Include *i %A_ScriptDir%\custom_configuration.ahk

if(CustomGuiConfiguration == "")
	CustomizableGuiConfiguration := GuiConfiguration
else
	CustomizableGuiConfiguration := CustomGuiConfiguration
