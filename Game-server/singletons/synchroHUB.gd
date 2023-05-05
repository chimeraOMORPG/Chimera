extends Node

func toClients(_identity, coords, faceDirection):
	for i in get_node(_identity).get_parent().characterList:
		rpc_id(i, 'synchronizeOnClients', _identity, coords, faceDirection)

@rpc("any_peer", "unreliable")
func synchronizeOnServer(_identity, incomingSynchroData):
	if get_node_or_null(_identity):
		var direction = incomingSynchroData.direction
		var input = incomingSynchroData.input
		if get_node(_identity).get('Synchro').has('input'):
			if input != get_node(_identity).get('Synchro').get('input'):
				print('diverso')
				get_node(_identity).Synchro['input'] = input
				print(get_node(_identity).Synchro['input'])
				print(get_node(_identity).eventList)
				get_node(_identity).facing()
		else:
			get_node(_identity).Synchro['input'] = input
		
		get_node(_identity).Synchro['direction'] = direction
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local")
func synchronizeOnClients(_identity, _coords):
	pass
