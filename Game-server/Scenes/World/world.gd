extends Node2D
var CharacterScene = preload("res://Scenes/Character/Character.tscn")
signal sceneOnClientAddedSignal

func addScene(clientID, Place)-> bool:
#	if not self.get_children().is_empty() and self.has_node(Place):
	if self.has_node(Place):
		print('Scene already exist')
	else:
		print('Not existent scene (or empty World), creating...')
		var p = load('res://Scenes/World/' + Place + '.tscn').instantiate()
		get_node("/root/World").add_child(p, true)
		var error = get_node_or_null('/root/World/' + Place)
		while error == null:
			print('wait, adding scene')
			error = get_node_or_null('/root/World/' + Place)
	rpc_id(clientID, 'addSceneOnClient', Place)
	await sceneOnClientAddedSignal
	return true

func create_player(clientID, Place, PreviouslyScene = null):
	var x = CharacterScene.instantiate()
	x.set_name(str(clientID))# Set the name, so players can figure out their local authority
	get_node('/root/World/' + Place + '/Characters').add_child.call_deferred(x, true)
	prints("New character created for player ID:", clientID, 'on scene:', Place)
	if PreviouslyScene != null:
		if get_node_or_null('/root/World/' + PreviouslyScene + '/Characters/' + clientID) != null:
			print('Character istance in previously scene destroyed')
			get_node('/root/World/' + PreviouslyScene + '/Characters/' + clientID).queue_free()
			
func destroy_player(id : int) -> void:
	for i in get_node('/root/World').get_children():
		if i.get_node('Characters').has_node(str(id)):
			i.get_node('Characters').get_node(str(id)).queue_free()
			prints('Player ID', id, 'character istance destroyed')
			break
		print('Errore destroying character istance, inexistent...')

@rpc("any_peer")
func sceneOnClientAdded():
	sceneOnClientAddedSignal.emit()

@rpc("call_local")
func addSceneOnClient(Place):
	pass
