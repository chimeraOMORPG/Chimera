extends Node

var network = ENetMultiplayerPeer.new()
var Place: String:
	get:
		return AuthGameserver.Place
var server_portINI: int = 4242
var max_playersINI: int = 100
var staleTime: int: #Elapsed time (in seconds) to consider requests expired, MUST be greater than $latency
	get:
		return latency + 1
var latency: int = 2 #(max) Time required (to wait) to receive token from auth server
var connected: Dictionary
var devmode: bool:
	get:
		return AuthGameserver.devmodeINI

func _ready():
	await Settings.settingsLoaded
	
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
		
func playerConnected(player_id : int) -> void:
	prints("New player connected with ID:", player_id)
	var callerIP = self.network.get_peer(player_id).get_remote_address()
	if not Security.baseIPcheck(callerIP):#This check is always made
		prints(callerIP + 'formally invalid ip, disconnecting!')
		network.disconnect_peer(player_id)
	elif Security.bannedIP.has(callerIP):
		prints(callerIP, "is a BANNED IP, disconnecting!")
		network.disconnect_peer(player_id)
	else:
		var dummy: Dictionary = await Security.verify(callerIP)
		if dummy["result"]:
			print("IP address check failed, disconnecting!")
			network.disconnect_peer(player_id)
		else:
			print('IP address check completed successfully, continuing to login...')
			connected[player_id] = {'verified': false}
			await get_tree().create_timer(staleTime).timeout
			if self.multiplayer.get_peers().has(player_id) and connected.get(player_id).verified != true:
				prints('Game client', player_id, 'provided no token, staled request, (tokenVerification has not called) disconnecting...')
				network.disconnect_peer(player_id)
			
func playerDisconnected(id : int) -> void:
	prints("Player ID:", id, " disconnected")
	connected.erase(id)
	get_node('/root/World').destroy_player(id)

@rpc("any_peer")
func tokenVerification(token):
	print('Player token received, start matching...')
	var clientID = multiplayer.get_remote_sender_id()
	while int(Time.get_unix_time_from_system()) - token.right(10).to_int() <= latency:
		print(TokenExpiration.availableTokens)
		if TokenExpiration.availableTokens.has(token) or devmode:
			print('Client\'s token verified!')
			var result = await get_node('/root/World').addScene(clientID, Place)
			if result:
				get_node('/root/World').create_player(clientID, Place)
				connected.get(clientID).verified = true
				return
			else:
				print('Error adding scene...')
				break
		else:
			print('Waiting a little bit for token arriving from the auth server...')
			await get_tree().create_timer(0.5).timeout
	print('Invalid or unknow token, disconnecting...')		
	network.disconnect_peer(clientID)

