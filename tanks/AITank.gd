extends "res://tanks/BaseTank.gd"

export(float) var MAX_ENGAGE_DISTANCE = 30
export(float) var MAX_CHASE_DISTANCE = 80

var kill_target

func _physics_process(delta):
	if is_instance_valid(kill_target):
		var dist = translation.distance_to(kill_target.translation)
		if dist <= MAX_CHASE_DISTANCE:
			# Get direction to target; dot product >0 if in front, else behind
			var to_target = kill_target.translation.direction_to(translation)
			var dot = transform.basis.z.dot(to_target)

			var facing_cone = 0.75
			var fire_cone = 0.90
			if dot > facing_cone:
				# Target is in front of us
				drive(Direction.FORWARD, delta)

				if dot > fire_cone and dist <= GUN_RANGE * 0.9:
					# Target is directly in front of us and in range!
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
			elif dot < 0:
				# Target is behind us AND we're not already turning
				# Turn in an arbitrary direction
				turn(Direction.RIGHT, delta)
		else:
			kill_target = null
	else:
		var dist = INF
		for target in get_tree().get_nodes_in_group("player"):
			var target_dist = translation.distance_to(target.translation)
			if target_dist <= MAX_ENGAGE_DISTANCE and target_dist < dist:
				kill_target = target
				dist = target_dist
	
	if ammo == 0 and !reloading:
		reload()
