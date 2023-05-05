extends CharacterBody2D

const speed: int = 400 # How fast the player will move (pixels/sec); now hardcoded but it must be passed from auth server
@onready var _identity: String = str(self.get_path())
var Synchro: Dictionary = {
	'direction': Vector2.ZERO,
	'input': {}}

func _process(delta):
	if self.name.to_int() == multiplayer.get_unique_id():
#		if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"): #Vedere come attivarlo per risparmiare dati
		Synchro.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#		if Input.is_action_pressed():
#			if Input.is_action_pressed("ui_up"):
#				Synchro.input = {'key': 'up', 'pressed': true}
#			if Input.is_action_pressed("ui_down"):
#				Synchro.input = {'key': 'down', 'pressed': true}
#			if Input.is_action_pressed("ui_right"):
#				Synchro.input = {'key': 'right', 'pressed': true}
#			if Input.is_action_pressed("ui_left"):
#				Synchro.input = {'key': 'left', 'pressed': true}
#
#			if Input.is_action_just_released("ui_up"):
#				Synchro.input = {'key': 'up', 'pressed': false}
#			if Input.is_action_just_released("ui_down"):
#				Synchro.input = {'key': 'down', 'pressed': false}
#			if Input.is_action_just_released("ui_right"):
#				Synchro.input = {'key': 'right', 'pressed': false}
#			if Input.is_action_just_released("ui_left"):
#				Synchro.input = {'key': 'left', 'pressed': false}
#			print('evento')
		SynchroHub.toServer(_identity, Synchro)

func facing(input):
	print(input)


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
	if self.name.to_int() == multiplayer.get_unique_id(): #ottimizzare in caso di is_echo
#		Synchro.input = {'key': event.as_text(), 'pressed': event.is_action_pressed(("ui_up"), 'echo': event.is_echo()}
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			Synchro.input = {'key': event.as_text(), 'pressed': true, 'echo': event.is_echo()}
##			Synchro.facing.append(event.as_text().to_lower())
###			$CHAnimatedSprite2D.play("walk_" + eventList.back())
##			if Synchro.facing.size()>2:
##				Synchro.facing.pop_front()
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
			Synchro.input = {'key': event.as_text(), 'pressed': false, 'echo': event.is_echo()}
##			if Synchro.facing.rfind(event.as_text().to_lower()) != -1:
##				Synchro.facing.remove_at(Synchro.facing.rfind(event.as_text().to_lower()))
##			if eventList.size()>0:
##				$CHAnimatedSprite2D.play("walk_" + eventList.front())
##			else:
##				$CHAnimatedSprite2D.play("idle_" + ($CHAnimatedSprite2D.animation).trim_prefix("walk_"))
		if event.is_action_pressed("ui_cancel"):
			print("Disconnection request sended to server")
			$disconnect_confirm.show()
			set_process_input(false)

func _on_disconnect_confirm_confirmed():
	set_process_input(true)
	multiplayer.multiplayer_peer.close()
	$CHCamera2D.enabled = false

func _on_disconnect_confirm_cancelled():
	set_process_input(true)
	$disconnect_confirm.hide()
	
