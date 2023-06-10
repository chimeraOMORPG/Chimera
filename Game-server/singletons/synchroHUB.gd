extends Node

# Signals from clients
signal incoming_synchro_signal(data)
signal update_facing_signal

func toClients(_identity, coords, faceDirection):
	for i in get_node(_identity).get_parent().characterList:
		rpc_id(i, 'synchronizeOnClients', _identity, coords, faceDirection)

signal just_spawned_signal
@rpc("any_peer", "reliable")
func just_spawned(node_path: String):
	if get_node_or_null(node_path):
		get_node(node_path).emit_signal('spawned')

@rpc("any_peer", "unreliable")
func synchronize_on_server(node_path, data):
	if get_node_or_null(node_path):
		get_node(node_path).synchro = data
		get_node(node_path).emit_signal('facing_updated')
	else:
		prints(node_path, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local", "unreliable")
func synchronizeOnClients(_identity, _coords):
	pass

@rpc("call_local")
func character_spawned(place_name, node_name, character_id_list):
	for i in character_id_list:
		rpc_id(i, 'character_spawned', place_name, node_name, character_id_list)

@rpc("call_local")
func character_exiting(place_name, node_name, character_id_list):
	rpc_id(node_name.to_int(), 'character_exiting', place_name, node_name, character_id_list)
