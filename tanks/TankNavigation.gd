extends Object
class_name TankNavigation

var me
var lookahead

func _init(_me, _lookahead = 3):
	me = _me
	lookahead = _lookahead

func get_direction_to(target):
	var intent = get_intent(target)
	var bumper = get_bumper()
	
	return (intent + bumper * 3).normalized()

func get_intent(target):
	var target_direction = me.position.direction_to(target.position)
	var forward = -me.transform.basis.z
	var space = me.get_world_3d().direct_space_state
	
	var obstacle = space.intersect_ray(me.position, target.position, [self, target])
	if obstacle.is_empty():
		return target_direction
	
	var intended = target.position - me.position
	var rays = 10
	var angle_step = PI * 1.25 / rays
	for i in rays:
		var angle = angle_step * (i + 1) # Start at 1 because we already did a ray at 0
		var vec1 = intended.rotated(Vector3.UP, angle)
		var vec2 = intended.rotated(Vector3.UP, -angle)
		
		var obs1 = space.intersect_ray(me.position, me.position + vec1, [self, target])
		var obs2 = space.intersect_ray(me.position, me.position + vec2, [self, target])
		
		# We'll have a very slight bias to one direction if both are clear, but
		# this should be rare in practice
		if obs1.is_empty():
			return vec1.normalized()
		elif obs2.is_empty():
			return vec2.normalized()
	
	return forward

func get_bumper():
	if lookahead <= 0:
		return Vector3.ZERO
	
	var forward = -me.transform.basis.z
	var space = me.get_world_3d().direct_space_state
	
	var hazard = Vector3.ZERO
	
	for i in 2:
		var bump1 = forward.rotated(Vector3.UP, (i + 1) * 0.2) * lookahead
		var bump2 = forward.rotated(Vector3.UP, (i + 1) * -0.2) * lookahead
		
		# If we see an obstacle, add our counterpart, rotated by an extra radian for extra "oomph"
		if !space.intersect_ray(me.position, me.position + bump1, [self]).is_empty():
			hazard += bump2.rotated(Vector3.UP, -1)
		if !space.intersect_ray(me.position, me.position + bump2, [self]).is_empty():
			hazard += bump1.rotated(Vector3.UP, 1)
	
	if hazard.length() > 0:
		return hazard.normalized()
	else:
		return Vector3.ZERO
