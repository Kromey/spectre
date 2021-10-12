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
export(int) var pool_size = 450 # Should be more than the largest number at a time to give some variety

var pool = []
var last_wall_count = 250 # Arbitrary default value

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	global_transform.origin += DESCENT_OFFSET
	
	for i in pool_size:
		var wall = Walls[i % Walls.size()].instance()
		add_child(wall)
		hide_wall(wall)
		pool.append(wall)

func rebuild_walls(num_walls = 0, duration = 1, delay = 0.0):
	if num_walls == 0:
		num_walls = last_wall_count
	
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

func hide_wall(wall):
	# "Hide" walls by moving them very very far away
	wall.translation = DESCENT_OFFSET * 5000

func spawn_walls(num_walls, min_dist := 3.0, origin := Vector3.ZERO):
	last_wall_count = num_walls
	
	if origin == Vector3.ZERO and is_instance_valid(Game.world.player):
			origin = Game.world.player.global_transform.origin
	
	var count = 0
	pool.shuffle()
	for wall in pool:
		if count >= num_walls:
			hide_wall(wall)
			continue
		
		var x = rng.randi_range(-90, 90)
		var z = rng.randi_range(-90, 90)
		var r = rng.randi_range(0, 3) * PI / 2
		
		wall.translation = Vector3(x, 0, z)
		wall.rotate_y(r)
		if wall.translation.distance_to(origin) > min_dist:
			count += 1
		else:
			hide_wall(wall)
	
	prints("Showing", count, "pooled walls")
