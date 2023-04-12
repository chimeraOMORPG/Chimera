extends Node

var server_portINI: int = 11113
var max_gameserversINI: int = 1
var network = ENetMultiplayerPeer.new()
var gameserver = SceneMultiplayer.new()
var list: String = 'gameServerList'
var staleTimeINI: int = 2 #Elapsed time (in seconds) to consider requests expired
var connected: Dictionary

func _ready():
	await Settings.settingsLoaded
	StartServer()

func _process(_delta):
	pass

func StartServer():
	var error = network.create_server(server_portINI, max_gameserversINI)
	if error == OK:
		get_tree().set_multiplayer(gameserver, self.get_path())
		multiplayer.set_multiplayer_peer(network)
		multiplayer.peer_connected.connect(self.gameServer_connected)
		multiplayer.peer_disconnected.connect(self.gameServer_disconnected)
		prints('Authentication server listening on '+str(server_portINI), 'for game servers')
	else:
		prints('Error creating server', error)

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
			connected[gameserver_id] = {'verified': false, 'nameserver': null}
			await get_tree().create_timer(staleTimeINI).timeout
			if self.multiplayer.get_peers().has(gameserver_id) and connected.get(gameserver_id).verified != true:
				prints('Game server', gameserver_id, 'provided no nameServer, staled request, (announceToAuthserver has not called) disconnecting...')
				network.disconnect_peer(gameserver_id)
			
func gameServer_disconnected(gameserver_id):
	prints("Game server", gameserver_id, "disconnected")
	connected.erase(gameserver_id)
	for i in ServerData.gameServerList:
		if ServerData.gameServerList.get(i).get('ID') == gameserver_id:
			ServerData.gameServerList.get(i).erase('ID')
			break

func pushToken(gameserver, token, gameserverName):
	if gameserver.get("ID") != null:
		if multiplayer.get_peers().has(gameserver.get("ID")):
			var error = rpc_id(int(gameserver.get("ID")), "tokenPassed", token)
			if error != OK:
				print('An error occurred calling tokenPassed on a game server')
	else:
		prints(gameserverName, 'game server not connected, unable to send him the player token')
#
@rpc("any_peer")
func announceToAuthserver(nameServer):
	var xIP: String = self.network.get_peer(multiplayer.get_remote_sender_id()).get_remote_address()
	if ServerData.gameServerList.has(nameServer):
		var yIP = IP.resolve_hostname(ServerData.gameServerList.get(nameServer).get('url'), 1)
		if not yIP.is_empty():
			if ServerData.gameServerList.get(nameServer).get('ID') == null:
				if xIP == yIP:
					ServerData.gameServerList.get(nameServer).ID = multiplayer.get_remote_sender_id()
					connected.get(multiplayer.get_remote_sender_id()).nameserver = nameServer
					connected.get(multiplayer.get_remote_sender_id()).verified = true
					prints('OK', nameServer, 'game server connected')
					var error = rpc_id(multiplayer.get_remote_sender_id(), 'wellcome')
					if error != OK:
						print('Error calling wellcome rpc')
				else:
					prints(nameServer, 'has a different IP address, disconnecting...')
					gameserver.disconnect_peer(multiplayer.get_remote_sender_id())
			else:
				prints(nameServer, 'already connected, disconnecting...')
				gameserver.disconnect_peer(multiplayer.get_remote_sender_id())
		else:
			prints(nameServer, 'unresolvable, disconnecting...')
			gameserver.disconnect_peer(multiplayer.get_remote_sender_id())
	else:
		prints(nameServer, 'is not a valid name of any game server, disconnecting...')
		gameserver.disconnect_peer(multiplayer.get_remote_sender_id())

@rpc("reliable", "call_local")
func wellcome():
	pass

@rpc("call_local")
func tokenPassed(token):
	pass
