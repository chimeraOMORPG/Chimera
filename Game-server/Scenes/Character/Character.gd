extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@onready var _identity: String = str(self.get_path())
@export var Synchro: Dictionary = {
	'direction': Vector2.ZERO,
	'input': {}}
var screen_size: Vector2
var eventList: Array
var faceDirection
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
	updateFacing.connect(self._facing)
	screen_size = get_viewport_rect().size

#func _position():
#	print('segnale emesso')
#	SynchroHub.toClients(_identity, self.position, faceDirection)

func move(delta):
	velocity = Synchro.get("direction").normalized() * delta * speed * 50
	move_and_slide()
	verify_border()	

func _process(delta):
	var temp = self.position
	move(delta)
	if not self.is_queued_for_deletion():
#		if temp != self.position:
			SynchroHub.toClients(_identity, self.position, null)

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

func _facing() -> void:
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
			else:
				faceDirection = null
		SynchroHub.toClients(_identity, null, faceDirection)

@rpc("any_peer", "reliable")
func disconnectMe():
	self.queue_free()
	await get_tree().create_timer(0.5).timeout
	get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(multiplayer.get_remote_sender_id())
	
