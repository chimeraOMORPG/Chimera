extends Node

var network = ENetMultiplayerPeer.new()
var Place: String = "01-daisy-garden"#Il luogo deve essere passato dall'auth server
var CharacterScene = preload("res://Scenes/Character/Character.tscn")
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

func playerDisconnected(id : int) -> void:
	prints("Player ID:", id, " disconnected")
	get_node('/root/World').destroy_player(id)

@rpc("any_peer")
func tokenVerification(token):
	print('Player token received, start matching...')
	var clientID = multiplayer.get_remote_sender_id()
		#If verified:
	var result = await get_node('/root/World').addScene(Place)
	if result:
		create_player(clientID)
		pass
	else:
		print('Error adding scene...')

func create_player(clientID):
#	var clientID = multiplayer.get_remote_sender_id()
	var x = CharacterScene.instantiate()
#	x.set_position(Vector2(randi_range(0, 1920), randi_range(0, 1080)))
	x.set_name(str(clientID))# Set the name, so players can figure out their local authority
	get_node('/root/World/01-daisy-garden/Characters').add_child.call_deferred(x, true)#*************** risolvere!!!
	prints("New character created for player ID:", clientID)

