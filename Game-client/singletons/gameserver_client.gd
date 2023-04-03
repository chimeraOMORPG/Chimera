extends Node

var game_server_port: int = 4242
var network = ENetMultiplayerPeer.new()
var token: String
var worldSceneContainer: PackedScene = preload("res://Scenes/World/World.tscn")
@export var Place: String = "01-daisy-garden"#Il luogo deve essere passato dall'auth server assieme all'url del gameserver

func _ready():
	pass

func ConnectToServer(gameserverUrl):
	#costruzione scenetree in base ai dati forniti dall'auth server
	var error = get_tree().change_scene_to_packed(worldSceneContainer)
	if error != OK:
		print('Error changing scene to World')
	print('Connecting to game server, please wait...')
	get_node("/root/Main_menu/warning").text = "Connecting to game server, please wait..."
	var error = network.create_client(gameserverUrl, game_server_port)
	if error == OK:
		multiplayer.set_multiplayer_peer(network)
		if not multiplayer.connected_to_server.is_connected(connected):
			multiplayer.connected_to_server.connect(self.connected)
		if not multiplayer.connection_failed.is_connected(failed):
			multiplayer.connection_failed.connect(self.failed)
		if not multiplayer.server_disconnected.is_connected(disconnected):
			multiplayer.server_disconnected.connect(self.disconnected)
	else:
		prints('Error creating client', error)
		
func connected():
	print("Game client connected to game server")
	print('Start verification pushing token...')
	var error = rpc_id(1, 'tokenVerification', token)
	if error != OK:
		print('Error during rpc playerVerification from game client')

func failed():
	print("Whenever authenticated, failed to connect to game server")
	get_node("/root/Main_menu/connect").disabled = false
	get_node("/root/Main_menu/AudioStreamPlayer2").play()
	get_node("/root/Main_menu/warning").text = "Whenever authenticated, failed to connect to game server"
	get_node("/root/Main_menu/spinner").process_mode = Node.PROCESS_MODE_DISABLED
	get_node("/root/Main_menu/spinner").visible = false
	
func disconnected():
	print("Disconnected from game server")
	get_tree().change_scene_to_file("res://Scenes/Main_menu/Main_menu.tscn")
	await get_tree().create_timer(0.5).timeout
	get_node("/root/Main_menu/warning").text = "Disconnected from game server"

#@rpc("any_peer")
#func playerVerified():
#	print('Ok, token authenticated, starting game...')
#	var error = rpc_id(1, 'create_player')
#	if error != OK:
#		print('Error during rpc create_player from game client')
	
#@rpc("call_local")
#func create_player():
#	pass

@rpc("call_local")
func tokenVerification(token):
	pass

