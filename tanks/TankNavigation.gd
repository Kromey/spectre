extends Object
class_name TankNavigation

var _me
var _lookahead

func _init(me, lookahead = 3):
	_me = me
	_lookahead = lookahead

func get_direction_to(target):
	var intent = get_intent(target)
	var bumper = get_bumper()
	
	return (intent + bumper * 3).normalized()

func get_intent(target):
	var target_direction = _me.translation.direction_to(target.translation)
	var forward = -_me.transform.basis.z
	var space = _me.get_world().direct_space_state
	
	var obstacle = space.intersect_ray(_me.translation, target.translation, [self, target])
	if obstacle.empty():
		return target_direction
	
	var intended = target.translation - _me.translation
	var rays = 10
	var angle_step = PI * 1.25 / rays
	for i in rays:
		var vec1 = intended.rotated(Vector3.UP, angle_step * i)
		var vec2 = intended.rotated(Vector3.UP, -angle_step * i)
		
		var obs1 = space.intersect_ray(_me.translation, _me.translation + vec1, [self, target])
		var obs2 = space.intersect_ray(_me.translation, _me.translation + vec2, [self, target])
		
		if obs1.empty() and obs2.empty():
			# Pick one at random to avoid bias
			if rand_range(0, 1) == 1:
				return vec1.normalized()
			else:
				return vec2.normalized()
		elif obs1.empty():
			return vec1.normalized()
		elif obs2.empty():
			return vec2.normalized()
	
	return forward

func get_bumper():
	if _lookahead <= 0:
		return Vector3.ZERO
	
	var forward = -_me.transform.basis.z
	var space = _me.get_world().direct_space_state
	
	var hazard = Vector3.ZERO
	
	for i in 2:
		var bump1 = forward.rotated(Vector3.UP, (i + 1) * 0.2) * _lookahead
		var bump2 = forward.rotated(Vector3.UP, (i + 1) * -0.2) * _lookahead
		
		# If we see an obstacle, add our counterpart, rotated by an extra radian for extra "oomph"
		if !space.intersect_ray(_me.translation, _me.translation + bump1, [self]).empty():
			hazard += bump2.rotated(Vector3.UP, -1)
		if !space.intersect_ray(_me.translation, _me.translation + bump2, [self]).empty():
			hazard += bump1.rotated(Vector3.UP, 1)
	
	if hazard.length() > 0:
		return hazard.normalized()
	else:
		return Vector3.ZERO
