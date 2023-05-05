extends Node

func toServer(_identity, Synchro):
	rpc_id(1, 'synchronizeOnServer', _identity, Synchro)

@rpc("authority", "unreliable")
func synchronizeOnClients(_identity, coords, faceDirection):
	if get_node_or_null(_identity):
		get_node(_identity).set('position', coords)
		if faceDirection != 'none':
			get_node(_identity + '/CHAnimatedSprite2D').play(faceDirection)
#		else:
#			get_node(_identity + '/CHAnimatedSprite2D').play((get_node(_identity + '/CHAnimatedSprite2D').animation).trim_prefix("walk_"))
#			$CHAnimatedSprite2D.play("idle_" + ($CHAnimatedSprite2D.animation).trim_prefix("walk_"))
	else:
		prints(_identity, 'not found to synchronize his data, probably is changing zone')

@rpc("call_local", "unreliable")
func synchronizeOnServer(_Synchro):
	pass
