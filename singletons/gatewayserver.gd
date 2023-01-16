extends Node

@export var gateway_server_ip = "127.0.0.1"
@export var gateway_server_port: int = 4241
var network = ENetMultiplayerPeer.new()
var gateway = SceneMultiplayer.new()

func _ready():
	ConnectToServer()

func _process(delta):
	if get_tree().get_multiplayer("/root/Gatewayserver")==null:
		return
	if not get_tree().get_multiplayer("/root/Gatewayserver").multiplayer_peer.get_connection_status():
		return
	get_tree().get_multiplayer("/root/Gatewayserver").poll()	
	
func ConnectToServer():
	network.create_client(str(gateway_server_ip), gateway_server_port)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(network)
	multiplayer.connected_to_server.connect(self.connected)
	multiplayer.connection_failed.connect(self.failed)
	multiplayer.server_disconnected.connect(self.disconnected)

func connected():
	print("Game client connected to gateway server")

func failed():
	print("Game client Failed to connect to gateway server")

func disconnected():
	print("Game client disconnected from gateway server")
