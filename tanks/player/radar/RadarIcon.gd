extends Sprite

var me: Spatial
var center := Vector2.ZERO
var clamp_to := 75.0
export(bool) var rotate := false

func update_pos(xform: Transform, zoom := 1.0):
	if !is_instance_valid(me):
		queue_free()
		return
	
	var my_pos = to_vec2(xform.xform_inv(me.global_transform.origin)) * zoom
	position = my_pos.clamped(clamp_to) + center
	
	if rotate:
		var looking = to_vec2(me.global_transform.basis.z)
		var radar_forward = to_vec2(xform.basis.z)
		
		rotation = looking.angle() - radar_forward.angle()

func to_vec2(vec: Vector3):
	return Vector2(vec.x, vec.z)
