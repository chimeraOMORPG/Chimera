extends Node

func toClients(_identity, coords, faceDirection):
	for i in get_node(_identity).get_parent().characterList:
#		if get_tree().get_multiplayer().get_peers().has(i):
#		if get_node(_identity).is_queued_for_deletion():
			rpc_id(i, 'synchronizeOnClients', _identity, coords, faceDirection)

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
