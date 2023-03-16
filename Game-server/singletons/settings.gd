extends Node

var enabled: bool = true #true/false enable/disabe ini style preferences and settings saves
var settings = ConfigFile.new()
signal settingsLoaded
		
func _ready():
	if enabled:
		var error = settings.load("res://settings.ini")
		if error != OK:
			print('An error occurred on loading settings.ini, loading defaults...')
		else:
			print('Ok found settings.ini, analyzing...')
			# Iterate over all sections.
			for section in settings.get_sections():
				var temp = get_tree().get_root().get_node(section)
				if temp == null:
					continue
				print('Iterating trought sections...')
				# Iterate over all properties.
				for property in settings.get_section_keys(section):
					print('Iterating trought properties...')
					prints('Found property:', property, 'with value:', settings.get_value(section, property), ' - searching for this property on script', section)
					# Il codice qui sotto va migliorato perchè adesso itera su tutte le variabili dei vari script
					# che corrispondono alle sezioni del file ini; trovare un modo più efficiente per verificare semplicemente
					# se la variabile nel file ini esiste nello script di riferimento (che corrisponde alla section)
					# ed in caso positivo sostituirne il valore.
					# Dopodiché ricordarsi di sostituire questo script anche negli altri componenti di Chimèra...
					for x in temp.get_script().get_script_property_list():
						if x.name == (property + 'INI'):
							prints('OK, found', property, 'with value:', temp.get(x.name))
							temp.set(x.name, settings.get_value(section, property))
							prints('Assigned new value:', temp.get(x.name))
							break
						else:
							print('nothing found...')
			print('All saved settings are loaded, continuing to update settings...')	
		updateSettings()
	settingsLoaded.emit()

func updateSettings():
	settings.clear()
	print('Below a complete list of all settings to save:')
	for x in get_tree().get_root().get_children():
		var y: GDScript = x.get_script()
		if y != null:
			for z in y.get_script_property_list():
				if z.name.ends_with('INI'):
					settings.set_value(str(x.name), z.name.trim_suffix('INI'), x.get(z.name))
					prints(x.name, z.name)
				else:
					if settings.has_section_key(x.name, z.name):
						settings.erase_section_key(x.name, z.name)
			settings.save("res://settings.ini")# Save it to a file (overwriting if already exists).


