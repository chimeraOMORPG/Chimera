extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@onready var _identity: String = str(self.get_path())
@export var Synchro: Dictionary
var faceDirection: String
var screen_size
var eventList: Array
var key:
	get:
		return Synchro.input.get('key')
var pressed:
	get:
		return Synchro.input.get('pressed')
signal updateAnimation


func _enter_tree():
	self.set_multiplayer_authority(1)

func _ready():
	screen_size = get_viewport_rect().size

func movement(deltapassed):
	velocity = Synchro.get("direction").normalized() * speed * deltapassed * 50
	move_and_slide()

func _process(delta):
	if Synchro.has('direction'):
		if Synchro.direction:
			movement(delta)
			verify_border()
	SynchroHub.toClients(_identity, self.position, faceDirection)

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)


#		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
#			eventList.append(event.as_text().to_lower())
#			$CHAnimatedSprite2D.play("walk_" + eventList.back())
#			if eventList.size()>2:
#				eventList.pop_front()
#		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
#			eventList.remove_at(eventList.rfind(event.as_text().to_lower()))
#			if eventList.size()>0:
#				$CHAnimatedSprite2D.play("walk_" + eventList.front())
#				print("ritorno a direzione " + eventList.front())
#			else:
#				$CHAnimatedSprite2D.play("idle_" + ($CHAnimatedSprite2D.animation).trim_prefix("walk_"))


func facing() -> void:
	print(eventList)
	if key == 'up' or 'down' or 'right' or 'left':
		if pressed:
			eventList.append(key.to_lower())
			faceDirection = "walk_" + eventList.back()
			if eventList.size()>2:
				eventList.pop_front()
		else:
			if eventList.rfind(key.to_lower()) != -1:
				eventList.remove_at(eventList.rfind(key.to_lower()))
			if eventList.size()>0:
				faceDirection = "walk_" + eventList.front()
			else:
				faceDirection = 'none'
		print(eventList)

