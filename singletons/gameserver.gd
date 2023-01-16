extends Node

@export var game_server_port: int = 4242
var network = ENetMultiplayerPeer.new()

func ConnectToServer():
	network.create_client(str(get_node("/root/Main_menu").game_server_ip), game_server_port)
	multiplayer.set_multiplayer_peer(network)
	multiplayer.connected_to_server.connect(get_node("/root/Main_menu").connected)
	multiplayer.connection_failed.connect(get_node("/root/Main_menu").failed)
	multiplayer.server_disconnected.connect(get_node("/root/Main_menu").disconnected)
