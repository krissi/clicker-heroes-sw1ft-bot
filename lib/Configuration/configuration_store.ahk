class ConfigurationStore {
	static setting_unreadable := "SETTING_UNREADABLE_ERROR"
	
	__New(filename) {
			this.filename := filename
	}
	
	getValue(section, setting) {
		filename := this.filename
		setting_unreadable := this.setting_unreadable
		
		IniRead, value, %filename%, %section%, %setting%, %setting_unreadable%

		return value
	}
}


