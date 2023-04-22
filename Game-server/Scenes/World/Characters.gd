extends Node2D
var toSpawn: PackedInt32Array:
	get:
		var x: Array
		for i in self.get_children():
			x.append(i.name.to_int())
		return x

func _enter_tree():
	self.child_entered_tree.connect(self._on_child_entered_tree)
	self.child_exiting_tree.connect(self._on_child_exiting_tree)

func _on_child_entered_tree(node):
	# When a character enter, the server ask all peers on the same scene for update/synchronize
	for i in self.get_children():
		rpc_id(i.name.to_int(), 'syncSpawn', get_parent().name, toSpawn)

func _on_child_exiting_tree(node):
	var temp = toSpawn
	temp.remove_at(toSpawn.find(node.name.to_int()))
	# Two lines above are needed because when this signal arrives the node
	# still in the scenetree... that's godot's behavior.
	for i in temp:
		rpc_id(i.name.to_int(), 'syncSpawn', get_parent().name, toSpawn)
	# If no more characters in this scene remove it.
	if temp.is_empty():
		self.get_parent().queue_free()
		prints('No more characters on scene', self.get_parent().name, 'removing...')
	else:
		#Otherwise, when a character exit, the server ask all peers on the same scene for update/synchronize
		for i in self.get_children():
			rpc_id(i.name.to_int(), 'syncSpawn', get_parent().name, toSpawn)

@rpc("call_local")
func syncSpawn(Place, Character):
	pass
