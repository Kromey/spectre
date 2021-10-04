extends Sprite

var me: Spatial
var center := Vector2.ZERO
var clamp_to := 72.0
var point_radius := 105.0
export(bool) var rotate := false
export(int, "hide", "shrink", "point") var clamp_behavior = CLAMP_HIDE

const CLAMP_HIDE = 0
const CLAMP_SHRINK = 1
const CLAMP_POINT = 2

onready var unscaled = scale

func update_pos(xform: Transform, zoom := 1.0):
	if !is_instance_valid(me):
		queue_free()
		return
	if !me.is_visible_in_tree():
		hide()
		return
	
	var my_pos = to_vec2(xform.xform_inv(me.global_transform.origin)) * zoom
	
	match clamp_behavior:
		CLAMP_HIDE:
			if my_pos.length() > clamp_to:
				hide()
				return
			else:
				show()
		
		CLAMP_SHRINK:
			if my_pos.length() > clamp_to:
				my_pos = my_pos.clamped(clamp_to)
				self_modulate = Color(1, 1, 1, 0.5)
				scale = unscaled * 0.5
			else:
				self_modulate = Color(1, 1, 1, 1)
				scale = unscaled
			
			show()
		
		CLAMP_POINT:
			if my_pos.length() > clamp_to:
				my_pos = my_pos.normalized() * point_radius
				rotation = my_pos.angle() + PI / 2
				show()
			else:
				hide()
				return
	
	position = my_pos + center
	
	if rotate:
		var looking = to_vec2(me.global_transform.basis.z)
		var radar_forward = to_vec2(xform.basis.z)
		
		rotation = looking.angle() - radar_forward.angle()

func to_vec2(vec: Vector3):
	return Vector2(vec.x, vec.z)
