extends Marker3D

var Missile = preload("res://tanks/Missile.tscn")

func fire_missile():
	var tanks = get_tree().get_nodes_in_group("tanks")
	
	if tanks.size() > 0:
		var target = tanks[0]
		var missile = Missile.instantiate()
		missile.start(Callable(global_transform, target))
		add_child(missile)
