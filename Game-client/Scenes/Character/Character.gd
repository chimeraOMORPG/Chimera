extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready var input: MultiplayerSynchronizer = $PlayerInput # Player synchronized input.
@export var eventList: Array = ['UP']
@export var authority: int:
	get:
		return self.name.to_int()

func _enter_tree():
	$PlayerInput.set_multiplayer_authority(authority)

func _ready():
	var screen_size = get_viewport_rect().size
	position.x = randi_range(0,screen_size.x)
	position.y = randi_range(0,screen_size.y)	
	$ID.text = name
	if self.name.to_int() == multiplayer.get_unique_id():
		$CHCamera2D.make_current()
	$connected.play()

func _physics_process(delta):
	grass_step(input.get("direction"))
#	side()
	
func grass_step(stepping):
	if stepping != Vector2.ZERO and $disconnect_confirm.visible != true:
		if not $grass_step.is_playing():
			$grass_step.play()
	else:
		$grass_step.stop()

func side():
	if self.name.to_int() == multiplayer.get_unique_id():
		if eventList:
			print(eventList)
			$CHAnimatedSprite2D.play("walk_" + eventList.back())

func _input(event):
#	print(eventList)
#	if self.name.to_int() == multiplayer.get_unique_id():
#		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
##	#		eventList.append(event.as_text().to_lower())
#			$CHAnimatedSprite2D.play("walk_" + eventList.back())
#	#		if eventList.size()>2:
#	#			eventList.pop_front()
#		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
#	#		eventList.remove_at(eventList.rfind(event.as_text().to_lower()))
#			if $PlayerInput.eventList.size()>0:
#				$CHAnimatedSprite2D.play("walk_" + eventList.front())
#				print("ritorno a direzione " + eventList.front())
#			else:
#				$CHAnimatedSprite2D.play("idle_" + ($CHAnimatedSprite2D.animation).trim_prefix("walk_"))
		if event.is_action_pressed("ui_cancel"):
			print("Disconnection request sended to server")
			$disconnect_confirm.show()
			set_process_input(false)

func _on_disconnect_confirm_confirmed():
	set_process_input(true)
	multiplayer.multiplayer_peer.close()
	$CHCamera2D.enabled = false

func _on_disconnect_confirm_cancelled():
	set_process_input(true)
	$disconnect_confirm.hide()
	
