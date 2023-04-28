extends Area2D

@onready var here: String = get_node('../../../').name

func _ready():
	body_entered.connect(self.sceneChange)
	
func sceneChange(body):
	var toScene = self.name.get_slice('_', 1)
	var toPosition = self.name.get_slice('_', 2).to_int()
	prints(body.name, 'Changing scene to', toScene)
	var result = await get_node_or_null('/root/World').addScene(body.name.to_int(), toScene)
	if result:
		get_node('/root/World').create_player(body.name.to_int(), toScene, toPosition, here)
	else:
		print('Error adding scene...')
