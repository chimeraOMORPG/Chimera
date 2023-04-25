extends SubViewportContainer

var PortaEst = preload("res://Scenes/Character/Character.tscn")
@onready var here: String = self.name
#put below all the scenes connected to this one
var hereToScene1: String = '02-crystal-rock'
var hereToScene2: String = '03-kraken-coast'

func _enter_tree():
	if $SubViewport.has_node('Gateways'):
		if not get_node('SubViewport/Gateways').get_children().is_empty():
			for i in get_node('SubViewport/Gateways').get_children():
				i.body_entered.connect(self.sceneChange)
	
func sceneChange(body):
	prints(body.name, 'Changing scene to', hereToScene1)
	var result = await get_node_or_null('/root/World').addScene(body.name.to_int(), hereToScene1)
	if result:
		get_node('/root/World').create_player(body.name.to_int(), hereToScene1, here)
	else:
		print('Error adding scene...')
