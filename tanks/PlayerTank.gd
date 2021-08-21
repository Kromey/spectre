extends "res://tanks/BaseTank.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	# -----
	# Turning
	var turn_input = 0
	
	if Input.is_action_pressed("movement_left"):
		turn_input += Direction.LEFT
	if Input.is_action_pressed("movement_right"):
		turn_input += Direction.RIGHT
	turn(turn_input, delta)
	# -----
	
	# -----
	# Acceleration
	var dir = 0
	if is_on_floor():
		if Input.is_action_pressed("movement_forward"):
			dir += Direction.FORWARD
		if Input.is_action_pressed("movement_backward"):
			dir += Direction.BACK
	drive(dir, delta)
	# -----

func _input(event):
	if event.is_action_pressed("action_shoot"):
		shoot()
	elif event.is_action_pressed("action_reload"):
		reload()
