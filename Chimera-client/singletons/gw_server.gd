extends Node

@export var gateway_server: String = "127.0.0.1" #FQDN must used if you want TLS to work; of course you can use ip for tests
@export var gateway_server_port: int = 4241
var encryption: bool = false
var network = ENetMultiplayerPeer.new()
var gateway = SceneMultiplayer.new()
var username: String
var password: String

func _ready():
	pass

func _process(_delta):
	if get_tree().get_multiplayer("/root/Gatewayserver")==null:
		return
	if not get_tree().get_multiplayer("/root/Gatewayserver").multiplayer_peer.get_connection_status():
		return
	get_tree().get_multiplayer("/root/Gatewayserver").poll()	
	
func ConnectToServer(_username, _password):
	username = _username
	password = _password
	network.create_client(str(gateway_server), gateway_server_port)
	get_tree().set_multiplayer(gateway, self.get_path())
	if encryption:
		print('TLS enabled')
		var client_tls_options = TLSOptions.client()
		# l'host qui sotto deve essere dinamico, inviato dal server di authenticazione in base all'ultima posizione
		# registrata del character
		var error = network.get_host().dtls_client_setup(gateway_server, client_tls_options)
		prints('errore:', error)
	else:
		print('TLS disabled')
	multiplayer.set_multiplayer_peer(network)
	if not multiplayer.connected_to_server.is_connected(connected):
		multiplayer.connected_to_server.connect(self.connected)
	if not multiplayer.connection_failed.is_connected(failed):
		multiplayer.connection_failed.connect(self.failed)
	if not multiplayer.server_disconnected.is_connected(disconnected):
		multiplayer.server_disconnected.connect(self.disconnected)

func connected():
	var myid = multiplayer.get_unique_id()
	print("Game client connected to gateway server with ID " + str(myid))
	
func failed():
	print("Game client Failed to connect to gateway server")
	get_node("/root/Main_menu/connect").disabled = false
	get_node("/root/Main_menu/AudioStreamPlayer2").play()
	get_node("/root/Main_menu/warning").text = "Connection failed"
	get_node("/root/Main_menu/warning").show()
	get_node("/root/Main_menu/spinner").process_mode = Node.PROCESS_MODE_DISABLED
	get_node("/root/Main_menu/spinner").visible = false

func disconnected():
	print("Game client disconnected from gateway server")
	get_node("/root/Main_menu/connect").disabled = false
	get_node("/root/Main_menu/AudioStreamPlayer2").play()
	get_node("/root/Main_menu/warning").text = "Connection failed"
	get_node("/root/Main_menu/warning").show()
	get_node("/root/Main_menu/spinner").process_mode = Node.PROCESS_MODE_DISABLED
	get_node("/root/Main_menu/spinner").visible = false

@rpc("call_remote")
func LoginRequest(IPDataReponse = null):
	get_node("/root/Main_menu/RealTime").visible = false
	if IPDataReponse != null and not IPDataReponse.is_empty():
		get_node("/root/Main_menu/RealTime").text = str(IPDataReponse)
		get_node("/root/Main_menu/RealTime").visible = true
		print(IPDataReponse)
	rpc_id(1, "login", username, password)
	print("Trying to log in...")
	username = ""
	password = ""

@rpc("call_remote")
func ResultLoginRequest(result, desc, token, gameserver):
	multiplayer.connected_to_server.disconnect(self.connected)
	multiplayer.connection_failed.disconnect(self.failed)
	multiplayer.server_disconnected.disconnect(self.disconnected)
	print("login result received: " + desc)
	if result:
		Gameserver.ConnectToServer(gameserver, token)
	else:
		get_node("/root/Main_menu/connect").disabled = false
		get_node("/root/Main_menu/AudioStreamPlayer2").play()
		get_node("/root/Main_menu/warning").text = "Connection failed"
		get_node("/root/Main_menu/warning").show()
		get_node("/root/Main_menu/spinner").process_mode = Node.PROCESS_MODE_DISABLED
		get_node("/root/Main_menu/spinner").visible = false

@rpc("call_local")	
func login(_username, _password):
	pass


