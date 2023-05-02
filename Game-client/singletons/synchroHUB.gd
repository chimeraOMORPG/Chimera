extends Node

var _Iam:
	get:
		return GameserverClient.multiplayer.get_unique_id()
			
@export var Synchro: Dictionary = {
	'direction': Vector2.ZERO
}

func _process(delta):
	if _Iam != null:
		prints('diverso da null', _Iam)
	else:
		print('nullo')
#		if self.name.to_int() == _Iam:
#			Synchro.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#			rpc_id(1, '_synchronize', Synchro)

@rpc("call_local", "unreliable")
func _synchronize(Synchro):
	pass
