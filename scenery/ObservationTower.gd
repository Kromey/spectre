extends Spatial

const Missile = preload("res://tanks/Missile.tscn")
onready var Silos = [
	$MissileSilo1,
	$MissileSilo2,
	$MissileSilo3,
	$MissileSilo4,
	$MissileSilo5,
	$MissileSilo6,
	$MissileSilo7,
	$MissileSilo8,
	$MissileSilo9,
]

func take_damage(_force, _amount, shooter = null):
	if is_instance_valid(shooter):
		print("ObservationTower taking revenge upon ", shooter, "!")
		for silo in Silos:
			var missile = Missile.instance()
			missile.steer_force = 2
			add_child(missile)
			missile.start(silo.global_transform, shooter, self)
			
			yield(get_tree().create_timer(0.2), "timeout")
