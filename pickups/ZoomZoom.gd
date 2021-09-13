extends Area

export(float) var MULTIPLIER = 3

func _on_ZoomZoom_body_entered(body):
	body.velocity *= MULTIPLIER
	$SFX.play()
