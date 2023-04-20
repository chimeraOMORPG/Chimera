extends Node2D

@rpc("authority")
func addSceneOnClient(Place):
	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	self.add_child.call_deferred(x, true)
	rpc_id(1, 'sceneOnClientAdded')
	prints(Place, 'scena aggiunta')

func _on_child_entered_tree(node):
	rpc_id.call_deferred(1, 'sceneOnClientAdded')
	
@rpc("authority")
func sceneOnClientAdded():
	pass
