extends Camera2D
@onready var customViewport: SubViewport = get_node('../../../')

func _ready():
	if get_parent().name.to_int() == multiplayer.get_unique_id():
#		self.set_custom_viewport(customViewport)
		self.make_current()
