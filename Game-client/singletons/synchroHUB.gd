extends Node

func toServer(_identity, Synchro):
	rpc_id(1, 'synchronizeOnServer', _identity, Synchro)

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
