extends Node3D

@export var DAMAGE: float = 2
var exploding = false

@onready var tween = $Tween

const KABOOM = preload("res://tanks/BoomTheMissile.tscn")

func _ready():
	scale = Vector3.ZERO
	
	var final_scale = randf_range(0.9, 1.1)
	tween.interpolate_property(self, "scale", scale, Vector3.ONE * final_scale, 0.2)
	tween.start()
	
	var lifetime = randf_range(5, 10)
	$Lifetime.start(lifetime)

func boom():
	if !exploding:
		exploding = true
		$Lifetime.stop()
		tween.stop_all()
		
		var explosion = KABOOM.instantiate()
		get_parent().add_child(explosion)
		explosion.global_transform.origin = global_transform.origin
		
		for body in $BoomZone.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(global_transform.origin.direction_to(body.global_transform.origin), DAMAGE)
				body.velocity += Vector3.UP
		
		for area in $BoomZone.get_overlapping_areas():
			if area.has_method("detonate"):
				area.detonate()
		
		queue_free()


func _on_Detonator_body_entered(_body):
	boom()


func _on_Lifetime_timeout():
	boom()
