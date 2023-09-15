extends Node3D

const Missile = preload("res://tanks/Missile.tscn")
@onready var Silos = [
	$MissileSilo5,
	$MissileSilo4,
	$MissileSilo6,
	$MissileSilo3,
	$MissileSilo7,
	$MissileSilo2,
	$MissileSilo8,
	$MissileSilo1,
	$MissileSilo9,
]

func take_damage(_force, _amount, shooter = null):
	if is_instance_valid(shooter):
		print("ObservationTower taking revenge upon ", shooter, "!")
		
		if !$FacilityAlarm.playing:
			$FacilityAlarm.play()
		
		for silo in Silos:
			await get_tree().create_timer(0.2).timeout
			
			var missile = Missile.instantiate()
			missile.steer_force = 4
			add_child(missile)
			missile.start(Callable(silo.global_transform, shooter).bind(self))
			
