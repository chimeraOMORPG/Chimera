extends Node

@rpc("any_peer")
func chiamata():
	var chiamante = multiplayer.get_remote_sender_id()
	print("chiamata in arrivo da "+str(chiamante))

