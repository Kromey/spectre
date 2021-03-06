extends KinematicBody

var velocity = Vector3.ZERO
var gravity = Vector3.DOWN * 8
var bounces = 0

const BOOM = preload("res://pickups/Mine.tscn")

func _physics_process(delta):
	if global_transform.origin.y < -5:
		queue_free()
	
	velocity += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		bounces += 1
		velocity = velocity.bounce(collision.normal)
		velocity -= velocity.project(collision.normal * velocity.length_squared()) * 0.25
		
		if collision.collider.has_method("take_damage") or (bounces > 3 and global_transform.origin.y < 0.11):
			$Disappear.play("Shrink")
			velocity = Vector3.ZERO
			$CollisionShape.disabled = true
			
			var boom = BOOM.instance()
			get_parent().add_child(boom)
			boom.global_transform.origin = global_transform.origin
			boom.global_transform.origin.y = 0
			
			yield($Disappear, "animation_finished")
			queue_free()
