extends Spatial

export(int) var pickup_value = 2

func _ready():
	$SpinnyAnim.play("Spinny")
	#$PulsyAnim.play("Pulsy")

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.repair_damage(pickup_value)
		queue_free()
