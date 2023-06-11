extends Node

# Signals from clients
signal scene_on_client_added_signal
signal spawned_signal(node_path)
signal incoming_synchro_signal(node_path, data)
signal update_facing_signal(node_path)

@rpc("any_peer")
func scene_on_client_added():
	scene_on_client_added_signal.emit()

@rpc("any_peer", "reliable")
func just_spawned(node_path: String):
	spawned_signal.emit(node_path)

@rpc("any_peer", "unreliable")
func synchronize_on_server(node_path, data):
	incoming_synchro_signal.emit(node_path, data)
	update_facing_signal.emit(node_path)	

@rpc("any_peer", "reliable")
func disconnection_request():
	var client_id: int = multiplayer.get_remote_sender_id()
	prints(client_id, 'disconnection request arrived')
	multiplayer.multiplayer_peer.disconnect_peer(client_id)

# Server side methods
func call_add_scene_on_client(client_id, place_name):
	rpc_id(client_id, 'add_scene_on_client', place_name)

@rpc("call_local")
func add_scene_on_client(_Place):
	pass

func to_clients(node_path, coords, faceDirection):
	for i in get_node(node_path).get_parent().characterList:
		rpc_id(i, 'synchronize_on_clients', node_path, coords, faceDirection)

@rpc("call_local", "unreliable")
func synchronize_on_clients(_identity, _coords, _face_direction):
	pass

@rpc("call_local")
func character_spawned(place_name, node_name, character_id_list):
	for i in character_id_list:
		rpc_id(i, 'character_spawned', place_name, node_name, character_id_list)

@rpc("call_local")
func character_exiting(place_name, node_name, character_id_list):
	rpc_id(node_name.to_int(), 'character_exiting', place_name, node_name, character_id_list)
