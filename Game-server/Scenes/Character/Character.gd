extends CharacterBody2D

enum Direction { # duplicate of the one in the client
	UP,
	DOWN,
	LEFT,
	RIGHT
}

const TILE_W: int = 8
const TILE_H: int = 8
const starting_dir = Direction.LEFT
const starting_pos = Vector2(0, 0)
const speed: float = 200; # px/sec

var curr_dir: Direction = starting_dir
var input_queue: Array[Direction] = []

var authority: int:
	get:
		return self.name.to_int()

func _ready():
	position = starting_pos

func versor_for(dir: Direction):
	if dir == Direction.UP:
		return Vector2(0, -1)
	if dir == Direction.DOWN:
		return Vector2(0, 1)
	if dir == Direction.LEFT:
		return Vector2(-1, 0)
	assert(dir == Direction.RIGHT)
	return Vector2(1, 0)

func currently_aligned() -> bool:
	var delta_x = fmod(position.x, TILE_W)
	var delta_y = fmod(position.y, TILE_H)
	return delta_x == 0 and delta_y == 0

func currently_moving() -> bool:
	return input_queue.size() > 0

func update_direction() -> void:
	if input_queue.size() > 0:
		curr_dir = input_queue[0]

func tile_relative_to_point(point: Vector2) -> Vector2:
	return Vector2(int(point.x / TILE_W), int(point.y / TILE_H))

func _process(delta):
	
	if currently_aligned():
		update_direction()
		rpc_id(0, "server_update", authority, position, curr_dir)
		
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

@rpc("call_local", "unreliable_ordered")
func server_update(authority_: int, position_: Vector2, direction_: Direction):
	pass

@rpc("any_peer", "call_remote")
func direction_key_pressed(authority_: int, dir: Direction):
	if authority == multiplayer.get_remote_sender_id():
		input_queue.erase(dir)
		input_queue.append(dir)

@rpc("any_peer", "call_remote")
func direction_key_released(authority_: int, dir: Direction):
	if authority == multiplayer.get_remote_sender_id():
		input_queue.erase(dir)
