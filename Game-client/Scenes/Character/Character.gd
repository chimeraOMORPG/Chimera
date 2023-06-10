extends CharacterBody2D

const speed: int = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready 
var node_path: String = str(self.get_path())
var faceDirection: String = 'down'
var coords: Vector2
@export var synchro: Dictionary = {
	"direction": Vector2.ZERO,
	"key": {},
	"pressed": false,
}

func _ready():
	SynchroHub.synchroAtReady(node_path)
	$ID.text = name
	set_process_input(false)
	if self.name.to_int() == multiplayer.get_unique_id():
		set_process_input(true)
		#$connected.play()

func _process(_delta):
	var temp = self.position
	if coords:
		set_position(coords)
		if temp != self.position:
			$CHAnimatedSprite2D.play('walk_' + faceDirection)
		else:
			$CHAnimatedSprite2D.play('idle_' + faceDirection)

func _input(event):
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		move(event, true)
	elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
		move(event, false)
	elif event.is_action_pressed("ui_cancel"):
		set_process_input(false)
		synchro.direction = Vector2.ZERO
		grass_step()
		SynchroHub.synchronize_on_server(node_path, synchro)
		$disconnect_confirm.show()

func move(event, pressed):
	synchro.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	synchro.key = event.as_text()
	synchro.pressed = pressed
	synchro.echo = event.is_echo()
	grass_step()
	SynchroHub.synchronize_on_server(node_path, synchro)

func grass_step():
	if synchro.direction != Vector2.ZERO: #and $disconnect_confirm.visible != true:
		if not $grass_step.is_playing():
			pass
			#$grass_step.play()
	else:
		$grass_step.stop()

func _on_disconnect_confirm_confirmed():
	rpc_id(1, 'disconnectMe')
	await get_tree().create_timer(1).timeout
	if get_tree().get_multiplayer().multiplayer_peer.get_connection_status() != 0:
		print('Disconnection request failed, disconnecting myself...')
		multiplayer.multiplayer_peer.close()
	
func _on_disconnect_confirm_canceled():
	set_process_input(true)
	$disconnect_confirm.hide()

@rpc("call_local", "reliable")
func disconnectMe():
	pass
