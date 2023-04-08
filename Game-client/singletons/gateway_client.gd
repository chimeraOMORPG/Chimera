extends Node

@export var gateway_serverINI: String = "chimera.nikoh.it" #FQDN must used if you want TLS to work; of course you can use ip for tests
@export var gateway_server_portINI: int = 4241
var encryptionINI: bool = true
var network = ENetMultiplayerPeer.new()
var gateway = SceneMultiplayer.new()
var username: String
var password: String
@export var devmodeINI: bool = false

func _ready():
	await Settings.settingsLoaded

func _process(_delta):
	pass
	
func ConnectToServer(_username, _password):
	print('Connecting to gateway server, please wait...')
	get_node("/root/Main_menu/warning").text = "Connecting to gateway server, please wait..."
	username = _username
	password = _password
	var error = network.create_client(str(gateway_serverINI), gateway_server_portINI)
	if error == OK:
		get_tree().set_multiplayer(gateway, self.get_path())
		if encryptionINI:
			print('TLS enabled')
			var client_tls_options = TLSOptions.client()
			network.get_host().dtls_client_setup(gateway_serverINI, client_tls_options)
		else:
			print('TLS disabled')
		multiplayer.set_multiplayer_peer(network)
		if not multiplayer.connected_to_server.is_connected(connected):
			multiplayer.connected_to_server.connect(self.connected)
		if not multiplayer.connection_failed.is_connected(failed):
			multiplayer.connection_failed.connect(self.failed)
		if not multiplayer.server_disconnected.is_connected(disconnected):
			multiplayer.server_disconnected.connect(self.disconnected)
	else:
		prints('Error creating client', error)
		
func connected():
	get_node("/root/Main_menu/warning").text = ''
	var myid = multiplayer.get_unique_id()
	prints("Game client connected to gateway server with ID", myid)
	
func failed():
	print("Game client Failed to connect to gateway server")
	get_node("/root/Main_menu/warning").text = "Connection failed"
	canReconnect()

func disconnected():
	if GameserverClient.network.get_connection_status() == 0:
		get_node("/root/Main_menu/warning").text = "Connection failed"
		canReconnect()
		
func canReconnect() -> void:
	get_node("/root/Main_menu/connect").disabled = false
	get_node("/root/Main_menu/AudioStreamPlayer2").play()
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
func ResultLoginRequest(result, desc, token, gameserverUrl):
	print("login result received: " + desc)
	if result:
		prints('Token received', token)
		GameserverClient.set('token', token)
		GameserverClient.ConnectToServer(gameserverUrl)

@rpc("call_local")	
func login(_username, _password):
	pass


