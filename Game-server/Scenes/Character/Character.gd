extends CharacterBody2D

# How fast the player will move (pixels/sec).
@export var speed = 400
@onready var node_path: String = str(self.get_path())

var screen_size: Vector2
var eventList: Array
var faceDirection
var input_from_client: Dictionary = {
	"direction": Vector2.ZERO,
	"key": "",
	"pressed": false,
}

func _ready():
	screen_size = get_viewport_rect().size
	SynchroHub.incoming_synchro_signal.connect(_sync_data)
	SynchroHub.update_facing_signal.connect(_facing_updated)
	SynchroHub.spawned_signal.connect(_spawned)

func _physics_process(delta):
	var temp = self.position
	velocity = input_from_client.direction.normalized() * delta * speed * 50
	move_and_slide()
	verify_border()	
	if not self.is_queued_for_deletion():
		if temp != self.position:
			SynchroHub.to_clients(node_path, self.position, null)

func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

func _spawned(node_path_from_client):
	if node_path != node_path_from_client:
		return
	SynchroHub.to_clients(node_path, self.position, faceDirection)

func _sync_data(node_path_from_client, data):
	if node_path == node_path_from_client:
		input_from_client = data

func _facing_updated(node_path_from_client) -> void:
	if node_path != node_path_from_client:
		return

	if input_from_client.key == 'up' or 'down' or 'right' or 'left':
		if input_from_client.pressed:
			eventList.append(input_from_client.key.to_lower())
			faceDirection = eventList.back()
			if eventList.size() > 2:
				eventList.pop_front()
		else:
			if eventList.rfind(input_from_client.key.to_lower()) != -1:
				eventList.remove_at(eventList.rfind(input_from_client.key.to_lower()))
			if eventList.size() > 0:
				faceDirection = eventList.front()
		SynchroHub.to_clients(node_path, null, faceDirection)
