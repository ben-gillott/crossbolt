extends KinematicBody2D


#MOVEMENT VARIABLES
export (int) var MOVE_SPEED = 500
export (int) var JUMP_VELOCITY = -700
export (int) var JUMP_GRAVITY = 1200
export (float, 0, 1.0) var FRICTION = 0.3
export (float, 0, 1.0) var ACCELERATION = 0.70
enum moveState {IN_AIR, MOVING, IDLE}
var velocity = Vector2.ZERO
var loaded: bool = true

#FIRING VARIABLES
export (float, 0, 1.0) var RELOAD_MOVEMENT_SLOW = 0.8
export var FIRE_DURATION = .3 #secs

var boltScene = preload("res://Scenes/Bolt.tscn")
enum ACTIONS {FIRING, MELEEING, RELOADING, IDLE}
var actionState = ACTIONS.IDLE
export var RELOAD_TIME = .6 #secs
var reloadTimer = 0



func get_input(delta):
	var dir = 0
	if Input.is_action_pressed("right"):
		dir += 1
	if Input.is_action_pressed("left"):
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * MOVE_SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
	
	
	if Input.is_action_just_pressed("fire"):
		if actionState == ACTIONS.FIRING: #Cant fire while firing
			print("Cant fire while firing")
		elif loaded:
			shoot()
		else:
			melee()
	elif Input.is_action_pressed("reload"):
		reload(delta)
	elif (not Input.is_action_pressed("reload")) and (actionState == ACTIONS.RELOADING):
		print("reload released early")
		actionState = ACTIONS.IDLE;
		reloadTimer = 0


func reload(delta):
	if loaded:
		print("already loaded")
	elif actionState == ACTIONS.FIRING or actionState == ACTIONS.MELEEING:
		print("fire while reloading - reload interrupted")
		reloadTimer = 0
	elif actionState == ACTIONS.IDLE:
		print("starting reload")
		actionState = ACTIONS.RELOADING
		reloadTimer = 0
	elif actionState == ACTIONS.RELOADING:
		print("Reloading, at ", reloadTimer, " ms")
		reloadTimer += delta
		if reloadTimer >= RELOAD_TIME:
			loaded = true
			print("Reloaded!")
			actionState = ACTIONS.IDLE
	
	
func shoot():
	actionState = ACTIONS.FIRING
	print("Firing")
	var bolt = boltScene.instance()
	bolt.position = $BoltStart.global_position
	owner.add_child(bolt) #adds bolt to the world instead of the player
	yield(get_tree().create_timer(FIRE_DURATION), "timeout")
	loaded = false
	actionState = ACTIONS.IDLE
	
func melee():
	actionState = ACTIONS.MELEEING
	print("Melee attack - *wham*")
	actionState = ACTIONS.IDLE
	
func _physics_process(delta):
	get_input(delta)
	flip()
	bow_animation()
	
	velocity.y += JUMP_GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	if position.y > 600:
		var Manager = get_parent().get_node("CoinManager")
		Manager._endOfTheGame()
		queue_free()


var lookDir = 1
func flip():
	var diff = get_global_mouse_position().x - global_position.x
	var flipZoneWidth = 10 #Declare a mid zone to eliminate jittering
	if abs(diff) > flipZoneWidth and lookDir != sign(diff): #if beyond little mid zone
		apply_scale(Vector2(-1, 1)) # flip
		lookDir = sign(diff)



var bowMaxScale = 22
var bowMaxPos = 16
var bowMinScale = 4
var bowMinPos = 25
var loadedColor = Color(0,1,0)
var loadingColor = Color(1,0,1)
var notLoadedColor = Color(1,0,0)
#this should be handled by animation tree later
func bow_animation():
	if loaded:
		$Crossbow_Bow.modulate = loadedColor
		$Crossbow_Draw.modulate = loadedColor
		$Crossbow_Draw.position.x = bowMaxPos
		$Crossbow_Draw.scale.x = bowMaxScale
	elif actionState == ACTIONS.RELOADING:
		#lerp size by timer
		$Crossbow_Bow.modulate = loadingColor
		$Crossbow_Draw.modulate = loadingColor
		$Crossbow_Draw.position.x = lerp(bowMinPos, bowMaxPos, reloadTimer/RELOAD_TIME)
		$Crossbow_Draw.scale.x = lerp(bowMinScale, bowMaxScale, reloadTimer/RELOAD_TIME)
	else: #not reloading and not loaded
		$Crossbow_Bow.modulate = notLoadedColor
		$Crossbow_Draw.modulate = notLoadedColor
		$Crossbow_Draw.position.x = bowMinPos
		$Crossbow_Draw.scale.x = bowMinScale
