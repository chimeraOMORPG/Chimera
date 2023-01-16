extends Control

var game_server_ip = null

func _ready():
	pass

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
	if game_server_ip != null and game_server_ip != "":
		Gameserver.ConnectToServer()
		$connect.hide()
		$warning.hide()
		$spinner.process_mode = true
		$spinner.visible = true
		
	elif game_server_ip == "":
		$AudioStreamPlayer2.play()
		$warning.text = "Please fill server address field"
		$warning.show()	
	else: 
		$AudioStreamPlayer2.play()
		$warning.text = "Please insert a valid server address"
		$warning.show()	
	
func _on_indirizzo_ip_text_changed(new_text):
	game_server_ip = str(new_text)
	print(game_server_ip)
