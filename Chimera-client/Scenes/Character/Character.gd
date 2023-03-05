extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var input_direction = Vector2.ZERO
var screen_size # Size of the game window.
var direction: Array
var focus = true
@onready var camera = $CHCamera2D
@onready var synchronizer = $CHMultiplayerSynchronizer

func _enter_tree():
	if name.is_valid_int():
		set_multiplayer_authority(str(name).to_int())
	pass
		
func _ready():
	#if synchronizer.is_multiplayer_authority():
		camera.make_current()
		screen_size = get_viewport_rect().size
		$ID.text = name
		position.x = randi_range(0,screen_size.x)
		position.y = randi_range(0,screen_size.y)
		print(multiplayer.get_unique_id())
		print(get_multiplayer_authority())
		$connected.play()
	#else 
	#camera.current = synchronizer.is_multiplayer_authority()
	
func movement(deltapassed):
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction.normalized() * speed * deltapassed * 50	
	if $disconnect_confirm.visible == false:
		if (multiplayer.multiplayer_peer.get_connection_status()) and is_multiplayer_authority():
			move_and_slide()

func grass_step(stepping):
	if stepping != Vector2.ZERO and $disconnect_confirm.visible != true:
		if not $grass_step.is_playing():
			$grass_step.play()
	else:
		$grass_step.stop()	

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		focus = true
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		focus = false
			
func _physics_process(delta):
	movement(delta)
	grass_step(input_direction)
	verify_border()
	
			
func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)
	
func _input(event):
	if is_multiplayer_authority():
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			direction.append(event.as_text().to_lower())
			$CHAnimatedSprite2D.play("walk_"+direction.back())
			if direction.size()>2:
				direction.pop_front()
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
			direction.remove_at(direction.rfind(event.as_text().to_lower()))
			if direction.size()>0:
				$CHAnimatedSprite2D.play("walk_"+direction.front())
				print("ritorno a direzione "+direction.front())
			else:
				$CHAnimatedSprite2D.play("idle_"+($CHAnimatedSprite2D.animation).trim_prefix("walk_"))
		if event.is_action_pressed("ui_cancel"):
			print("Disconnection request sended to server")
			$disconnect_confirm.show()
			set_process_input(false)
		if Input.is_key_pressed(KEY_C,) and not event.echo:
			rpc_id(1,"chiamata")

@rpc("call_remote")
func chiamata():
	pass

func _on_disconnect_confirm_confirmed():
	set_process_input(true)
	multiplayer.multiplayer_peer.close()
	$CHCamera2D.enabled = false

func _on_disconnect_confirm_cancelled():
	set_process_input(true)
	$disconnect_confirm.hide()
