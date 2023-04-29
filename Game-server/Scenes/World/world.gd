extends Node2D

var CharacterScene = preload("res://Scenes/Character/Character.tscn")
signal sceneOnClientAddedSignal

func addScene(clientID, Place)-> bool:
	if self.has_node(Place):
		print('Scene already exist')
	else:
		print('Not existent scene (or empty World), creating...')
		var p = load('res://Scenes/World/' + Place + '.tscn').instantiate()
		get_node("/root/World").add_child.call_deferred(p, true)
	rpc_id(clientID, 'addSceneOnClient', Place)
	await sceneOnClientAddedSignal
	return true

func create_player(clientID, Place, spawnPointID:= 0, PreviouslyScene = null):
	var spawnCoordinates: Vector2 = get_node(Place).get('spawnPoints')[spawnPointID]
	var x = CharacterScene.instantiate()
	x.set_multiplayer_authority(clientID)
	x.set_name(str(clientID))
	get_node(Place + '/SubViewport/Characters').add_child(x, true)
	while get_node_or_null(Place + '/SubViewport/Characters/' + x.name) == null:
		print('Waiting for creating character...')
#	var temp = get_node(Place + '/SubViewport/Characters/' + x.name).setRightPosition(spawnCoordinates)
	get_node(Place + '/SubViewport/Characters/' + x.name).set_position(spawnCoordinates)
	prints("New character created for player ID:", clientID, 'on scene:', Place)
	if PreviouslyScene != null:
		if get_node_or_null('/root/World/' + PreviouslyScene + '/SubViewport/Characters/' + str(clientID)) != null:
			print('Character istance in previously scene destroyed')
			get_node('/root/World/' + PreviouslyScene + '/SubViewport/Characters/' + str(clientID)).queue_free()
			
func destroy_player(id : int) -> void:
	for i in self.get_children():
		if i.get_node('SubViewport/Characters').has_node(str(id)):
			i.get_node('SubViewport/Characters/' + str(id)).queue_free()
			prints('Player ID', id, 'character istance destroyed')
			break
		print('Errore destroying character istance, inexistent...')

@rpc("any_peer")
func sceneOnClientAdded():
	sceneOnClientAddedSignal.emit()

@rpc("call_local")
func addSceneOnClient(_Place):
	pass
