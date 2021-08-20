extends "res://tanks/BaseTank.gd"

#const GRAVITY = 2 * Vector3.DOWN
const ACCEL = 2
const DEACCEL = ACCEL * 2
const MAX_SPEED = 10
const TURN_RATE = PI / 2.0 # Radians/sec
const TURN_INERTIA = 8

var Bullet = preload("res://tanks/Bullet.tscn")

var velocity = Vector3.ZERO
var turn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	# -----
	# Turning
	var turn_input = 0
	
	if Input.is_action_pressed("movement_left"):
		turn_input += TURN_RATE * delta
	if Input.is_action_pressed("movement_right"):
		turn_input -= TURN_RATE * delta
	
	var inertia = TURN_INERTIA
	if abs(turn_input) < abs(turn):
		# Stop turning twice as fast as we started
		inertia *= 2
	
	turn = lerp(turn, turn_input, inertia * delta)
	rotate_y(turn)
	# -----
	
	# -----
	# Gravity
	#velocity += GRAVITY * delta
	
	# -----
	# Acceleration
	if is_on_floor():
		var dir = Vector3.ZERO
		var hvel = velocity
		hvel.y = 0
		
		if Input.is_action_pressed("movement_forward"):
			dir += Vector3.FORWARD
		if Input.is_action_pressed("movement_backward"):
			dir += Vector3.BACK
		
		dir = transform.basis.z * dir.normalized().z
		
		var target = dir * MAX_SPEED
		
		var accel
		if dir.dot(hvel) > 0:
			accel = ACCEL
		else:
			accel = DEACCEL
		
		hvel = hvel.linear_interpolate(target, accel * delta)
		velocity.x = hvel.x
		velocity.z = hvel.z
	
	velocity = move_and_slide(velocity, Vector3.UP)
	# -----

func _input(event):
	if event.is_action_pressed("action_shoot"):
		var bullet = Bullet.instance()
		#bullet.BULLET_TIME = 1.5
		bullet.BULLET_SPEED = MAX_SPEED * 1.2
		bullet.global_transform = $BulletSpawn.global_transform
		get_tree().root.add_child(bullet)
