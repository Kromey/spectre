extends Control

var tank
var camera
var width = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	tank = $"/root/TestScene/AITank"
	camera = $"/root/TestScene/AITank/Camera"

func _process(_delta):
	if not visible:
		return
	update()

func _draw():
	var color = Color(1, 1, 1)
	draw_vector(tank.translation, tank.velocity, color)
	
	for i in tank.NUM_RAYS:
		var vec = tank.get_ray(i) * (tank.interest[i] + tank.danger[i])
		draw_vector(tank.translation, vec, Color(0, 1, 0))
		
#		if tank.danger[i] > 0:
#			draw_vector(tank.translation, vec * 4)
	
	draw_vector(tank.translation, tank.get_interest_direction(), Color(0, 0, 1))

func draw_vector(origin, vec, color = Color(1, 0, 0)):
	if vec.length() == 0:
		return
	
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
