#Persistent
#NoEnv
#InstallKeybdHook

SetTitleMatchMode, 3 ; Steam [3] or browser [regex] version?
SetControlDelay, -1


#Include <Bot>

bot := new Bot(script)
game := bot.game
settings_dialog := new SettingsDialog(bot.game.client, bot.game.coordinates, bot.game.client.configuration)

; -----------------------------------------------------------------------------------------
; -- Hotkeys (+=Shift, !=Alt, ^=Ctrl)
; -----------------------------------------------------------------------------------------

!Esc::Reload
return

; Quick tests for <Game> (Ctrl):
^F1::
	game.getClickable()
return

^F2::
	game.switchToCombatTab()
return

^F3::
	game.switchToAncientTab()
return

^F4::
	game.switchToRelicTab()
return

^F5::
	MsgBox % "Clantab not yet implemented"
return

^F6::
	game.scrollToTop()
return

^F7::
	game.scrollToBottom()
return

; Quick tests for <Bot> (Alt):
!F1::
	bot.saveGame()
return

!F2::
	bot.openAncientsOptimizer()
return

!F3::
	bot.ascend()
return

!F4::
	bot.salvageJunkPile()
return

!F5::
	bot.buyAvailableUpgrades()
return

!F6::
	bot.regild()
return

!F7::
	bot.toggleMode()
return

!F8::
	bot.activateSkills()
return

!F9::
	bot.toggleFlag()
return

; Quick tests smaller classes (<SettingsDialog>, ...) (Shift):
+F1::
	settings_dialog.open()
return

+F2::
	settings_dialog.close()
return

+F3::
	settings_dialog.openSaveDialog()
return

+F4::
	settings_dialog.closeSaveDialog()
return