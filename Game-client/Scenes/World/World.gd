extends Node2D

func _ready():
#	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
#	get_node('/root/World').add_child.call_deferred(x, true)
#	CharacterScene.set_name(str(id))# Set the name, so players can figure out their local authority
#	get_node('/root/World/' + Place + "/Characters").add_child(CharacterScene)
#	prints("New character created for player ID:", id)
	pass

@rpc("authority")
func addSceneOnClient(Place):
	print(Place)
	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	get_node('/root/World').add_child.call_deferred(x, true)
	



