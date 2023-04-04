extends Node2D

func addScene(Place):
	if not self.get_children().is_empty():
		if self.has_node(Place):
			print('Scene already exist')
			return true
	print('Not existent scene (or empty World), creating...')
	var p = load('res://Scenes/World/' + Place + '.tscn').instantiate()
	get_node("/root/World").add_child(p, true)
	var error = get_node_or_null('/root/World/' + Place)
	while error == null:
		print('waiting')
		error = get_node_or_null('/root/World/' + Place)
	return true
	
func destroy_player(id : int) -> void:
	for i in get_node('/root/World').get_children():
		if i.get_node('Characters').has_node(str(id)):
			i.get_node('Characters').get_node(str(id)).queue_free()
			prints('Player ID', id, 'character istance destroyed')
			break
		print('Errore destroying character istance, inexistent...')
	
