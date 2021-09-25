extends "res://tanks/BaseTank.gd"

onready var PlayerCamera = find_node("Camera")
onready var HUD = find_node("PlayerHUD")

const BOOMCAM = preload("res://tanks/BoomCam.tscn")

enum PlayerState {
	Running,
	Locked,
}
var current_state = PlayerState.Running

var turn_input := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerCamera.make_current()
	
	HUD.update_ammo(ammo, MAX_AMMO)
	HUD.update_armor(armor, MAX_ARMOR)
	HUD.update_score(Game.player_score)
	HUD.update_kills(Game.player_kills)
	HUD.update_level(Game.level)

func _physics_process(delta):
	match current_state:
		PlayerState.Running:
			# -----
			# Turning
			
			if Input.is_action_pressed("movement_left"):
				turn_input += Direction.LEFT
			if Input.is_action_pressed("movement_right"):
				turn_input += Direction.RIGHT
			
			turn(clamp(turn_input, -1.25, 1.25), delta)
			turn_input = 0.0
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
	match current_state:
		PlayerState.Running:
			if event.is_action_pressed("action_shoot"):
				shoot()
			elif event.is_action_pressed("action_reload"):
				reload()
			elif event is InputEventMouseMotion:
				turn_input -= event.relative.x * 0.2

func die(killer):
	var cam = BOOMCAM.instance()
	cam.translation = translation
	get_parent().add_child(cam)
	cam.get_node("Camera").current = true
	
	.die(killer)

func set_state(state):
	current_state = state

func update_score(score):
	HUD.update_score(score)

func update_bonus(bonus):
	HUD.update_bonus(bonus)

func update_kills(kills):
	HUD.update_kills(kills)

func update_level(level):
	HUD.update_level(level)
