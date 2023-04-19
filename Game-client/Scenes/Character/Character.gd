extends CharacterBody2D

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

const TILE_W: int = 32
const TILE_H: int = 32
const starting_dir = Direction.LEFT
const starting_pos = Vector2(0, 0)
const speed: float = 200; # px/sec

var curr_dir: Direction = starting_dir
var input_queue: Array[Direction] = []

@export var authority: int:
	get:
		return self.name.to_int()

func _enter_tree():
	#$PlayerInput.set_multiplayer_authority(authority)
	pass
	
func _ready():
	
	$ID.text = name
	if self.name.to_int() == multiplayer.get_unique_id():
		$CHCamera2D.make_current()
	$connected.play()
	
	position = starting_pos
	update_animation()
	$AnimatedSprite2D.play()

func versor_for(dir: Direction):
	if dir == Direction.UP:
		return Vector2(0, -1)
	if dir == Direction.DOWN:
		return Vector2(0, 1)
	if dir == Direction.LEFT:
		return Vector2(-1, 0)
	assert(dir == Direction.RIGHT)
	return Vector2(1, 0)

func set_direction_pending(dir: Direction) -> void:
	input_queue.erase(dir)
	input_queue.append(dir)

func remove_direction_pending(dir: Direction) -> void:
	input_queue.erase(dir)

func currently_aligned() -> bool:
	var delta_x = fmod(position.x, TILE_W)
	var delta_y = fmod(position.y, TILE_H)
	return delta_x == 0 and delta_y == 0

func currently_moving() -> bool:
	return input_queue.size() > 0

func update_direction() -> void:
	if input_queue.size() > 0:
		curr_dir = input_queue[0]

func update_animation():
	$AnimatedSprite2D.flip_h = false
	if currently_moving():
		if curr_dir == Direction.UP:
			$AnimatedSprite2D.animation = "walk-back"
		elif curr_dir == Direction.DOWN:
			$AnimatedSprite2D.animation = "walk-front"
		elif curr_dir == Direction.LEFT:
			$AnimatedSprite2D.animation = "walk-left"
		elif curr_dir == Direction.RIGHT:
			$AnimatedSprite2D.animation = "walk-left"
			$AnimatedSprite2D.flip_h = true
	else:
		if curr_dir == Direction.UP:
			$AnimatedSprite2D.animation = "stand-back"
		elif curr_dir == Direction.DOWN:
			$AnimatedSprite2D.animation = "stand-front"
		elif curr_dir == Direction.LEFT:
			$AnimatedSprite2D.animation = "stand-left"
		elif curr_dir == Direction.RIGHT:
			$AnimatedSprite2D.animation = "stand-left"
			$AnimatedSprite2D.flip_h = true

func tile_relative_to_point(point: Vector2) -> Vector2:
	return Vector2(int(point.x / TILE_W), int(point.y / TILE_H))

func _process(delta):
	
	const server_id = 1
	
	if Input.is_action_just_pressed("ui_up"):
		set_direction_pending(Direction.UP)
		rpc_id(server_id, "direction_key_pressed", Direction.UP)
	
	if Input.is_action_just_pressed("ui_down"):
		set_direction_pending(Direction.DOWN)
		rpc_id(server_id, "direction_key_pressed", Direction.DOWN)
	
	if Input.is_action_just_pressed("ui_left"):
		set_direction_pending(Direction.LEFT)
		rpc_id(server_id, "direction_key_pressed", Direction.LEFT)
	
	if Input.is_action_just_pressed("ui_right"):
		set_direction_pending(Direction.RIGHT)
		rpc_id(server_id, "direction_key_pressed", Direction.RIGHT)
	
	if Input.is_action_just_released("ui_up"):
		remove_direction_pending(Direction.UP)
		rpc_id(server_id, "direction_key_released", Direction.UP)
	
	if Input.is_action_just_released("ui_down"):
		remove_direction_pending(Direction.DOWN)
		rpc_id(server_id, "direction_key_released", Direction.DOWN)
	
	if Input.is_action_just_released("ui_left"):
		remove_direction_pending(Direction.LEFT)
		rpc_id(server_id, "direction_key_released", Direction.LEFT)
	
	if Input.is_action_just_released("ui_right"):
		remove_direction_pending(Direction.RIGHT)
		rpc_id(server_id, "direction_key_released", Direction.RIGHT)
	
	if currently_aligned():
		update_direction()
		update_animation()
		
	if currently_moving() or not currently_aligned():
		
		var versor = versor_for(curr_dir)
		var increment = versor * delta * speed
		
		var old_tile = tile_relative_to_point(position)
		var new_tile = tile_relative_to_point(position + increment)
		
		if currently_aligned() || old_tile == new_tile:
			position += increment
		else:
			if curr_dir == Direction.LEFT or curr_dir == Direction.UP:
				position = Vector2(old_tile.x * TILE_W, old_tile.y * TILE_H)
			else:
				position = Vector2(new_tile.x * TILE_W, new_tile.y * TILE_H)
			assert(currently_aligned())

#func grass_step(stepping):
#	if stepping != Vector2.ZERO and $disconnect_confirm.visible != true:
#		if not $grass_step.is_playing():
#			$grass_step.play()
#	else:
#		$grass_step.stop()

@rpc("call_remote")
func server_update(position_: Vector2, direction_: Direction):
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		position = position_
		curr_dir = direction_

@rpc("call_local")
func direction_key_pressed(dir: Direction):
	pass

@rpc("call_local")
func direction_key_released(dir: Direction):
	pass

func _on_disconnect_confirm_confirmed():
	set_process_input(true)
	multiplayer.multiplayer_peer.close()
	$CHCamera2D.enabled = false

func _on_disconnect_confirm_cancelled():
	set_process_input(true)
	$disconnect_confirm.hide()
