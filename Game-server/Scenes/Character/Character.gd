extends CharacterBody2D

func _enter_tree():
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())
	pass
		
func _ready():
	pass
	
func incoming_rpc_id():
	var caller = str(multiplayer.get_remote_sender_id())
	return caller

@rpc("any_peer")
func chiamata():
	print("Incoming call from "+(incoming_rpc_id()))
