#Include <Configuration\Configuration_Store>

class AbstractConfiguration {
	__New() {
		if (this.section == "")
			throw "No section defined"
		
		this.configurations := []
		this.configurations.push(new ConfigurationStore("user.ini"))
		this.configurations.push(new ConfigurationStore("default.ini"))
	}
	
	getSetting(setting) {
		for idx, config in this.configurations {
			value := config.getValue(this.section, setting)
			
			if (value != ConfigurationStore.setting_unreadable)
				return value
		}
			
		throw "No value found for '" . setting . "' in '" . this.section . "'. Either your installation is broken or this is a bug"
	}
	
	__Call(method, args*) {
		if this[method]
			return this[method].(this, args*)
		
		return this.getSetting(method)
	}
}


