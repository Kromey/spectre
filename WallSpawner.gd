extends Spatial

var rng: RandomNumberGenerator

const Walls = [
	preload("res://obstacles/Wall.tscn"), # Basic wall should be the most common
	preload("res://obstacles/Wall.tscn"),
	preload("res://obstacles/Wall.tscn"),
	preload("res://obstacles/Wall.tscn"),
	preload("res://obstacles/Wall.tscn"),
	preload("res://obstacles/WindowedWall.tscn"),
	preload("res://obstacles/WindowedWall.tscn"),
	preload("res://obstacles/WindowedWall.tscn"),
	preload("res://obstacles/SawTeeth.tscn"),
	preload("res://obstacles/SawTeeth.tscn"),
	preload("res://obstacles/SawTeeth.tscn"),
	preload("res://obstacles/CWall.tscn"),
	preload("res://obstacles/Cross.tscn"),
	preload("res://obstacles/WindowedCross.tscn"),
	preload("res://obstacles/HalfWall.tscn"),
	preload("res://obstacles/HalfWall.tscn"),
]

const DESCENT_OFFSET := Vector3.DOWN * 1.5
onready var ORIGIN := global_transform.origin

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	global_transform.origin += DESCENT_OFFSET

func rebuild_walls(num_walls = 0, duration = 1, delay = 0.0):
	if num_walls == 0:
		num_walls = get_child_count()
	
	descend(duration, delay)
	yield(get_tree().create_timer(duration + delay, false), "timeout")
	spawn_walls(num_walls)
	rise(duration, 0)

func rise(duration = 1, delay = 0.75):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		self,
		"translation",
		ORIGIN + DESCENT_OFFSET,
		ORIGIN,
		duration,
		Tween.TRANS_SINE,
		Tween.EASE_OUT,
		delay
	)
	tween.start()
	var __ = tween.connect("tween_all_completed", tween, "queue_free")

func descend(duration = 1, delay = 0.75):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		self,
		"translation",
		ORIGIN,
		ORIGIN + DESCENT_OFFSET,
		duration,
		Tween.TRANS_SINE,
		Tween.EASE_OUT,
		delay
	)
	tween.start()
	var __ = tween.connect("tween_all_completed", tween, "queue_free")

func spawn_walls(num_walls, min_dist = 3, origin = Vector3.ZERO):
	for wall in get_children():
		wall.queue_free()
	
	var count = 0
	while count < num_walls:
		var x = rng.randi_range(-90, 90)
		var z = rng.randi_range(-90, 90)
		var r = rng.randi_range(0, 3) * PI / 2
		var i = rng.randi_range(0, Walls.size() - 1) # Range is inclusive
		
		var wall = Walls[i].instance()
		wall.translate(Vector3(x, 0, z))
		wall.rotate_y(r)
		if wall.translation.distance_to(origin) > min_dist:
			add_child(wall)
			count += 1
