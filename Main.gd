extends Spatial

#const PillBomb = preload("res://PillBomb.tscn")
const PlayerTank = preload("res://tanks/player/PlayerTank.tscn")
const AITank = preload("res://tanks/AITank.tscn")
const AdvancedTank = preload("res://tanks/AdvancedTank.tscn")
const Turret = preload("res://tanks/Turret.tscn")
const MissileTurret = preload("res://tanks/MissileTurret.tscn")

var player

func _input(event):
	# TODO: Temporary quit-to-MainMenu
	if event.is_action_pressed("ui_cancel"):
		Game.current_state = Game.State.MainMenu

func _ready():
	player = PlayerTank.instance()
	player.translate(Vector3.UP * 0.2)
	add_child(player)
	var _e = player.connect("dead", self, "player_death")
	call_deferred("first_shot")
	player.lock_player_controls(2)
	
	Game.world = self
	Game.current_state = Game.State.LoadingLevel

func start():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$ObserverController.spawn_observer(3)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$WallController.rebuild_walls(250)
	
	$RepairController.spawn_repairs()
	$ZoomController.spawn_zooms()
	
	$FlagController.spawn_flags()
	for flag in $FlagController.pool:
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

# Pretty hacky, but calling this at game start ensures all our materials get
# compiled and eliminates "first-shot lag"
func first_shot():
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
