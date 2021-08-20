extends "res://tanks/BaseTank.gd"

export(float) var FIRE_RATE = 1.5
export(float) var RELOAD_TIME = 3

var kill_target

# Called when the node enters the scene tree for the first time.
func _ready():
	kill_target = get_tree().get_nodes_in_group("player")[0]
	$FireTimer.wait_time = FIRE_RATE
	$ReloadTimer.wait_time = RELOAD_TIME

func _physics_process(delta):
	if is_instance_valid(kill_target):
		# Get direction to target; dot product >0 if in front, else behind
		var to_target = kill_target.translation.direction_to(translation)
		var dot = transform.basis.z.dot(to_target)

		var cone = 0.75
		if dot > cone:
			# Target is in front of us
			drive(Direction.FORWARD, delta)
		elif dot < -cone:
			# Target is behind us
			drive(Direction.BACK, delta)

		# Is target left or right of us?
		var cross = transform.basis.z.cross(to_target).y
		if cross > 0:
			turn(Direction.LEFT, delta)
		elif cross < 0:
			turn(Direction.RIGHT, delta)
	
	if ammo == 0 and $ReloadTimer.time_left == 0:
		print("Reloading...")
		$ReloadTimer.start()
