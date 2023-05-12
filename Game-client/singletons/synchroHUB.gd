extends Node

func toServer(path, Synchro):
	Synchro['time'] = Time.get_unix_time_from_system()
	rpc_id(1, 'synchronizeOnServer', path, Synchro)

func synchroAtReady(path):
	rpc_id(1, 'justSpawned', path)

@rpc("authority", "unreliable")
func synchronizeOnClients(_identity, coords, faceDirection):
	if get_node_or_null(_identity):
		if coords:
			get_node(_identity).set('coords', coords)
		if faceDirection:
			get_node(_identity).set('faceDirection', faceDirection)
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local", "unreliable")
func synchronizeOnServer(_Synchro):
	pass

@rpc("call_local","reliable")
func justSpawned(_identity):
	pass
