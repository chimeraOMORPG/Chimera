extends Node

@export var characterList: PackedInt32Array:
	get:
		var x: Array = []
		for i in self.get_children():
			x.append(i.name.to_int())
		return x
		
var thisScene: SubViewportContainer:
	get:
		return self.get_node('../../')

func _enter_tree():
	self.child_entered_tree.connect(self._on_child_entered_tree)
	self.child_exiting_tree.connect(self._on_child_exiting_tree)

func _on_child_entered_tree(node):
	# When a character enter, the server ask all peers on the same scene for update/synchronize
	for i in characterList:
		rpc_id(i, 'syncSpawn', thisScene.name, node.name, characterList, false)

func _on_child_exiting_tree(node):
	if multiplayer.get_peers().has(node.name.to_int()):
		var temp = characterList
		temp.remove_at(temp.find(node.name.to_int()))
		# Two lines above are needed because when this signal arrives the node
		# still in the scenetree... that's godot's behavior.
		for i in characterList:
			prints('chiamo', i, 'uscito da:', thisScene.name, 'nodo uscito:', node.name)
			rpc_id(i, 'syncSpawn', thisScene.name, node.name, temp, true)
		if temp.is_empty(): # If no more characters in this scene remove it.
			thisScene.queue_free()
			prints('No more characters on scene', thisScene.name, 'removing...')
			#Otherwise, when a character exit, the server ask all peers on the same scene for update/synchronize


@rpc("call_local")
func syncSpawn(_Place, _Character):
	pass
