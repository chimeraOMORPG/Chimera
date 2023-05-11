extends Label

@onready var _sign: String = get_parent().name
var playanim: bool = true

func _ready():
	self.text = _sign
	var screen_size = get_viewport_rect().size
	self.position.x = (screen_size.x/2)-(_sign.length()/2)
	self.position.y = screen_size.y/2
	if playanim:
		pass
	

						
