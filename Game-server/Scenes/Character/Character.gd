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
signal spawned

func _enter_tree():
	updateFacing.connect(self._updateFacing)
	spawned.connect(self._spawned)
	self.set_multiplayer_authority(1)

func _ready():
	screen_size = get_viewport_rect().size

func move(delta):
	velocity = Synchro.get("direction").normalized() * delta * speed * 50
	move_and_slide()
	verify_border()	

func _physics_process(delta):
	var temp = self.position
	move(delta)
	if not self.is_queued_for_deletion():
		if temp != self.position:
			SynchroHub.toClients(_identity, self.position, null)

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

func _spawned():
	SynchroHub.toClients(_identity, self.position, faceDirection)

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
		SynchroHub.toClients(_identity, null, faceDirection)

@rpc("any_peer", "reliable")
func disconnectMe():
	var clientID: int = multiplayer.get_remote_sender_id()
	prints(clientID, 'disconnection request arrived')
	self.queue_free()
	get_tree().get_multiplayer().multiplayer_peer.disconnect_peer.call_deferred(clientID)
