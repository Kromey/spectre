extends Node3D


func _ready():
	$Particles.restart()
	# Remove ourselves after we've run
	var _e = get_tree().create_timer(2).connect("timeout", Callable(self, "queue_free"))
