extends Area2D

var direction: Vector2
var speed: int = 700

func _ready():
	direction = position.direction_to(get_global_mouse_position()).normalized()
	var angle = position.angle_to_point(get_global_mouse_position())
	rotation = angle - PI/2
	
func _process(delta):
	position += direction * speed * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("mobs"):
		body.queue_free()
	queue_free()
