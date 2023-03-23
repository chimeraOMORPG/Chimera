extends Node

var auth_serverINI: String = "chimeragw.nikoh.it" #FQDN must used if you want TLS to work; of course you can use ip for tests
var auth_server_portINI: int = 11113
var nameServer: String = "Chimera_one"
var network = ENetMultiplayerPeer.new()
var gateway = SceneMultiplayer.new()

func _ready():
	await Settings.settingsLoaded
	ConnectToServer()

func _process(_delta):
	pass

func ConnectToServer():
	if (auth_serverINI != null and !auth_serverINI.is_empty()) and auth_server_portINI != null:
		var error = network.create_client(str(auth_serverINI), auth_server_portINI)
		if error == OK:
			get_tree().set_multiplayer(gateway, self.get_path())
			multiplayer.set_multiplayer_peer(network)
			print('connecting to authentication server...')
			if not multiplayer.connected_to_server.is_connected(connected):
				multiplayer.connected_to_server.connect(self.connected)
			if not multiplayer.connection_failed.is_connected(failed):
				multiplayer.connection_failed.connect(self.failed)
			if not multiplayer.server_disconnected.is_connected(disconnected):
				multiplayer.server_disconnected.connect(self.disconnected)
		else:
			prints('Error creating client:', error)
	else:
		print('Please provide authentication server and port')
		
func connected():
	print("Game server connected to authentication server")
	var error = rpc_id(1, "announceToAuthserver", nameServer)
	if error != OK:
		prints('This error has occurred during announcing:', error)
	
func failed():
	prints("Failed to connect to", auth_serverINI, "authentication server")
	print('Quitting...')
	await get_tree().create_timer(0.5).timeout	
	self.get_tree().quit()
	
func disconnected():
	print("Game server disconnected from authentication server")
	if get_node("/root/GameserverClient").multiplayer.is_server():
		prints('Shutdowning this game server...')
		get_node("/root/GameserverClient").multiplayer.set_multiplayer_peer(null)
		print('Quitting...')
	await get_tree().create_timer(0.5).timeout	
	self.get_tree().quit()
	
@rpc("call_local")
func announceToAuthserver(nameServer):
	pass
	
@rpc("any_peer")
func wellcome():
	GameserverClient.StartServer()

@rpc("any_peer")
func tokenPassed(token):
	get_node("/root/main/tokenExpiration").availableTokens.append(token)



