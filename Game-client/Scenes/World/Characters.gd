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
#			elif stillAnyOne():
#				thisScene.queue_free()	
		else:	
			for i in serverCharachterList:
				if not characterList.has(i):
					var x = CharacterScene.instantiate()
					x.set_name(str(i))# Set the name, so players can figure out their local authority
					self.add_child(x, true)

	#		if stillAnyOne():
	#			thisScene.queue_free()
		if node.to_int() == multiplayer.get_unique_id():
			trasition.play('trans_in')

#func stillAnyOne() -> bool:
#	if characterList.is_empty():
#		return true
#	for i in get_children():
#		if not i.is_queued_for_deletion():
#			return false
#	return true

#@rpc("authority")
#func syncSpawn(Place, node, entered, serverCharachterList):
#	if thisScene.name == Place:
#		if entered:
#			prints(node, 'entrato in', Place)
#			prints('serverlist:', serverCharachterList, 'characterlist:', characterList)
#			for i in serverCharachterList:
#				if not characterList.has(i):
#					prints(multiplayer.get_unique_id(), 'non ha il nodo', i, 'aggiungo...')
#					var x = CharacterScene.instantiate()
#					x.set_name(str(i))# Set the name, so players can figure out their local authority
#					self.add_child(x, true)
#		else:
#			prints('chiamato:', multiplayer.get_unique_id(), node, 'uscito da', Place)
#			if node.to_int() == multiplayer.get_unique_id():
#				thisScene.queue_free()
#			else:
#				for i in characterList:
#					if not serverCharachterList.has(i):
#						get_node(str(i)).queue_free()
##				get_node(node).queue_free()
#		prints("Characters synchronized on this client.")
#		if node.to_int() == multiplayer.get_unique_id():
#			trasition.play('trans_in')
#	else:
#		prints('A problem has occurred retrieving', Place, 'as the active scene on this client....')
#
