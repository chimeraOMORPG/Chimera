extends Node

var server_portINI: int = 11113
var max_gameserversINI: int = 1
var network = ENetMultiplayerPeer.new()
var gameserver = SceneMultiplayer.new()

func _ready():
	await Settings.settingsLoaded
	await Security.allowedIPesLoaded
	StartServer()

func _process(_delta):
	if not get_tree().get_multiplayer("/root/Gameserver").multiplayer_peer.get_connection_status():
		return
	get_tree().get_multiplayer("/root/Gameserver").poll()	

func StartServer():
	network.create_server(server_portINI, max_gameserversINI)
	get_tree().set_multiplayer(gameserver, self.get_path())
	multiplayer.set_multiplayer_peer(network)
	multiplayer.peer_connected.connect(self.gameServer_connected)
	multiplayer.peer_disconnected.connect(self.gameServer_disconnected)
	prints('Authentication server listening on '+str(server_portINI), 'for game servers')

func gameServer_connected(gameserver_id):
	prints("New game server connected with ID:", gameserver_id)
	var callerIP = self.network.get_peer(gameserver_id).get_remote_address()
	if not Security.baseIPcheck(callerIP):#This check is always made
		prints(callerIP + 'formally invalid ip, disconnecting!')
		gameserver.disconnect_peer(gameserver_id)
	elif Security.bannedIP.has(callerIP):
		prints(callerIP, "is a BANNED IP, disconnecting!")
		gameserver.disconnect_peer(gameserver_id)
	else:
		var dummy: Dictionary = Security.verify(callerIP)
		if dummy["result"]:
			print("IP address check failed, disconnecting!")
			gameserver.disconnect_peer(gameserver_id)
		else:
			print('IP address check completed successfully, game server trusted and connected')
			ServerData.gameServerList['ID'] = gameserver_id
			
func gameServer_disconnected(gameserver_id):
	prints("Game server", gameserver_id, "disconnected")

func pushToken(gameserver, token):
#		rpc_id(gameserver_id, "ResultLoginRequest", token)
#		await get_tree().create_timer(0.5).timeout
#		gateway.disconnect_peer(player_id)
	pass
#
#@rpc("call_local")
#func ResultLoginRequest(_result):
#	pass
#
#func incoming_rpc_ID():
#	return multiplayer.get_remote_sender_id()
#
#@rpc("any_peer")
#func login(username, password):
#	print("Login request received")
#	Authenticate.ConnectToServer(username, password, incoming_rpc_ID())
#
#@rpc("call_local")
#func LoginRequest():
#	pass

