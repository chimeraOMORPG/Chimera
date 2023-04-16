extends MultiplayerSynchronizer

# Synchronized property.
@export var direction := Vector2.ZERO
@export var eventList: Array

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	if get_parent().name.to_int() == multiplayer.get_unique_id():
		process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _input(event):
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			eventList.append(event.as_text().to_lower())
#			get_node('../CHAnimatedSprite2D').play("walk_" + eventList.back())
			if eventList.size()>2:
				eventList.pop_front()
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
			eventList.remove_at(eventList.rfind(event.as_text().to_lower()))
#			if eventList.size()>0:
##				get_node('../CHAnimatedSprite2D').play("walk_" + eventList.front())
#				print("ritorno a direzione " + eventList.front())
#			else:
#				get_node('../CHAnimatedSprite2D').play("idle_" + (get_node('../CHAnimatedSprite2D').animation).trim_prefix("walk_"))
