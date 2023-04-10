extends Control

@onready var username_input = get_node("AuthUser")
@onready var password_input = get_node("AuthPassword")
@onready var login_button = get_node("connect")
var devmode: bool:
	get:
		return GatewayClient.devmodeINI

func _ready():
	$MainTheme.stream.set_loop(true)
	if devmode:
		print('ciao')
		$warning.set_text('DEVMODE ENABLED')

func _on_login_button_pressed():
	if username_input.text == "" or password_input.text == "":
		$AudioStreamPlayer2.play()
		$warning.text = "Please fill all fields"
	else: 	
		$connect.disabled = true
		if devmode:
			GatewayClient.ResultLoginRequest(true, 'DEVMODE enabled', str(int(Time.get_unix_time_from_system())), '127.0.0.1')
		else:
			GatewayClient.ConnectToServer(username_input.get_text(), password_input.get_text() )
			$spinner.process_mode = Node.PROCESS_MODE_ALWAYS
			$spinner.visible = true

@rpc("call_remote")
func printIPData(data):
	pass
