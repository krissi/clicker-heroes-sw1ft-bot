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

^F8::
	game.openSettingsDialog()
return

^F9::
	game.closeSettingsDialog()
return

; Quick tests for <Bot> (Alt):
!F1::
	bot.openSaveDialog()
return

!F2::
	bot.save()
return

!F3::
	bot.lvlUp()
return

!F4::
	bot.openAncientsOptimizer()
return

!F5::
	bot.ascend()
return

!F6::
	bot.salvageJunkPile()
return

!F7::
	bot.buyAvailableUpgrades()
return

!F8::
	bot.regild()
return

!F9::
	bot.toggleMode()
return

!F10::
	bot.activateSkills()
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