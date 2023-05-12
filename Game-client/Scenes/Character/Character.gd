extends CharacterBody2D

const speed: int = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready var path: String = str(get_parent().get_path()) + '/'
var faceDirection: String = 'down'
var coords: Vector2
var eventList: Array
var Synchro: Dictionary = {
	'direction': Vector2.ZERO,
	'input': {}}
var key:
	get:
		return Synchro.input.get('key')
var pressed:
	get:
		return Synchro.input.get('pressed')

func _ready():
	SynchroHub.synchroAtReady(path)
	$ID.text = name
	set_process_input(false)
	if self.name.to_int() == multiplayer.get_unique_id():
		set_process_input(true)
		$connected.play()

func _physics_process(delta):
	if coords:# coords arrive from server then client update his position
		print('Wrong character position, server has request an update...')
		set_position(coords)
		coords = Vector2.ZERO
	velocity = Synchro.get("direction").normalized() * delta * speed * 50
	grass_step()
	if velocity:
		move_and_slide()
		$CHAnimatedSprite2D.play('walk_' + faceDirection)
	else:
		$CHAnimatedSprite2D.play('idle_' + faceDirection)

func _input(event):
	if event.is_action_type():
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			movement(event, true)
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
			movement(event, false)
		elif event.is_action_pressed("ui_cancel"):
			set_process_input(false)
			Synchro.direction = Vector2.ZERO
			grass_step()
			SynchroHub.toServer(path, Synchro)
			$disconnect_confirm.show()

func movement(dir, pressed):
	Synchro.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	Synchro.input = {'key': dir.as_text(), 'pressed': pressed, 'echo': dir.is_echo()}
#	_updateFacing()
	SynchroHub.toServer(path, Synchro)

func _updateFacing() -> void:
	if key == 'up' or 'down' or 'right' or 'left':
		if pressed:
			eventList.append(key.to_lower())
			faceDirection = eventList.back()
			if eventList.size()>2:
				eventList.pop_front()
		else:
			if eventList.rfind(key.to_lower()) != -1:
				eventList.remove_at(eventList.rfind(key.to_lower()))
			if eventList.size()>0:
				faceDirection = eventList.front()

func grass_step():
	if Synchro.direction != Vector2.ZERO: #and $disconnect_confirm.visible != true:
		if not $grass_step.is_playing():
			$grass_step.play()
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
