extends CharacterBody2D

#const speed: int = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready var path: String = str(get_parent().get_path()) + '/'
#const interpolationOffset: int = 100
#var faceDirection: String = 'down'
#var coords: Vector2
#var eventList: Array
var Synchro: Dictionary = {
	'D': Vector2.ZERO, # D for Directio
	'I': {}, # I for Input
	'T': 0.0, # T for Timestamp
	'F': '', # Ottimizzare in intero anzichè string con legenda con enum # Facing
	'C': Vector2.ZERO} # Coordinates received from teh server
var key:
	get:
		return Synchro.I.get('key')
var pressed:
	get:
		return Synchro.I.get('pressed')
var positionDiff: int = 10 #in pixel

func _ready():
	SynchroHub.synchroAtReady(path)
	$ID.text = name
	set_process_input(false)
	if self.name.to_int() == multiplayer.get_unique_id():
		set_process_input(true)
		$connected.play()

func _physics_process(delta):
	while Synchro.C == Vector2.ZERO:
		print('Waiting spawning data from the server...')
		return
	var temp = self.position
	if not Synchro.C.is_equal_approx(self.position):
		self.position = self.position.lerp(Synchro.get('C'), delta * 25)
		if not $CHAnimatedSprite2D.is_playing() or $CHAnimatedSprite2D.animation != ('walk_' + Synchro.F):
			$CHAnimatedSprite2D.play('walk_' + Synchro.F)
	else:
		$CHAnimatedSprite2D.play('idle_' + Synchro.F)
#	grass_step()

func _input(event):
	if event.is_action_type():
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			movement(event, true)
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
			movement(event, false)
		elif event.is_action_pressed("ui_cancel"):
			set_process_input(false)
			Synchro.D = Vector2.ZERO
			grass_step()
			SynchroHub.toServer(path, Synchro)
			$disconnect_confirm.show()

func movement(dir, press):
	var tempSynchro: Dictionary
	tempSynchro.D = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	tempSynchro.I = {'key': dir.as_text(), 'pressed': press, 'echo': dir.is_echo()}
	tempSynchro.T = Time.get_unix_time_from_system()
	SynchroHub.toServer(path, tempSynchro)

#func _updateFacing() -> void:
#	if key == 'up' or 'down' or 'right' or 'left':
#		if pressed:
#			eventList.append(key.to_lower())
#			faceDirection = eventList.back()
#			if eventList.size()>2:
#				eventList.pop_front()
#		else:
#			if eventList.rfind(key.to_lower()) != -1:
#				eventList.remove_at(eventList.rfind(key.to_lower()))
#			if eventList.size()>0:
#				faceDirection = eventList.front()

func grass_step():
	if Synchro.D != Vector2.ZERO: #and $disconnect_confirm.visible != true:
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
