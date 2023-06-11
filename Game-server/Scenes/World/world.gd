extends Node2D

var CharacterScene = preload("res://Scenes/Character/Character.tscn")

func addScene(client_id, place_name : String)-> bool:
	if self.has_node(place_name):
		print('Scene already exist')
	else:
		print('Not existent scene (or empty World), creating...')
		var place_path = 'res://Scenes/World/' + place_name + '.tscn'
		var new_place = load(place_path).instantiate()
		get_node("/root/World").add_child.call_deferred(new_place, true)
	SynchroHub.call_add_scene_on_client(client_id, place_name)
	await SynchroHub.scene_on_client_added_signal
	return true

func create_player(clientID, Place, spawnPointID:= 0, PreviouslyScene = null):
	var spawnCoordinates: Vector2 = get_node(Place).get('spawnPoints')[spawnPointID]
	var x = CharacterScene.instantiate()
#	x.set_multiplayer_authority(clientID)
	x.set_name(str(clientID))
	x.set_position(spawnCoordinates)
	get_node(Place + '/SubViewport/Characters').add_child(x, true)
	while get_node_or_null(Place + '/SubViewport/Characters/' + x.name) == null:
		print('Waiting for creating character...')
	prints("New character created for player ID:", clientID, 'on scene:', Place)
	if PreviouslyScene != null: # If null it is the first spawn of session, not a scene change
		if get_node_or_null('/root/World/' + PreviouslyScene + '/SubViewport/Characters/' + str(clientID)) != null:
			print('Character istance in previously scene destroyed')
			get_node('/root/World/' + PreviouslyScene + '/SubViewport/Characters/' + str(clientID)).queue_free()
			
func destroy_player(id : int) -> void:
	for i in self.get_children():
		if i.get_node('SubViewport/Characters').has_node(str(id)):
			i.get_node('SubViewport/Characters/' + str(id)).queue_free()
			prints('Player ID', id, 'character istance destroyed')
			break
		else:
			print('Error destroying character istance, inexistent...')
