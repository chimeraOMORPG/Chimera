extends Node

var game_server_port: int = 4242
var network = ENetMultiplayerPeer.new()
var token: String
var worldSceneContainer: PackedScene = preload("res://Scenes/World/World.tscn")
@export var Place: String = "01-daisy-garden"#Il luogo deve essere passato dall'auth server assieme all'url del gameserver

func _ready():
	await Settings.settingsLoaded

func ConnectToServer(gameserverUrl):
	#costruzione scenetree in base ai dati forniti dall'auth server
	var error = get_tree().change_scene_to_packed(worldSceneContainer)
	if error != OK:
		print('Error changing scene to World')
	prints('Connecting to', gameserverUrl, 'game server, please wait...')
	get_node("/root/Main_menu/LoginForm/WarningMessage").text = "Connecting to game server, please wait..."
	var error2 = network.create_client(gameserverUrl, game_server_port)
	if error2 == OK:
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
	var error = get_tree().change_scene_to_file("res://Scenes/Main_menu/Main_menu.tscn")
	if error != OK:
		print('Error changing scene to Main_menu')
	while get_node_or_null("/root/Main_menu/LoginForm/WarningMessage") == null:
		print('Changing scene...')
		await get_tree().create_timer(0.1).timeout
	get_node("/root/Main_menu/LoginForm/WarningMessage").text = "Disconnected from game server"
	get_node("/root/Main_menu/LoginForm/Inputs/Connect").disabled = false
	get_node("/root/Main_menu/LoginForm/FailureSound").play()
	get_node("/root/Main_menu/LoginForm/WarningMessage").text = "Whenever authenticated, failed to connect to game server"
	get_node("/root/Main_menu/LoginForm/LoadingAnimation").process_mode = Node.PROCESS_MODE_DISABLED
	get_node("/root/Main_menu/LoginForm/LoadingAnimation").visible = false
	
func disconnected():
	print("Disconnected from game server")
	var error = get_tree().change_scene_to_file("res://Scenes/Main_menu/Main_menu.tscn")
	if error != OK:
		print('Error changing scene to Main_menu')
	while get_node_or_null("/root/Main_menu/LoginForm/WarningMessage") == null:
		print('Changing scene...')
		await get_tree().create_timer(0.1).timeout
	get_node("/root/Main_menu/LoginForm/FailureSound").play()
	get_node("/root/Main_menu/LoginForm/WarningMessage").text = "Disconnected from game server"
	
@rpc("call_local")
func tokenVerification(token):
	pass

