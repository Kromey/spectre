extends Spatial

export var speed = 20
export var steer_force = 1
export var damage = 1
export var flight_time = 5

var velocity = Vector3(1, 1, 0)
var acceleration = Vector3.ZERO

var hit_something = false

var target
var shooter

func _ready():
	var __ = get_tree().create_timer(flight_time).connect("timeout", self, "queue_free")

func start(_transform, _target, _shooter):
	global_transform = _transform
	velocity = transform.basis.z * -speed
	
	target = _target
	shooter = _shooter

func _physics_process(delta):
	look_at(translation + velocity, Vector3.UP)
	
	if is_instance_valid(target):
		var desired = global_transform.origin.direction_to(target.global_transform.origin) * speed
		velocity = velocity.linear_interpolate(desired, steer_force * delta)
	
	translation += velocity * delta


func _on_missile_collision(body):
	if !hit_something and body.has_method("take_damage"):
		body.take_damage(velocity, damage)
	
	hit_something = true
	queue_free()
	set_physics_process(false)
	$Debug/DebugDraw3D.hide()
