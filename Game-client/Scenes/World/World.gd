extends Node2D

var Place:
	get:
		return GameserverClient.Place
#func _on_child_entered_tree(node):
#	prints('child entered', node)
#	pass # Replace with function body.
#
#
#func _on_tree_entered():
#	GameserverClient.startGame()
#	pass # Replace with function body.

func _ready():
	var x = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	get_node('/root/World').add_child.call_deferred(x, true)
#	CharacterScene.set_name(str(id))# Set the name, so players can figure out their local authority
#	get_node('/root/World/' + Place + "/Characters").add_child(CharacterScene)
#	prints("New character created for player ID:", id)

