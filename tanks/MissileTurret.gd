extends "res://tanks/AITank.gd"

var Missile = preload("res://tanks/Missile.tscn")

@onready var Launchers = [
	$MissileSpawn1,
	$MissileSpawn2,
	$MissileSpawn3,
	$MissileSpawn4,
]
var launcher = 0

func shoot():
	if ammo > 0 and !reloading and $FireRate.is_stopped():
		$FireRate.start(FIRE_RATE)
		ammo -= 1
		
		# Cycle through our launchers
		launcher = (launcher + 1) % Launchers.size()
		
		var missile = Missile.instantiate()
		get_tree().root.add_child(missile)
		missile.start(Callable(Launchers[launcher].global_transform, current_target).bind(self))
