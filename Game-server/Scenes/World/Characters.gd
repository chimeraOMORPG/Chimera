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
	SynchroHub.character_spawned(thisScene.name, node.name, characterList)	

func _on_child_exiting_tree(node):	
	for i in characterList:
		if multiplayer.get_peers().has(i):
			var error = SynchroHub.character_exiting(thisScene.name, node.name, characterList)
			if error:
				prints('Error calling syncSpam:', error)

	# Two lines above are needed because when this signal arrives the node
	# still in the scenetree... that's godot's behavior.
	#	if multiplayer.get_peers().has(node.name.to_int()):			
	characterList.remove_at(characterList.find(node.name.to_int()))

	if characterList.is_empty(): # If no more characters in this scene remove it.
		thisScene.queue_free.call_deferred()
		prints('No more characters on scene', thisScene.name, 'removing...')
