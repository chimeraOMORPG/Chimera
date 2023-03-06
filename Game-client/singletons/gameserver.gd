extends Node

@export var game_server_port: int = 4242
var network = ENetMultiplayerPeer.new()

func ConnectToServer(gameserverUrl, token):
	network.create_client(gameserverUrl, game_server_port)
	multiplayer.set_multiplayer_peer(network)
	if not multiplayer.connected_to_server.is_connected(connected):
		multiplayer.connected_to_server.connect(self.connected)
	if not multiplayer.connection_failed.is_connected(failed):
		multiplayer.connection_failed.connect(self.failed)
	if not multiplayer.server_disconnected.is_connected(disconnected):
		multiplayer.server_disconnected.connect(self.disconnected)

func connected():
	print("Game client connected to game server")
	get_tree().change_scene_to_file("res://Scenes/Main/main.tscn")
	
func failed():
	print("Whenever authenticated, failed to connect to game server")
	get_node("/root/Main_menu/connect").disabled = false
	get_node("/root/Main_menu/AudioStreamPlayer2").play()
	get_node("/root/Main_menu/warning").text = "Whenever authenticated, failed to connect to game server"
	get_node("/root/Main_menu/warning").show()
	get_node("/root/Main_menu/spinner").process_mode = Node.PROCESS_MODE_DISABLED
	get_node("/root/Main_menu/spinner").visible = false
	
func disconnected():
	print("Disconnected from game server")
	get_tree().change_scene_to_file("res://Scenes/Main_menu/Main_menu.tscn")
	waiting()

func waiting():
	print("start")
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(self._on_timer_timeout)
func _on_timer_timeout():
	print("end")
	get_node("../Main_menu/connect")
