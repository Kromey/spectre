extends Spatial

#const PillBomb = preload("res://PillBomb.tscn")
const PlayerTank = preload("res://tanks/player/PlayerTank.tscn")
const AITank = preload("res://tanks/AITank.tscn")
const ArmorPickup = preload("res://ArmorPickup.tscn")
const Flag = preload("res://Flag.tscn")

const Walls = [
	preload("res://obstacles/Wall.tscn"),
	preload("res://obstacles/WindowedWall.tscn"),
	preload("res://obstacles/SawTeeth.tscn"),
]


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = PlayerTank.instance()
	player.translate(Vector3.UP * 0.2)
	player.add_to_group("player")
	GameStats.add_to_score(0)
	add_child(player)
	var _e = player.connect("dead", self, "player_death")
	call_deferred("first_shot", player)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for _i in 200:
		var x = rng.randi_range(-90, 90)
		var z = rng.randi_range(-90, 90)
		var r = rng.randi_range(0, 1) * PI / 2
		var i = rng.randi_range(0, Walls.size() + 1) # Allow extra numbers for bias
		if i >= Walls.size():
			i = 0 # Make the first wall more likely to be chosen
		
		var wall = Walls[i].instance()
		wall.translate(Vector3(x, 0, z))
		wall.rotate_y(r)
		add_child(wall)
	
	for _i in 20:
		var x = rng.randf_range(75, 90)
		var z = rng.randf_range(75, 90)
		
		if rng.randi_range(0, 1) == 1:
			x = -x
		if rng.randi_range(0, 1) == 1:
			z = -z
		
		var tank = AITank.instance()
		tank.translate(Vector3(x, 1, z))
		tank.add_to_group("enemies")
		add_child(tank)
		_e = tank.connect("dead", self, "tank_death")
	
	for _i in 35:
		spawn_pickup(ArmorPickup)
	
	for _i in 5:
		var x = rng.randf_range(-90, 90)
		var z = rng.randf_range(-90, 90)
		
		var flag = Flag.instance()
		flag.translate(Vector3(x, 0, z))
		add_child(flag)
		_e = flag.connect("body_entered", self, "_on_flag_pickup", [flag])

func spawn_pickup(scene):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var x = rng.randf_range(-90, 90)
	var z = rng.randf_range(-90, 90)
	
	var pickup = scene.instance()
	pickup.translate(Vector3(x, 0, z))
	pickup.connect("tree_exiting", self, "spawn_pickup", [scene])
	call_deferred("add_child", pickup)

func _on_flag_pickup(body, flag):
	if body.is_in_group("player"):
		GameStats.add_to_score(1)
		flag.queue_free()

# Pretty hacky, but calling this at game start ensures all our materials get
# compiled and eliminates "first-shot lag"
func first_shot(player):
	var gun_range = player.GUN_RANGE
	player.GUN_RANGE = 0
	player.shoot()
	player.GUN_RANGE = gun_range
	player.reload_immediate()

func player_death():
	print("Player died!")

func tank_death():
	print("Enemy tank died!")
