extends Spatial

export(int) var pickup_value = 2

func _ready():
	rotate_y(randf() * PI)
	
	$Tween.interpolate_property(self, "rotation", rotation, rotation + Vector3.UP * 2 * PI, 4)
	$Tween.repeat = true
	$Tween.start()

func _on_Area_body_entered(body):
	$ArmorPickup.play()
	body.repair_damage(pickup_value)
	
	$Area.monitoring = false
	
	$Tween.interpolate_property(self, "translation", translation, translation + Vector3.DOWN, 1.0)
	$Tween.repeat = false
	$Tween.start()
	
	yield(get_tree().create_timer(1.0), "timeout")
	queue_free()
