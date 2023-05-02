extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
#@onready var input = $PlayerInput # Player synchronized input.
var Synchro: Dictionary = {
	'direction': Vector2.ZERO
}
var screen_size
@export var eventList: Array
@export var authority: int:
	get:
		return name.to_int()

func _enter_tree():
	self.set_multiplayer_authority(1)

func _ready():
	screen_size = get_viewport_rect().size

func movement(deltapassed):
	if Synchro.direction:
		velocity = Synchro.get("direction").normalized() * speed * deltapassed * 50	
		move_and_slide()

func _physics_process(delta):
	movement(delta)
	verify_border()
	updateOnClients()

func updateOnClients():
	for i in get_parent().characterList:
		rpc_id(i, 'moveOn', self.name, self.position)

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

@rpc("any_peer", "unreliable")
func _synchronize(data):
	Synchro.direction = data.direction
	
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
#	if Input.is_key_pressed(KEY_C,) and not event.echo:
#		rpc_id(1,"chiamata")

@rpc("call_local", "unreliable")
func moveOn():
	pass
