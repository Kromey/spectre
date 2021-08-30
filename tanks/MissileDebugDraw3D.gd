extends Control

onready var missile = self.owner
var width = 1

func _process(_delta):
	if not visible:
		return
	update()

func _draw():
	var pos = missile.global_transform.origin
	
	draw_vector(pos, missile.velocity, Color(1, 1, 1))
	#draw_vector(missile.translation, missile.seek(), Color(0, 1, 0))
	
	if is_instance_valid(missile.target):
		draw_vector(pos, pos.direction_to(missile.target.global_transform.origin) * missile.speed)

func draw_vector(origin, vec, color = Color(1, 0, 0)):
	if vec.length() == 0:
		return
	
	var camera = get_viewport().get_camera()
	var start = camera.unproject_position(origin)
	var end = camera.unproject_position(origin + vec)
	
	draw_line(start, end, color, width)
	draw_triangle(end, start.direction_to(end), width * 2, color)

func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2 * PI / 3) * size
	var c = pos + dir.rotated(4 * PI / 3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
