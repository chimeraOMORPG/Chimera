extends Node

# Signals from server
signal character_spawned_signal(place_name, node_name, character_id_list)
signal character_exiting_signal(place_name, node_name, character_id_list)
signal synchronize_on_clients_signal(node_path, coords, face_direction)
signal add_scene_signal(place_name)

@rpc("authority", "reliable")
func character_spawned(place_name, node_name, character_id_list):
	character_spawned_signal.emit(place_name, node_name, character_id_list)

@rpc("authority", "reliable")
func character_exiting(place_name, node_name, character_id_list):
	character_exiting_signal.emit(place_name, node_name, character_id_list)

@rpc("authority", "unreliable")
func synchronize_on_clients(node_path, coords, face_direction):
	synchronize_on_clients_signal.emit(node_path, coords, face_direction)

@rpc("authority")
func add_scene_on_client(place_name):
	add_scene_signal.emit(place_name)

# Client side methods
@rpc("call_local")
func scene_on_client_added():
	rpc_id(1, 'scene_on_client_added')

@rpc("call_local","reliable")
func just_spawned(identity):
	rpc_id(1, 'just_spawned', identity)

@rpc("call_local", "unreliable")
func synchronize_on_server(node_path, data):
	rpc_id(1, 'synchronize_on_server', node_path, data)

@rpc("call_local", "reliable")
func disconnection_request():
	rpc_id(1, 'disconnection_request')
	await get_tree().create_timer(1).timeout
	if multiplayer.multiplayer_peer.get_connection_status() != 0:
		print('Disconnection request failed, disconnecting myself...')
		multiplayer.multiplayer_peer.close()
