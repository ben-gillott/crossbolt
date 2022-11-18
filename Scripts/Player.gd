extends KinematicBody2D


#MOVEMENT VARIABLES
export (int) var MOVE_SPEED = 500
export (int) var JUMP_VELOCITY = -700
export (int) var JUMP_GRAVITY = 1200
export (float, 0, 1.0) var FRICTION = 0.3
export (float, 0, 1.0) var ACCELERATION = 0.70

#FIRING VARIABLES
export (float, 0, 1.0) var RELOAD_SLOW_FACTOR = 0.8
export (int) var RELOAD_TIME = 2000 #ms

var velocity = Vector2.ZERO
var boltScene = preload("res://Scenes/Bolt.tscn")

func get_input():
	var dir = 0
	if Input.is_action_pressed("right"):
		dir += 1
	if Input.is_action_pressed("left"):
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * MOVE_SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
		
	#Shooting:
	if Input.is_action_just_pressed("fire"):
		shoot()

func shoot():
	var bolt = boltScene.instance()
	bolt.position = $BoltStart.global_position
	owner.add_child(bolt) #adds bolt to the world instead of the player
	

func _physics_process(delta):
	get_input()
	velocity.y += JUMP_GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	if position.y > 600:
		var Manager = get_parent().get_node("CoinManager")
		Manager._endOfTheGame()
		queue_free()



