extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@export var eventList: Array
@onready var _identity: String = str(self.get_path())
var Synchro: Dictionary = {
	'direction': Vector2.ZERO}

func _process(_delta):
	if self.name.to_int() == multiplayer.get_unique_id():
		Synchro.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		SynchroHub.toServer(_identity, Synchro)

func _ready():
	$ID.text = name
	if self.name.to_int() == multiplayer.get_unique_id():
		$connected.play()
		
func grass_step(stepping):
	if stepping != Vector2.ZERO and $disconnect_confirm.visible != true:
		if not $grass_step.is_playing():
			$grass_step.play()
	else:
		$grass_step.stop()

func _input(event):
	if self.name.to_int() == multiplayer.get_unique_id():
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			eventList.append(event.as_text().to_lower())
			$CHAnimatedSprite2D.play("walk_" + eventList.back())
			if eventList.size()>2:
				eventList.pop_front()
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
			if eventList.rfind(event.as_text().to_lower()) != -1:
				eventList.remove_at(eventList.rfind(event.as_text().to_lower()))
			if eventList.size()>0:
				$CHAnimatedSprite2D.play("walk_" + eventList.front())
			else:
				$CHAnimatedSprite2D.play("idle_" + ($CHAnimatedSprite2D.animation).trim_prefix("walk_"))
#		if event.is_action_pressed("ui_cancel"):
#			print("Disconnection request sended to server")
#			$disconnect_confirm.show()
#			set_process_input(false)

func _on_disconnect_confirm_confirmed():
	set_process_input(true)
	multiplayer.multiplayer_peer.close()
	$CHCamera2D.enabled = false

func _on_disconnect_confirm_cancelled():
	set_process_input(true)
	$disconnect_confirm.hide()
	
