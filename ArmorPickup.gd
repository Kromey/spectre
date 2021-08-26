extends Spatial

export(int) var pickup_value = 2

func _ready():
	rotate_y(randf() * 2 * PI)
	
	$Tween.interpolate_property(self, "rotation", rotation, rotation + Vector3.UP * 2 * PI, 4)
	$Tween.repeat = true
	$Tween.start()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.repair_damage(pickup_value)
		queue_free()
