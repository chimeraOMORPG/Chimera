extends Node

func toClients(_identity, coords):
	for i in get_node(_identity).get_parent().characterList:
		rpc_id(i, 'synchronizeOnClients', _identity, coords)

@rpc("any_peer", "unreliable")
func synchronizeOnServer(_identity, incomingSynchroData):
	if get_node_or_null(_identity):
		get_node(_identity).set('Synchro', incomingSynchroData)
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local")
func synchronizeOnClients(_identity, coords):
	pass
