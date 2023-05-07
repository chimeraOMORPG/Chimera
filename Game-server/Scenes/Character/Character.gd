extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@onready var _identity: String = str(self.get_path())
@export var Synchro: Dictionary
var faceDirection: String
var screen_size: Vector2
var eventList: Array
var key:
	get:
		return Synchro.input.get('key')
var pressed:
	get:
		return Synchro.input.get('pressed')
signal updateFacing

func _enter_tree():
	self.set_multiplayer_authority(1)

func _ready():
	updateFacing.connect(self.facing)
	screen_size = get_viewport_rect().size

func move(delta):
	velocity = Synchro.get("direction").normalized() * delta * speed * 50
	verify_border()
	move_and_slide()
	return self.position

func _process(delta):
	if Synchro.has('direction'):
		if Synchro.direction:
			var temp: Vector2 = position
			if move(delta) != temp:
				print('diverso')
	SynchroHub.toClients(_identity, self.position, faceDirection)
#	if not self.is_queued_for_deletion():
		
func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

func facing() -> void:
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

@rpc("any_peer", "reliable")
func disconnectMe():
	get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(multiplayer.get_remote_sender_id())
	
