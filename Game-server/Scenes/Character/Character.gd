extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@onready var input = $PlayerInput # Player synchronized input.
var screen_size
@onready var eventList:
	get:
		return $PlayerInput.eventList
@export var authority: int:
	get:
		return name.to_int()

func _enter_tree():
	$PlayerInput.set_multiplayer_authority(authority)

func _ready():
	screen_size = get_viewport_rect().size
	position.x = randi_range(0,screen_size.x)
	position.y = randi_range(0,screen_size.y)		
	pass

func movement(deltapassed):
	if input.direction:
		velocity = input.get("direction").normalized() * speed * deltapassed * 50	
		move_and_slide()

func _physics_process(delta):
#	print(eventList)
	movement(delta)
	verify_border()

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

#func _input(event):
#	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
#		direction.append(event.as_text().to_lower())
#		$CHAnimatedSprite2D.play("walk_"+direction.back())
#		if direction.size()>2:
#			direction.pop_front()
#	elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
#		direction.remove_at(direction.rfind(event.as_text().to_lower()))
#		if direction.size()>0:
#			$CHAnimatedSprite2D.play("walk_"+direction.front())
#			print("ritorno a direzione "+direction.front())
#		else:
#			$CHAnimatedSprite2D.play("idle_"+($CHAnimatedSprite2D.animation).trim_prefix("walk_"))
#	if event.is_action_pressed("ui_cancel"):
#		print("Disconnection request sended to server")
#		$disconnect_confirm.show()
#		set_process_input(false)


