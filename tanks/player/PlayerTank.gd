extends "res://tanks/BaseTank.gd"

onready var PlayerCamera = find_node("Camera")
onready var HUD = find_node("PlayerHUD")

signal score_changed
signal kills_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerCamera.make_current()
	
	emit_signal("ammo_changed", ammo)
	emit_signal("damage_changed", damage, MAX_DAMAGE)
	emit_signal("score_changed", GameStats.player_score)
	emit_signal("kills_changed", GameStats.player_kills)

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

func update_score(score):
	emit_signal("score_changed", score)

func update_kills(kills):
	emit_signal("kills_changed", kills)
