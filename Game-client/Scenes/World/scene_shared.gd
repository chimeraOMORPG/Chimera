extends SubViewportContainer

func _enter_tree():
	for i in get_parent().get_children():
		if i.name != self.name and i.name != StringName('transition'):
			i.queue_free()
