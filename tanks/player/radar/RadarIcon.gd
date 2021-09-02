extends Sprite

var me: Spatial
var center := Vector2.ZERO
var clamp_to := 75.0
export(bool) var rotate := false

func update_pos(xform: Transform, zoom := 1.0):
	if !is_instance_valid(me):
		queue_free()
		return
	
	var my_pos = to_relative_position2d(xform, me.global_transform.origin, zoom)
	position = my_pos + center

func to_relative_position2d(xform: Transform, point: Vector3, zoom: float):
	var pos = xform.xform_inv(point)
	pos = pos.normalized() * min(pos.length() * zoom, clamp_to)
	
	return Vector2(pos.x, pos.z)
