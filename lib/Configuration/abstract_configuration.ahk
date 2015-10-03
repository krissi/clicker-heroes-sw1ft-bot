#Include <Configuration\Configuration_Store>

class AbstractConfiguration {
	__New(configurations := false) {
		if (this.section == "")
			throw "No section defined"
		
		if(configurations) {
			this.configurations := configurations
		} else {
			this.configurations := []
			this.configurations.push(new ConfigurationStore("user.ini"))
			this.configurations.push(new ConfigurationStore("default.ini"))
			this.configurations.push(new ConfigurationStore("system.ini"))
		}
	}
	
	getSetting(setting) {
		for idx, config in this.configurations {
			value := config.getValue(this.section, setting)
			
			if (value != ConfigurationStore.setting_unreadable) {
				if(value == "false") {
					return false
				}
				return value
			}
		}
			
		throw Exception("No value found for '" . setting . "' in '" . this.section . "'. Either your installation is broken or this is a bug", "SETTING_NOT_FOUND", [ this.section, setting ])
	}
	
	__Call(method, args*) {
		if this[method]
			return this[method].(this, args*)
		
		return this.getSetting(method)
	}
}


