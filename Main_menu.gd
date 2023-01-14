extends Control
#@export var PlayerScene = preload("res://Player.tscn")
@export var server_port: int = 4242
var server_ip = null
var peer = ENetMultiplayerPeer.new()

func _ready():
	pass
	
func ConnectToServer():
	peer.create_client(str(server_ip), server_port)
	multiplayer.connected_to_server.connect(self.connected)
	multiplayer.connection_failed.connect(self.failed)
	multiplayer.server_disconnected.connect(self.disconnected)
	multiplayer.set_multiplayer_peer(peer)

func connected():
	$spinner.process_mode = false
	$spinner.visible = false
	get_tree().change_scene_to_file("res://main.tscn")
	
func failed():
	$AudioStreamPlayer2.play()
	$warning.text = "Connection failed"
	$warning.show()
	$connect.show()
	$spinner.process_mode = false
	$spinner.visible = false
	
func disconnected():
	print("Disconnected")

func _on_button_pressed():
	if server_ip != null and server_ip != "":
		ConnectToServer()
		$connect.hide()
		$warning.hide()
		$spinner.process_mode = true
		$spinner.visible = true
		
	elif server_ip == "":
		$AudioStreamPlayer2.play()
		$warning.text = "Please fill server address field (maybe chimera.nikoh.it?)"
		$warning.show()	
	else: 
		$AudioStreamPlayer2.play()
		$warning.text = "Please insert a valid server address (maybe chimera.nikoh.it?)"
		$warning.show()	
	
func _on_indirizzo_ip_text_changed(new_text):
	server_ip = str(new_text)
	print(server_ip)
