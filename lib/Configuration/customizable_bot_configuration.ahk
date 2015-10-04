#Include *i %A_ScriptDir%\custom_configuration.ahk

if(CustomBotConfiguration == "")
	CustomizableBotConfiguration := BotConfiguration
else
	CustomizableBotConfiguration := CustomBotConfiguration
