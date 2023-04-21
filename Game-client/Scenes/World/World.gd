extends Node2D

@rpc("authority")
func addSceneOnClient(Place):
	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	self.add_child(x, true)
	rpc_id(1, 'sceneOnClientAdded')
	prints(Place, 'scena aggiunta')
	
@rpc("call_local")
func sceneOnClientAdded():
	pass
