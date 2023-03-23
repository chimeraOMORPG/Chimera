extends Node

var network = ENetMultiplayerPeer.new()
var PlayerScene = preload("res://Scenes/Character/Character.tscn")
var server_portINI: int = 4242
var max_playersINI: int = 100

func _ready():
	pass
	
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
		
func playerConnected(id : int) -> void:
	prints("New player connected with ID:", id)
	#implementare regole di sicurezza + banning
#	await get_tree().create_timer(10).timeout
#	if not get_node('/root/main/Characters').get_children().is_empty():
#		for i in get_node('/root/main/Characters').get_children():
#			if i.name == str(id):
#				return
#			else:
#				prints('The client ID', id, 'did not provide a valid token, disconnecting')
#	network.disconnect_peer(id)
	
@rpc("any_peer")				
func create_player():
	var clientID = multiplayer.get_remote_sender_id()
	# Instantiate a new player for this client.
	var p = PlayerScene.instantiate()
	# Set the name, so players can figure out their local authority
	p.name = str(clientID)
	get_node("/root/main/Characters").add_child(p)
	prints("New character created for player ID:", clientID)
#	var error = rpc_id(clientID, 'startGame')
#	if error != OK:
#		print('Error during rpc startGame from game server')

func playerDisconnected(id : int) -> void:
	destroy_player(id)

func destroy_player(id : int) -> void:
	prints("Player ID:", id, " disconnected")
	for i in get_node('/root/main/Characters').get_children():
		if i.name == str(id):
			get_node("/root/main/Characters").get_node(str(i)).queue_free()
			prints('Player ID', id, 'character istance destroyed')
			break

@rpc("any_peer")
func tokenVerification(token):
	print('Player token received, start matching...')
	var clientID = multiplayer.get_remote_sender_id()
	var current_Time: int = Time.get_unix_time_from_system()
	var tokenTime = int(token.right(10))
	if not get_node('/root/main/Characters').get_children().is_empty():
		for i in get_node('/root/main/Characters').get_children():
			if i.name == str(clientID):
				return
			else:
				prints('The client ID', id, 'did not provide a valid token, disconnecting')
	network.disconnect_peer(id)

	while not get_node('/root/main/Characters').get_children().all(get('name')).has(clientID):
		print('Invalid or unknow token, waiting a little bit for the authentication server send me...')
#		await get_tree().create_timer(2).timeout
#
#		rpc_id(clientID, 'playerVerified')
#
#		else:
#			print('Client\'s token verified!')
#
#			current_Time = Time.get_unix_time_from_system()
#

#	if current_Time - tokenTime >= 30:
#		print('Invalid token, expired, disconnecting')
#	elif not get_node("/root/main/tokenExpiration").availableTokens.has(token):
#		print('Invalid token, unknown, disconnecting')
#	else:
#		print('Client\'s token verified!')
#		rpc_id(clientID, 'playerVerified')

@rpc("call_local")
func playerVerified():
	pass
