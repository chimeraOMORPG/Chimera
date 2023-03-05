extends Sprite2D
var rotation_speed = PI*2


func _physics_process(delta):
	rotation += rotation_speed * delta
