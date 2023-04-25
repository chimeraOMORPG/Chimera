extends Node2D

@onready var trasition: Node = get_parent().get_node('../../transition/Control/AnimationPlayer')
const  CharacterScene = preload("res://Scenes/Character/Character.tscn")
@export var characterList: PackedInt32Array:
	get:
		var x: Array = []
		for i in self.get_children():
			x.append(i.name.to_int())
		return x

@rpc("authority")
func syncSpawn(Place, toSpawn, entered):
	if get_parent().name == Place:
		print(toSpawn)
		for i in characterList:
			if not toSpawn.has(i):
				get_node(str(i)).queue_free.call_deferred()	
		for i in toSpawn:
			if not characterList.has(i):
				var x = CharacterScene.instantiate()
				x.set_name(str(i))# Set the name, so players can figure out their local authority
				self.add_child(x, true)	
		prints("Characters synchronized on this client.")
		if entered.to_int() == multiplayer.get_unique_id():
			trasition.play('trans_in')
#	else:
#		prints(Place, 'is not the active scene on this client')
#
