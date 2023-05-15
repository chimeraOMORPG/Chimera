extends CharacterBody2D

@export var speed = 150 # How fast the player will move (pixels/sec).
@onready var _identity: String = str(self.get_path())
@export var Synchro: Dictionary = {
	'D': Vector2.ZERO, # D for Directio
	'I': {}, # I for Input
	'T': 0.0, # T for Timestamp
	'F': 'down', # Ottimizzare in intero anzichè string con legenda con enum # Facing
	'C': Vector2.ZERO}
var screen_size: Vector2
var eventList: Array
var key:
	get:
		return Synchro.I.get('key')
var pressed:
	get:
		return Synchro.I.get('pressed')
signal updateFacing
signal spawned

func _enter_tree():
	updateFacing.connect(self._updateFacing)
	spawned.connect(self._spawned)
	self.set_multiplayer_authority(1)

func _ready():
	screen_size = get_viewport_rect().size
	Synchro.C = self.position

func _physics_process(delta):
	velocity = Synchro.D.normalized() * speed * delta * 50
	print(delta)
	if velocity:
		move_and_slide()
		verify_border()
		Synchro.C = self.position
		if not self.is_queued_for_deletion():
			var tempSynchro: Dictionary
			tempSynchro.C = self.position
			tempSynchro.T = Time.get_unix_time_from_system()
			SynchroHub.toClients(_identity, tempSynchro)
		
func verify_border():
	position.x = clamp(position.x,30, screen_size.x-30)
	position.y = clamp(position.y, 30, screen_size.y-30)

func _spawned():
	var tempSynchro: Dictionary
	tempSynchro.C = Synchro.C
	tempSynchro.T = Time.get_unix_time_from_system()
	tempSynchro.F = Synchro.F
	SynchroHub.toClients(_identity, tempSynchro)

func _updateFacing() -> void:
	if key == 'up' or 'down' or 'right' or 'left':
		if pressed:
			eventList.append(key.to_lower())
			Synchro.F = eventList.back()
			if eventList.size()>2:
				eventList.pop_front()
		else:
			if eventList.rfind(key.to_lower()) != -1:
				eventList.remove_at(eventList.rfind(key.to_lower()))
			if eventList.size()>0:
				Synchro.F = eventList.front()
		var tempSynchro: Dictionary
		tempSynchro.F = Synchro.F
		tempSynchro.T = Time.get_unix_time_from_system()
		SynchroHub.toClients(_identity, tempSynchro)

@rpc("any_peer", "reliable")
func disconnectMe():
	var clientID: int = multiplayer.get_remote_sender_id()
	prints(clientID, 'disconnection request arrived')
	get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(clientID)

