extends KinematicBody

var falling = 0.0
const GRAVITY = 2

signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	falling += GRAVITY * delta
	
	var vel = move_and_slide(Vector3.DOWN * falling, Vector3.UP)
	falling = -vel.y
	
	if translation.y < -5:
		emit_signal("dead")
		queue_free()
