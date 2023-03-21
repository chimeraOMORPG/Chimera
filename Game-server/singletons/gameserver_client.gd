extends Node

var network = ENetMultiplayerPeer.new()
var PlayerScene = preload("res://Scenes/Character/Character.tscn")
var server_portINI: int = 4242
var max_playersINI: int = 100

func _ready():
	pass
	
func StartServer():
	print('Starting game server')
	var error = network.create_server(server_portINI,max_playersINI)
	if error == OK:
		multiplayer.set_multiplayer_peer(network)
		multiplayer.peer_connected.connect(self.playerConnected)
		multiplayer.peer_disconnected.connect(self.playerDisconnected)
		prints('Game server listening on', server_portINI)
	else:
		prints('Error creating server', error)
		
func playerConnected(id : int) -> void:
	create_player(id)

func create_player(id : int) -> void:
	# Instantiate a new player for this client.
	var p = PlayerScene.instantiate()
	# Set the name, so players can figure out their local authority
	p.name = str(id)
	get_node("/root/main/Characters").add_child(p)
	prints("New player connected with ID:", id)

func playerDisconnected(id : int) -> void:
	destroy_player(id)

func destroy_player(id : int) -> void:
	# Delete this peer's node.
	prints("Player ID:", id, " disconnected")
	get_node("/root/main/Characters").get_node(str(id)).queue_free()
