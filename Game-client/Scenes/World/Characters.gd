extends Node2D

var CharacterScene = preload("res://Scenes/Character/Character.tscn")
var characterList: PackedInt32Array:
	get:
		var x: Array
		for i in self.get_children():
			x.append(i.name.to_int())
		return x

@rpc("authority")
func syncSpawn(Place, toSpawn):
	print(toSpawn)
	if get_parent().name == Place:
		for i in characterList:
			if not toSpawn.has(i):
				get_node(str(i)).queue_free()	
		for i in toSpawn:
			if not characterList.has(i):
#				var clientID = multiplayer.get_unique_id()
				var x = CharacterScene.instantiate()
				x.set_name(str(i))# Set the name, so players can figure out their local authority
				self.add_child.call_deferred(x, true)	
		prints("Characters synchronized on this client.")
			
	
