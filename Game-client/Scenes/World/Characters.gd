extends Node

@onready var trasition: Node = get_parent().get_node('../../transition/Control/AnimationPlayer')
const  CharacterScene = preload("res://Scenes/Character/Character.tscn")
var thisScene: SubViewportContainer:
	get:
		return self.get_node('../../')

var characterList: PackedInt32Array:
	get:
		var x: Array = []
		for i in self.get_children():
			x.append(i.name.to_int())
		return x

@rpc("authority")
func syncSpawn(Place, node, serverCharachterList, exiting):
	if thisScene.name == Place:# questa linea DOVREBBE essere superflua....
		if exiting:
			if node.to_int() == multiplayer.get_unique_id():
				thisScene.queue_free()
				trasition.play('trans_in')
				return
			for i in characterList:
				if not serverCharachterList.has(i):
					get_node(str(i)).queue_free()
		else:	
			for i in serverCharachterList:
				if not characterList.has(i):
					var x = CharacterScene.instantiate()
					x.set_name(str(i))
					self.add_child(x, true)
					if node.to_int() == multiplayer.get_unique_id():
						trasition.play('trans_in')

