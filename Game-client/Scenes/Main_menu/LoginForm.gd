extends Control

signal submit(username: String, password: String)

@onready var _username_input = get_node("Inputs/Username")
@onready var _password_input = get_node("Inputs/Password")
@onready var _connect_button = get_node("Inputs/Connect")

func reportError(message: String) -> void:
	_reset_state()
	$WarningMessage.text = message
	$FailureSound.play()

func reportWarning(message: String) -> void:
	_reset_state()
	$WarningMessage.text = message

func reportInfo(message: String) -> void:
	_reset_state()
	$WarningMessage.text = message

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _reset_state() -> void:
	_connect_button.disabled = false
	$LoadingAnimation.process_mode = Node.PROCESS_MODE_DISABLED
	$LoadingAnimation.visible = false
	_username_input.text = ''
	_password_input.text = ''
	$WarningMessage.text = ''

func _set_loading_state() -> void:
	_connect_button.disabled = true	
	$LoadingAnimation.process_mode = Node.PROCESS_MODE_ALWAYS
	$LoadingAnimation.visible = true

func _on_connect_pressed():
	_set_loading_state()
	var username = _username_input.text
	var password = _password_input.text
	submit.emit(username, password)
