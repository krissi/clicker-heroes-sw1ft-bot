class SettingsDialog {
	__New(client, coordinates, configuration) {
		this.client := client
		this.coordinates := coordinates
		this.configuration := configuration
	}
	
	open() {
		this.coordinates.settingsDialogOpenButton().click(this.client)
	}
	
	close() {
		this.coordinates.settingsDialogCloseButton().click(this.client)
	}
	
	openSaveDialog() {
		dialogBoxClass := this.configuration.saveDialogBoxClass()
		this.coordinates.saveDialogOpenButton().click(this.client)
		sleep % 1000
	}	
	
	closeSaveDialog() {
		dialogBoxClass := this.configuration.saveDialogBoxClass()
		ControlSend,, {esc}, ahk_class %dialogBoxClass%
	}
}