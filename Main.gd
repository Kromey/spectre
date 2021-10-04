extends Spatial

#const PillBomb = preload("res://PillBomb.tscn")
const PlayerTank = preload("res://tanks/player/PlayerTank.tscn")
const AITank = preload("res://tanks/AITank.tscn")
const AdvancedTank = preload("res://tanks/AdvancedTank.tscn")
const Turret = preload("res://tanks/Turret.tscn")
const MissileTurret = preload("res://tanks/MissileTurret.tscn")
const ZoomZoom = preload("res://pickups/ZoomZoom.tscn")
const Observers = preload("res://scenery/Observer.tscn")

const OBSERVER_SPAWN_RATE := 0.01


func _input(event):
	# TODO: Temporary quit-to-MainMenu
	if event.is_action_pressed("ui_cancel"):
		Game.current_state = Game.State.MainMenu

func _ready():
	Game.world = self
	Game.current_state = Game.State.LoadingLevel

func start():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	for __ in 3:
		spawn_observer()
	
	var player = PlayerTank.instance()
	player.translate(Vector3.UP * 0.2)
	add_child(player)
	var _e = player.connect("dead", self, "player_death")
	call_deferred("first_shot", player)
	player.current_state = player.PlayerState.Locked
	var __ = get_tree().create_timer(2).connect("timeout", player, "set_state", [player.PlayerState.Running])
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$WallSpawner.spawn_walls(250)
	$WallSpawner.rise()
	
	$RepairSpawner.spawn_repairs()
	
	for _i in 10:
		spawn_pickup(ZoomZoom)
	
	$FlagSpawner.spawn_flags()
	for flag in $FlagSpawner.pool:
		var min_tanks = tanks_by_level(0, 2)
		var max_tanks = min_tanks + tanks_by_level(0, 5) * 2
		var tanks = rng.randi_range(min_tanks, max_tanks)

		for _t in tanks_by_level(3, 5):
			tanks -= 1
			spawn_tank(AdvancedTank, flag.translation, 3.0, 5.0)
		for _t in tanks_by_level(5, 4):
			tanks -= 1
			spawn_tank(Turret, flag.translation, 0.5, 1.5)
		for _t in tanks_by_level(7, 3):
			tanks -= 1
			spawn_tank(MissileTurret, flag.translation, 1.5, 3.5)

		if tanks > 0:
			for _t in tanks:
				spawn_tank(AITank, flag.translation, 0.5, 4.5)
	
	for _i in 3 + tanks_by_level(0, 2) * 3:
		spawn_tank(AITank, player.translation, 50, 95)

func _physics_process(delta):
	# Chance to spawn a new Observer
	if randf() < OBSERVER_SPAWN_RATE * delta:
		spawn_observer()
	
	# Equal chance to evacuate one
	if randf() < OBSERVER_SPAWN_RATE * delta:
		evacuate_observer()

func spawn_observer():
	var obs = Observers.instance()
	add_child(obs)

func evacuate_observer():
	var observers = get_tree().get_nodes_in_group("observers")
	if observers.size() > 0:
		observers.shuffle()
		observers[0].current_state = observers[0].State.Evacuating

func tanks_by_level(first_at, more_every = 0):
	var tanks = 0
	
	if Game.level > first_at:
		tanks += 1
		
		if more_every > 0:
			tanks += floor((Game.level - first_at) / more_every)
	
	return tanks

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
	yield(get_tree().create_timer(5.5), "timeout")
	
	Game.reset_stats()
	var e = get_tree().reload_current_scene()
	assert(e == OK)

func tank_death(killer):
	print("Enemy tank died!")
	if is_instance_valid(killer) and killer.is_in_group("player"):
		print("\tWe blame the player!")
		Game.enemy_killed()
	elif is_instance_valid(killer) and killer.is_in_group("enemies"):
		print("\tFriendly fire casualty!")
