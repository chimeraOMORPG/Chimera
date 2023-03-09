extends Node

var network = ENetMultiplayerPeer.new()
var server_portINI: int = 4243
var max_gatewaysINI: int = 1

func _ready():
	await Settings.settingsLoaded
	StartServer()

func StartServer():
	network.create_server(server_portINI,max_gatewaysINI)
	multiplayer.set_multiplayer_peer(network)
	multiplayer.peer_connected.connect(self.Gateway_connected)
	multiplayer.peer_disconnected.connect(self.Gateway_disconnected)
	prints('Authentication server listening on', server_portINI, 'for gateway clients')

func Gateway_connected(gateway_id):
	print("New gateway client connected with ID: "+str(gateway_id))
	var callerIP = self.network.get_peer(gateway_id).get_remote_address()
	if not Security.baseIPcheck(callerIP):#This check is always made
		prints(callerIP + 'formally invalid ip, disconnecting!')
		network.disconnect_peer(gateway_id)
	elif Security.bannedIP.has(callerIP):
		prints(callerIP, "is a BANNED IP, disconnecting!")
		network.disconnect_peer(gateway_id)
	else:
		var dummy: Dictionary = Security.verify(callerIP)
		if dummy["result"]:
			print("IP address check failed, disconnecting!")
			network.disconnect_peer(gateway_id)
		else:
			print('IP address check completed successfully, continuing...')

func Gateway_disconnected(gateway_id):
	prints("Gateway ID:", gateway_id, "disconnected")

@rpc("any_peer")
func Authenticate(username, password, player_id):
	var desc: String
	var result: bool
	var token: String
	var gameserverUrl: String
	var remote = multiplayer.get_remote_sender_id()
	print("Authentication request received, authenticating...")
	if not PlayerData.Players.has(username):
		print("User not found")
		result = false
		desc = "Authentication failed!"
	elif not PlayerData.Players[username].Password == password:
		print ("Wrong password")
		result = false
		desc = "Authentication failed!"
	else:
		var gameserver = ServerData.gameServerList[(PlayerData.Players[username].gameServer)]
		gameserverUrl = gameserver.url
		prints('Game serve is', gameserver, '@', gameserverUrl)
		desc = "Authentication successful"
		print(desc)
		result = true
		token = str(randi()).sha256_text() + str(Time.get_unix_time_from_system())
		print(token)
		Gameserver.pushToken(gameserver, token)
	print("Sending back authentication result to gateway server")
	rpc_id(remote, "AuthenticationResult", result, player_id, desc, token, gameserverUrl)
	await get_tree().create_timer(0.5).timeout
	network.disconnect_peer(remote)
	
@rpc("call_local")
func AuthenticationResult(_result, _player_id):
	pass
