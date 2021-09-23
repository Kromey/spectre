extends KinematicBody

var velocity = Vector3.ZERO
var gravity = Vector3.DOWN * 8
var bounces = 0

func _ready():
	var a = Vector2(1, 1)
	var b = Vector2(0, 8)
	
	prints(a, b, a.project(b), b.project(a))

func _physics_process(delta):
	velocity += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		bounces += 1
		velocity = velocity.bounce(collision.normal)
		velocity -= velocity.project(collision.normal * velocity.length_squared()) * 0.25
		
		if bounces > 3:
			queue_free()
