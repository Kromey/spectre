extends Area

export(float) var DAMAGE = 2
var exploding = false

onready var tween = $Tween

const BOOM = preload("res://tanks/BoomTheMissile.tscn")

func _ready():
	scale = Vector3.ZERO
	
	var final_scale = rand_range(0.9, 1.1)
	tween.interpolate_property(self, "scale", scale, Vector3.ONE * final_scale, 0.2)
	tween.start()
	
	var lifetime = rand_range(5, 10)
	$Lifetime.start(lifetime)

func boom(body):
	if exploding:
		if body.has_method("take_damage"):
			body.take_damage(global_transform.origin.direction_to(body.global_transform.origin), DAMAGE)
			body.velocity += Vector3.UP
	else:
		exploding = true
		tween.stop_all()
		
		var final_scale = rand_range(2.8, 2.2)
		tween.interpolate_property(self, "scale", Vector3.ZERO, Vector3.ONE * final_scale, 0.1)
		tween.start()
		
		$Lifetime.stop()
		$Lifetime.start(0.101)
		
		var boom = BOOM.instance()
		boom.global_transform.origin = global_transform.origin
		get_parent().add_child(boom)

func _on_BoomBoom_body_entered(body):
	boom(body)


func _on_Mine_area_entered(area):
	if area.has_method("boom"):
		area.boom(self)
		pass


func _on_Lifetime_timeout():
	if exploding:
		queue_free()
	else:
		boom(self)
