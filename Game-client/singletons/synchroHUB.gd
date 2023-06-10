extends Node

# Signals from server
signal character_spawned_signal(place_name, node_name, character_id_list)
signal character_exiting_signal(place_name, node_name, character_id_list)

@rpc("call_local", "unreliable")
func synchronize_on_server(node_path, data):
	rpc_id(1, 'synchronize_on_server', node_path, data)

func synchroAtReady(identity):
	rpc_id(1, 'justSpawned', identity)

@rpc("authority", "unreliable")
func synchronizeOnClients(identity, coords, faceDirection):
	if get_node_or_null(identity):
		if coords:
			get_node(identity).set('coords', coords)
		if faceDirection:
			get_node(identity).set('faceDirection', faceDirection)
	else:
		prints(identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local","reliable")
func justSpawned(identity):
	pass

@rpc("authority", "reliable")
func character_spawned(place_name, node_name, character_id_list):
	character_spawned_signal.emit(place_name, node_name, character_id_list)

@rpc("authority", "reliable")
func character_exiting(place_name, node_name, character_id_list):
	character_exiting_signal.emit(place_name, node_name, character_id_list)
