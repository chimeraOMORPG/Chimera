extends Node

func toClients(_identity, coords, faceDirection):
	for i in get_node(_identity).get_parent().characterList:
		rpc_id(i, 'synchronizeOnClients', _identity, coords, faceDirection)

@rpc("any_peer", "reliable")
func justSpawned(path):
	var _identity: String = str(multiplayer.get_remote_sender_id())
	if get_node_or_null(path + _identity):
		get_node(path + _identity).emit_signal('spawned')

@rpc("any_peer", "unreliable")
func synchronizeOnServer(path, incomingSynchro):
	var _identity: String = str(multiplayer.get_remote_sender_id())
	if get_node_or_null(path + '/' + _identity):
		if get_node(path + _identity).Synchro.time < incomingSynchro.time:
			get_node(path + _identity).Synchro = incomingSynchro
			get_node(path + _identity).emit_signal('updateFacing')
		else:
			print('Not sequential/old packet arrived, discarded...')
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local", "unreliable")
func synchronizeOnClients(_identity, _coords):
	pass
