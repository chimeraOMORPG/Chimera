extends Node

func toClients(_identity, coords, faceDirection):
	for i in get_node(_identity).get_parent().characterList:
		rpc_id(i, 'synchronizeOnClients', _identity, coords, faceDirection)

@rpc("any_peer", "unreliable_ordered")
func justSpawned(_identity):
	if get_node_or_null(_identity):
		get_node(_identity).emit_signal('spawned')

@rpc("any_peer", "unreliable")
func synchronizeOnServer(_identity, incomingSynchroData):
	if get_node_or_null(_identity):
		get_node(_identity).Synchro = incomingSynchroData
		get_node(_identity).emit_signal('updateFacing')
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local")
func synchronizeOnClients(_identity, _coords):
	pass
