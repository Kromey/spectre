extends "res://tanks/BaseTank.gd"

export(float) var MAX_ENGAGE_DISTANCE = 30
export(float) var MAX_CHASE_DISTANCE = 80

var current_target

func _physics_process(delta):
	current_target = select_target()
	if !engage_target(current_target, delta):
		current_target = null
	
	if ammo == 0 and !reloading:
		reload()

func select_target():
	var dist = INF
	var target = null
	for ptarget in get_tree().get_nodes_in_group("player"):
		var target_dist = translation.distance_to(ptarget.translation)
		if target_dist <= MAX_ENGAGE_DISTANCE and target_dist < dist:
			target = ptarget
			dist = target_dist
	
	return target

func engage_target(target, delta, attack = true):
	if !is_instance_valid(target):
		return false
	
	var dist = translation.distance_to(target.translation)
	if dist > MAX_CHASE_DISTANCE:
		return false
	
	var to_target = target.translation.direction_to(translation)
	var dot = transform.basis.z.dot(to_target)

	var facing_cone = 0.75
	var fire_cone = 0.90
	if dot > facing_cone:
		# Target is in front of us
		drive(Direction.FORWARD, delta)

		if dot > fire_cone and attack and dist <= GUN_RANGE * 0.9:
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
	
	return true
