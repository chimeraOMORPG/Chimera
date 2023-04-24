extends Node2D

@export var characterList: PackedInt32Array:
	get:
		var x: Array = []
		for i in self.get_children():
			x.append(i.name.to_int())
		return x

func _enter_tree():
	self.child_exiting_tree.connect(self._on_child_exiting_tree)

func newCharacter(id):
	# When a character enter, the server ask all peers on the same scene for update/synchronize
	for i in characterList:
		rpc_id(i, 'syncSpawn', get_parent().name, characterList, id)

func _on_child_exiting_tree(node):
	var temp = characterList
	temp.remove_at(characterList.find(node.name.to_int()))
	# Two lines above are needed because when this signal arrives the node
	# still in the scenetree... that's godot's behavior.
	if temp.is_empty(): # If no more characters in this scene remove it.
		self.get_parent().queue_free.call_deferred()
		prints('No more characters on scene', self.get_parent().name, 'removing...')
	else:
		#Otherwise, when a character exit, the server ask all peers on the same scene for update/synchronize
		for i in temp:
			rpc_id(i, 'syncSpawn', get_parent().name, characterList, node.name)

@rpc("call_local")
func syncSpawn(_Place, _Character):
	pass
