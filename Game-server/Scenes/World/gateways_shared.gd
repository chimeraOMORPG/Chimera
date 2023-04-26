extends Area2D

@onready var here: String = get_node('../../../').name
const destination: Dictionary = {
	01:
	{
	'scene_name': '02-crystal-rock',
	'spawn_position': Vector2(660, 58)
}, 02:
	{
	'scene_name': '02-crystal-rock',
	'spawn_position': ''
	}
}

func _ready():
	body_entered.connect(self.sceneChange)
	
func sceneChange(body):
	var toScene = destination[self.name.to_int()].get('scene_name')
	var toPosition = destination[self.name.to_int()].get('spawn_position')
	prints(body.name, 'Changing scene to', toScene)
	var result = await get_node_or_null('/root/World').addScene(body.name.to_int(), toScene)
	if result:
		get_node('/root/World').create_player(body.name.to_int(), toScene, toPosition, here)
	else:
		print('Error adding scene...')
