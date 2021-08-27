extends Control

var tank1
var tank2
var camera
var width = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	tank1 = $"/root/TestScene/AITank"
	tank2 = $"/root/TestScene/AITankNew"
	camera = $"/root/TestScene/AITankNew/Camera"

func _process(_delta):
	if not visible:
		return
	update()

func _draw():
	# Old tank
	draw_vector(tank1.translation, tank1.velocity, Color(1, 1, 1))
	
	for i in tank1.NUM_RAYS:
		var vec = tank1.get_interest_ray(i)
		draw_vector(tank1.translation, vec, Color(0, 1, 0))
		
#		if tank.danger[i] > 0:
#			draw_vector(tank.translation, vec * 4)
	
	draw_vector(tank1.translation, tank1.get_interest_direction(), Color(0, 0, 1))
	
	# New tank
	draw_vector(tank2.translation, tank2.velocity, Color(1, 1, 1))
	draw_vector(tank2.translation, tank2.get_intent(tank2.current_target), Color(0, 0, 1))
	draw_vector(tank2.translation, tank2.get_bumper())
	
	draw_vector(tank2.translation, tank2.get_direction_to(tank2.current_target), Color(0, 1, 0))

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
