extends Label

func _ready():
	var screen_size = get_viewport_rect().size
	var xStartPoint = (get_node('../../').get('_sign').length())/2
	self.text = get_node('../../').get('_sign')
	self.position.x = screen_size.x/2-xStartPoint
	self.position.y = screen_size.y/2
	

