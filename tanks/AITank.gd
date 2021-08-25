extends "res://tanks/BaseTank.gd"

export(float) var MAX_CHASE_DISTANCE = 40

var kill_target

# Called when the node enters the scene tree for the first time.
#func _ready():
#	kill_target = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	if is_instance_valid(kill_target) and translation.distance_to(kill_target.translation) <= MAX_CHASE_DISTANCE:
		# Get direction to target; dot product >0 if in front, else behind
		var to_target = kill_target.translation.direction_to(translation)
		var dot = transform.basis.z.dot(to_target)

		var facing_cone = 0.75
		var fire_cone = 0.90
		if dot > facing_cone:
			# Target is in front of us
			drive(Direction.FORWARD, delta)

			if dot > fire_cone:
				# Target is directly in front of us!
				shoot()
		elif dot < -facing_cone:
			# Target is behind us
			drive(Direction.BACK, delta)

		# Is target left or right of us?
		var cross = transform.basis.z.cross(to_target).y
		var turn_threshold = 0.08
		if cross > turn_threshold:
			turn(Direction.LEFT, delta)
		elif cross < -turn_threshold:
			turn(Direction.RIGHT, delta)
	else:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			kill_target = players[0]
	
	if ammo == 0 and !reloading:
		reload()
