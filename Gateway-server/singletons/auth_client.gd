extends Node

var auth_server_ipINI: String
var auth_server_portINI: int = 4243
var network = ENetMultiplayerPeer.new()
var username: String
var password: String
var incoming_id: int

func _ready():
	await Settings.settingsLoaded
	pass

func ConnectToServer(_username, _password, _incoming_id):
	if auth_server_ipINI:
		username = _username
		password = _password
		incoming_id = _incoming_id
		network.create_client(str(auth_server_ipINI), auth_server_portINI)
		multiplayer.set_multiplayer_peer(network)
		if not multiplayer.connected_to_server.is_connected(connected):
			multiplayer.connected_to_server.connect(self.connected)
		if not multiplayer.connection_failed.is_connected(failed):
			multiplayer.connection_failed.connect(self.failed)
		if not multiplayer.server_disconnected.is_connected(disconnected):
			multiplayer.server_disconnected.connect(self.disconnected)
	else:
		print('Please insert an authentication server on settings.ini')

func connected():
	print("Gateway client connected to authentication server, sending datas and request to authentication server")
	rpc_id(1, "Authenticate", username, password, incoming_id)
	
func failed():
	print("Failed to connect to authentication server")
	var desc = "Authentication failed, unable to connect to authentication server"
	Gwserver.ReturnLoginRequest(false, incoming_id, desc, null, null)

func disconnected():
	print("Gateway client disconnected from authentication server")

@rpc("call_local")
func Authenticate(_username, _password, _player_id):
	pass

@rpc("call_remote")
func AuthenticationResult(result, player_id, desc, token, gameserver):
	print("Result received and replying to player login request")
	Gwserver.ReturnLoginRequest(result, player_id, desc, token, gameserver)

