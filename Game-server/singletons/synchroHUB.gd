extends Node

func toClients(_identity, tempSynchro):
	for i in get_node(_identity).get_parent().characterList:
		rpc_id(i, 'synchronizeOnClients', _identity, tempSynchro)

@rpc("any_peer", "unreliable")
func synchronizeOnServer(path, incomingSynchro):
	var _identity: String = str(multiplayer.get_remote_sender_id())
	if get_node_or_null(path + _identity):
		if incomingSynchro == null:
			get_node(path + _identity).emit_signal('spawned')
		elif get_node(path + _identity).Synchro.T < incomingSynchro.T:
			get_node(path + _identity).Synchro.T = incomingSynchro.T
			if incomingSynchro.has('D'):
				get_node(path + _identity).emit_signal('updateDirection', incomingSynchro.D)
			if incomingSynchro.has('I'):
				get_node(path + _identity).Synchro.I = incomingSynchro.I
#			get_node(path + _identity).Synchro.merge(incomingSynchro, true)
			get_node(path + _identity).emit_signal('updateFacing')
		else:
			print('Not sequential/old packet arrived, discarded...')
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local", "unreliable")
func synchronizeOnClients(_identity, _coords):
	pass
