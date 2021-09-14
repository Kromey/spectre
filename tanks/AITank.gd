extends "res://tanks/BaseTank.gd"

export(float) var MAX_ENGAGE_DISTANCE = 30
export(float) var MAX_CHASE_DISTANCE = 80

var current_target

var navigation
export(int) var navigation_lookahead = 3

func _ready():
	navigation = TankNavigation.new(self, navigation_lookahead)

func _physics_process(delta):
	if !is_instance_valid(current_target) or current_target.is_in_group("waypoints"):
		current_target = select_target(current_target)
	
	if is_instance_valid(current_target):
		if !engage_target(current_target, delta, current_target.is_in_group("player")):
			current_target = null

func select_target(target):
	var dist = INF
	for ptarget in get_tree().get_nodes_in_group("player"):
		var target_dist = translation.distance_to(ptarget.translation)
		if target_dist <= MAX_ENGAGE_DISTANCE and target_dist < dist:
			target = ptarget
			dist = target_dist
	
	if is_instance_valid(target):
		return target
	else:
		return set_patrol_target()

func set_patrol_target():
	var target = Position3D.new()
	target.add_to_group("waypoints")
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var target_pos = Vector3.FORWARD.rotated(Vector3.UP, rng.randf_range(0, 2 * PI))
	target_pos *= rng.randf_range(3, 8)
	target.translate(translation + target_pos)
	target.translation.y = 0.1
	
	if abs(target.translation.x) > 95 or abs(target.translation.z) > 95:
		# Didn't get a valid target, we'll just try again next frame
		return null
	else:
		get_tree().root.add_child(target)
		# Ensure we clean up our waypoints even if we get stuck/abandon them
		var _e = get_tree().create_timer(30).connect("timeout", target, "queue_free")
		
		return target

func engage_target(target, delta, attack = true):
	if !is_instance_valid(target):
		return false
	
	var dist = translation.distance_to(target.translation)
	if dist > MAX_CHASE_DISTANCE:
		return false
	elif dist < 1.5 and target.is_in_group("waypoints"):
		return false
	
	#var to_target = get_direction_to(target)
	var to_target = navigation.get_direction_to(target)
	var dot = (-transform.basis.z).dot(to_target)

	var facing_cone = 0.75
	var fire_cone = 0.90
	var speed = 1.0
	if target.is_in_group("waypoints"):
		speed = 0.3 # Patrol slower
	
	if dot > facing_cone:
		# Target is in front of us
		drive(Direction.FORWARD * speed, delta)

		if dot > fire_cone and attack and dist <= GUN_RANGE * 0.9:
			# Target is directly in front of us and in range!
			# NB: Not the target, but the "path around the obstacle", however this
			# is desirable behavior as it causes tanks to sometimes appear to
			# "lead" the player with otherwise "wild" shots around obstacles.
			shoot()
	elif dot < -facing_cone:
		# Target is behind us
		drive(Direction.BACK * speed, delta)

	# Is target left or right of us?
	var cross = transform.basis.z.cross(to_target).y
	var turn_threshold = 0.00
	if cross > turn_threshold:
		turn(Direction.RIGHT, delta)
	elif cross < -turn_threshold:
		turn(Direction.LEFT, delta)
	elif dot < 0:
		# Target is behind us AND we're not already turning
		# Turn in an arbitrary direction
		turn(Direction.RIGHT, delta)
	
	return true
