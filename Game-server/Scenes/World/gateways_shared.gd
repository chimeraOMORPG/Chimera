extends Area2D

@onready var here: String = get_node('../../../').name
const destination: Dictionary = {
	'scene_name': 'crystal-rock',
	'scene_ID': '02',
	'spawn_position': Vector2(660, 58)
}

func _ready():
	body_entered.connect(self.sceneChange)
	
func sceneChange(body):
	var toScene: String = destination.scene_ID + '-' + destination.scene_name
	prints(body.name, 'Changing scene to', toScene)
	var result = await get_node_or_null('/root/World').addScene(body.name.to_int(), toScene)
	if result:
		get_node('/root/World').create_player(body.name.to_int(), toScene, destination.spawn_position, here)
	else:
		print('Error adding scene...')
