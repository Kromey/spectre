extends Spatial

#const PillBomb = preload("res://PillBomb.tscn")
const PlayerTank = preload("res://tanks/player/PlayerTank.tscn")
const AITank = preload("res://tanks/AITank.tscn")
const AdvancedTank = preload("res://tanks/AdvancedTank.tscn")
const Turret = preload("res://tanks/Turret.tscn")
const MissileTurret = preload("res://tanks/MissileTurret.tscn")
const ArmorPickup = preload("res://ArmorPickup.tscn")
const Flag = preload("res://Flag.tscn")

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


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var player = PlayerTank.instance()
	player.translate(Vector3.UP * 0.2)
	GameStats.add_to_score(0)
	add_child(player)
	var _e = player.connect("dead", self, "player_death")
	call_deferred("first_shot", player)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var num_walls = 0
	while num_walls < 250:
		var x = rng.randi_range(-90, 90)
		var z = rng.randi_range(-90, 90)
		var r = rng.randi_range(0, 3) * PI / 2
		var i = rng.randi_range(0, Walls.size() - 1) # Range is inclusive
		
		var wall = Walls[i].instance()
		wall.translate(Vector3(x, 0, z))
		wall.rotate_y(r)
		if wall.translation.distance_to(player.translation) > 3:
			add_child(wall)
			num_walls += 1
	print("Spawned ", num_walls, " walls")
	
	for _i in 35:
		spawn_pickup(ArmorPickup)
	
	var num_flags = 0
	while num_flags < 5:
		var x = rng.randf_range(-90, 90)
		var z = rng.randf_range(-90, 90)
		
		var flag = Flag.instance()
		flag.translate(Vector3(x, 0, z))
		flag.add_to_group("goals")
		if flag.translation.distance_to(player.translation) > 50:
			add_child(flag)
			_e = flag.connect("body_entered", self, "_on_flag_pickup", [flag])
			num_flags += 1
			
			var tanks = rng.randi_range(3, 7)
			for _t in tanks:
				spawn_tank(AITank, flag.translation, 0.5, 4.5)
			spawn_tank(Turret, flag.translation, 0.5, 1.5)
			spawn_tank(MissileTurret, flag.translation, 1.5, 3.5)
			spawn_tank(AdvancedTank, flag.translation, 3.0, 5.0)
	
	for _i in 35:
		spawn_tank(AITank, player.translation, 50, 95)

func spawn_tank(scene, around, min_dist, max_dist):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var local_pos = Vector3.FORWARD.rotated(Vector3.UP, rng.randf_range(0, 2 * PI))
	local_pos *= rng.randf_range(min_dist, max_dist)
	local_pos.x = clamp(local_pos.x, -95, 95)
	local_pos.z = clamp(local_pos.z, -95, 95)
	
	var tank = scene.instance()
	tank.translate(around + local_pos + Vector3.UP)
	tank.add_to_group("enemies")
	add_child(tank)
	var _e = tank.connect("dead", self, "tank_death")

func spawn_pickup(scene):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var x = rng.randf_range(-90, 90)
	var z = rng.randf_range(-90, 90)
	
	var pickup = scene.instance()
	pickup.translate(Vector3(x, 0, z))
	pickup.connect("tree_exiting", self, "spawn_pickup", [scene])
	call_deferred("add_child", pickup)

func _on_flag_pickup(_body, flag):
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

func player_death(_killer):
	print("Player died!")

func tank_death(killer):
	print("Enemy tank died!")
	if is_instance_valid(killer) and killer.is_in_group("player"):
		print("\tWe blame the player!")
		GameStats.add_to_kills(1)
	elif is_instance_valid(killer) and killer.is_in_group("enemies"):
		print("\tFriendly fire casualty!")
