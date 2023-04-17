extends Node2D

func _ready():
	for i in get_parent().get_children():
		if i.name != self.name:
			i.queue_free()
