extends Node2D

var CharacterScene = preload("res://Scenes/Character/Character.tscn")

func _ready():
	pass

@rpc("authority")
func addSceneOnClient(Place):
	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	self.add_child.call_deferred(x, true)
	prints(Place, 'scena aggiunta')
	
@rpc("authority")
func addCharacterOnClient(Place):
	var clientID = multiplayer.get_unique_id()
	var x = CharacterScene.instantiate()
	x.set_name(str(clientID))# Set the name, so players can figure out their local authority
	get_node('/root/World/' + Place + '/Characters').add_child.call_deferred(x, true)
	prints("New character created for player ID:", clientID, 'on scene:', Place)

func _on_child_entered_tree(node):
	rpc_id(1, 'sceneOnClientAdded')
	prints(node, 'child entrato')
	
@rpc("authority")
func sceneOnClientAdded():
	pass

