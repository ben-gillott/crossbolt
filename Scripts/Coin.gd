extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	position.y = 20
	pass # Replace with function body.

var gravityVal = 100
var velocityVal = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y = position.y + velocityVal * delta
	velocityVal += gravityVal * delta
	
	if(position.y > 900):
		queue_free()
	pass
