extends Node

var children: Array:
	get:
		var x: Array = []
		for i in self.get_children():
			x.append(i.name)
		return x

func _ready():
	SynchroHub.add_scene_signal.connect(_add_scene)

func _add_scene(place_name):
	if not children.has(place_name):
		var x = load('res://Scenes/World/' + place_name + '.tscn').instantiate()
		self.add_child(x, true)
	else:
		prints('Scene', place_name, 'already existent on this client')
	SynchroHub.scene_on_client_added()
