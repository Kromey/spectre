extends Spatial

export(int) var pickup_value = 2

func _ready():
	rotate_y(randf() * PI)
	
	$Tween.interpolate_property(self, "rotation", rotation, rotation + Vector3.UP * 2 * PI, 4)
	$Tween.repeat = true
	$Tween.start()

func _on_Area_body_entered(body):
	body.repair_damage(pickup_value)
	queue_free()
