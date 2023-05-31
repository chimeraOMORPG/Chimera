extends Node

func toServer(identity, Synchro):
	rpc_id(1, 'synchronizeOnServer', identity, Synchro)

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

@rpc("call_local", "unreliable")
func synchronizeOnServer(_Synchro):
	pass

@rpc("call_local","reliable")
func justSpawned(identity):
	pass


