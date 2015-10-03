#Include *i %A_ScriptDir%\custom_configuration.ahk

if(CustomGameConfiguration == "")
	CustomizableGameConfiguration := GameConfiguration
else
	CustomizableGameConfiguration := CustomGameConfiguration
