extends Node

var children: Array:
	get:
		var x: Array = []
		for i in self.get_children():
			x.append(i.name)
		return x

@rpc("authority")
func addSceneOnClient(Place):
	if not children.has(Place):
		var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
		self.add_child(x, true)
		rpc_id(1, 'sceneOnClientAdded')
		prints(Place, 'scena aggiunta')
	else:
		prints('Scene', Place, 'already existent on this client')
	
@rpc("call_local")
func sceneOnClientAdded():
	pass
