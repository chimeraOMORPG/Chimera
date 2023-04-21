extends Node2D
var toSpawn: PackedInt32Array:
	get:
		var x: Array
		for i in self.get_children():
			x.append(i.name.to_int())
		return x

func _on_child_entered_tree(node):
	rpc_id.call_deferred(0, 'syncSpawn', get_parent().name, toSpawn)

func _on_child_exiting_tree(node):
	var temp = toSpawn
	temp.remove_at(toSpawn.find(node.name.to_int()))
	# Two lines above are needed because when this signal arrives the node
	# still in the scenetree... that's godot's behavior.
	rpc_id(0, 'syncSpawn', get_parent().name, (temp))
	
@rpc("call_local")
func syncSpawn(Place, Character):
	pass
