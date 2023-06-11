extends CharacterBody2D

const speed: int = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready 
var node_path: String = str(self.get_path())

var remote_input: Dictionary = {
	"face_direction" = 'down',
	"coords" = Vector2.ZERO
}

@export var local_input: Dictionary = {
	"direction": Vector2.ZERO,
	"key": {},
	"pressed": false,
}

func _ready():
	SynchroHub.synchronize_on_clients_signal.connect(synchronize_on_clients)
	SynchroHub.just_spawned(node_path)
	$ID.text = name
	set_process_input(false)
	if self.name.to_int() == multiplayer.get_unique_id():
		set_process_input(true)
		$connected.play()

func synchronize_on_clients(node_path_from_server, coords, face_direction): 
	if node_path != node_path_from_server:
		return
	if coords:
		remote_input.coords = coords
	if face_direction:
		remote_input.face_direction = face_direction

func _process(_delta):
	var temp = self.position
	if remote_input.coords:
		set_position(remote_input.coords)
		if temp != self.position:
			$CHAnimatedSprite2D.play('walk_' + remote_input.face_direction)
		else:
			$CHAnimatedSprite2D.play('idle_' + remote_input.face_direction)

func _input(event):
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		move(event, true)
	elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
		move(event, false)
	elif event.is_action_pressed("ui_cancel"):
		set_process_input(false)
		local_input.direction = Vector2.ZERO
		grass_step()
		SynchroHub.synchronize_on_server(node_path, local_input)
		$disconnect_confirm.show()

func move(event, pressed):
	local_input.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	local_input.key = event.as_text()
	local_input.pressed = pressed
	local_input.echo = event.is_echo()
	grass_step()
	SynchroHub.synchronize_on_server(node_path, local_input)

func grass_step():
	if local_input.direction != Vector2.ZERO: #and $disconnect_confirm.visible != true:
		if not $grass_step.is_playing():
			pass
			$grass_step.play()
	else:
		$grass_step.stop()

func _on_disconnect_confirm_confirmed():
	set_process_input(false)
	SynchroHub.disconnection_request()
	
func _on_disconnect_confirm_canceled():
	set_process_input(true)
	$disconnect_confirm.hide()


