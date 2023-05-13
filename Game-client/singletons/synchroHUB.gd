extends Node

func toServer(path, tempSynchro):
	rpc_id(1, 'synchronizeOnServer', path, tempSynchro)

func synchroAtReady(path):
	rpc_id(1, 'justSpawned', path)

@rpc("authority", "unreliable")
func synchronizeOnClients(_identity, incomingSynchro):
	if get_node_or_null(_identity):
		if get_node(_identity).Synchro.T < incomingSynchro.T:
			if incomingSynchro.has('C'):
				get_node(_identity).get('Synchro').C = incomingSynchro.C
			if incomingSynchro.has('F'):
				get_node(_identity).get('Synchro').F = incomingSynchro.F
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local", "unreliable")
func synchronizeOnServer(_Synchro):
	pass

@rpc("call_local","reliable")
func justSpawned(_identity):
	pass
