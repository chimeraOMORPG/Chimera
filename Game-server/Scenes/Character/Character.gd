extends CharacterBody2D

# How fast the player will move (pixels/sec).
@export var speed = 400

@onready var identity: String = str(self.get_path())

@export var synchro: Dictionary = {
	"direction": Vector2.ZERO,
	"key": {},
	"pressed": false,
}

var screen_size: Vector2
var eventList: Array
var faceDirection

signal facing_updated
signal spawned

func _enter_tree():
	facing_updated.connect(self._facing_updated)
	spawned.connect(self._spawned)
	self.set_multiplayer_authority(1)

func _ready():
	screen_size = get_viewport_rect().size

func move(delta):
	velocity = synchro.direction.normalized() * delta * speed * 50
	move_and_slide()
	verify_border()	

func _physics_process(delta):
	var temp = self.position
	move(delta)
	if not self.is_queued_for_deletion():
		if temp != self.position:
			SynchroHub.toClients(identity, self.position, null)

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

func _spawned():
	SynchroHub.toClients(identity, self.position, faceDirection)

func _facing_updated() -> void:
	if synchro.key == 'up' or 'down' or 'right' or 'left':
		if synchro.pressed:
			eventList.append(synchro.key.to_lower())
			faceDirection = eventList.back()
			if eventList.size()>2:
				eventList.pop_front()
		else:
			if eventList.rfind(synchro.key.to_lower()) != -1:
				eventList.remove_at(eventList.rfind(synchro.key.to_lower()))
			if eventList.size()>0:
				faceDirection = eventList.front()
		SynchroHub.toClients(identity, null, faceDirection)

@rpc("any_peer", "reliable")
func disconnectMe():
	var clientID: int = multiplayer.get_remote_sender_id()
	prints(clientID, 'disconnection request arrived')
	get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(clientID)
