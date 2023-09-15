extends Control

var tank1
var tank2
var tank3
var width = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	tank1 = $"/root/TestScene/AITank"
	tank2 = $"/root/TestScene/AITank2"
	tank3 = $"/root/TestScene/AITank3"

func _process(_delta):
	if not visible:
		return
	update()

func _draw():
	for tank in [tank1, tank2, tank3]:
		if !is_instance_valid(tank):
			continue
		
		draw_vector(tank.position, tank.velocity, Color(1, 1, 1))
		draw_vector(tank.position, tank.navigation.get_bumper())
		
		if is_instance_valid(tank.current_target):
			draw_vector(tank.position, tank.navigation.get_intent(tank.current_target), Color(0, 0, 1))
			draw_vector(tank.position, tank.navigation.get_direction_to(tank.current_target), Color(0, 1, 0))

func draw_vector(origin, vec, color = Color(1, 0, 0)):
	if vec.length() == 0:
		return
	
	var camera = get_viewport().get_camera_3d()
	var start = camera.unproject_position(origin)
	var end = camera.unproject_position(origin + vec)
	
	draw_line(start, end, color, width)
	draw_triangle(end, start.direction_to(end), width * 2, color)

func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2 * PI / 3) * size
	var c = pos + dir.rotated(4 * PI / 3) * size
	var points = PackedVector2Array([a, b, c])
	draw_polygon(points, PackedColorArray([color]))
