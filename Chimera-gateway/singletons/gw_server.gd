extends Node

var server_portINI: int = 4241
var max_playersINI: int
var network = ENetMultiplayerPeer.new()
var gateway = SceneMultiplayer.new()
var staleTimeINI: int = 2 #Elapsed time (in seconds) to consider requests expired
var encryptionINI: bool = true #True/false enable/disable login data encryption
var keyINI: String # Your private key.
var certINI: String # Your X509 certificate.

func _ready():
	await Settings.settingsLoaded
	StartServer()

func _process(_delta):
	if not get_tree().get_multiplayer("/root/Gwserver").multiplayer_peer.get_connection_status():
		return
	get_tree().get_multiplayer("/root/Gwserver").poll()	

func StartServer():
	network.create_server(server_portINI,max_playersINI)
	get_tree().set_multiplayer(gateway, self.get_path())
	if encryptionINI and FileAccess.file_exists(keyINI) and FileAccess.file_exists(certINI):
		var server_tls_options = TLSOptions.server(load(keyINI), load(certINI))
		network.get_host().dtls_server_setup(server_tls_options)
		print('TLS enabled')
	else:
		print('TLS disabled')
	multiplayer.set_multiplayer_peer(network)
	multiplayer.peer_connected.connect(self.Player_connected)
	multiplayer.peer_disconnected.connect(self.Player_disconnected)
	print('Gateway server listening on '+str(server_portINI))

func Player_connected(player_id):
	print("New game client connected with ID: "+str(player_id))
	var callerIP = self.network.get_peer(player_id).get_remote_address()
	if not Security.baseIPcheck(callerIP):#This check is always made
		prints(callerIP + 'formally invalid ip, disconnecting!')
		gateway.disconnect_peer(player_id)
	elif Security.bannedIP.has(callerIP):
		prints(callerIP, "is a BANNED IP, disconnecting!")
		gateway.disconnect_peer(player_id)
	else:
		var dummy: Dictionary = await Security.verify(callerIP)
		if dummy["result"]:
			print("IP address check failed, disconnecting!")
			gateway.disconnect_peer(player_id)
		else:
			print('IP address check completed successfully, continuing to login...')
			rpc_id(player_id, "LoginRequest", dummy["IPDataReponse"])
			await get_tree().create_timer(staleTimeINI).timeout
			var desc = "Authentication failed, staled request..."
			ReturnLoginRequest(false, player_id, desc, null, null)
			
func Player_disconnected(player_id):
	print("Game client "+str(player_id)+" disconnected")

func ReturnLoginRequest(result, player_id, desc, token, gameserver):
	if self.multiplayer.get_peers().has(player_id):
		rpc_id(player_id, "ResultLoginRequest", result, desc, token, gameserver)
		await get_tree().create_timer(0.5).timeout
		gateway.disconnect_peer(player_id)
	
@rpc("call_local")
func ResultLoginRequest(_result):
	pass

func incoming_rpc_ID():
	return multiplayer.get_remote_sender_id()

@rpc("any_peer")
func login(username, password):
	print("Login request received")
	Authenticate.ConnectToServer(username, password, incoming_rpc_ID())

@rpc("call_local")
func LoginRequest():
	pass
