extends Node2D

func _ready():
	pass

@rpc("authority")
func addSceneOnClient(Place):
	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	self.add_child.call_deferred(x, true)
	prints(Place, 'scena aggiunta')

func _on_child_entered_tree(node):
	rpc_id(1, 'sceneOnClientAdded')
	prints(node, 'child entrato')
	
@rpc("authority")
func sceneOnClientAdded():
	pass
