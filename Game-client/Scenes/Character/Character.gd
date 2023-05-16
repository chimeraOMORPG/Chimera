extends CharacterBody2D

#const speed: int = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready var path: String = str(get_parent().get_path()) + '/'
#const interpolationOffset: int = 100
#var faceDirection: String = 'down'
#var coords: Vector2
#var eventList: Array
@export var speed = 150 # How fast the player will move (pixels/sec).
var Synchro: Dictionary = {
	'D': {'vector': Vector2.ZERO, 'localTime': Time.get_unix_time_from_system()}, # D for Direction
	'I': {}, # I for Input
	'T': 0.0, # T for Timestamp
	'F': '', # Ottimizzare in intero anzichè string con legenda con enum # Facing
	'C': null} # Coordinates received from teh server
var key:
	get:
		return Synchro.I.get('key')
var pressed:
	get:
		return Synchro.I.get('pressed')
var t = 0.0

func _enter_tree():
	self.hide()

func _ready():
	SynchroHub.toServer(path)
	$ID.text = name
	set_process_input(false)
	if self.name.to_int() == multiplayer.get_unique_id():
		set_process_input(true)
		$connected.play()

func _physics_process(delta):
	prints(Synchro.D['vector'], self.position)
	while Synchro.C == null:
		print('Waiting spawning data from the server...')
		return
	if self.visible != true:
		self.show()
	if not Synchro.C.is_equal_approx(self.position):
		self.position = self.position.lerp(Synchro.get('C'), delta * 10)
		prints('lerp pos:', self.position, 'time:', Synchro.T)
		if not $CHAnimatedSprite2D.is_playing() or $CHAnimatedSprite2D.animation != ('walk_' + Synchro.F):
			$CHAnimatedSprite2D.play('walk_' + Synchro.F)
#	else:
#		$CHAnimatedSprite2D.play('idle_' + Synchro.F)
	var timediff = Time.get_unix_time_from_system()-Synchro.D['localTime']
	velocity = (Synchro.D['vector'] * speed * delta * 150) * (1 - timediff)
	if velocity:
		prints('timediff:', timediff, 'velocity:', velocity)
		move_and_slide()
		Synchro.D['localTime'] = Time.get_unix_time_from_system()
		Synchro.C = self.position
		print('pred pos:', self.position)

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
