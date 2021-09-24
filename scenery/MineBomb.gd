extends KinematicBody

var velocity = Vector3.ZERO
var gravity = Vector3.DOWN * 8
var bounces = 0

func _physics_process(delta):
	velocity += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		bounces += 1
		velocity = velocity.bounce(collision.normal)
		velocity -= velocity.project(collision.normal * velocity.length_squared()) * 0.25
		
		if bounces > 3 and global_transform.origin.y < 0.11:
			$Disappear.play("Shrink")
			velocity = Vector3.ZERO
			set_physics_process(false)
			
			yield($Disappear, "animation_finished")
			queue_free()
