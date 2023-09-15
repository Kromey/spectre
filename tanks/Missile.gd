extends Node3D

@export var speed = 20
@export var steer_force = 1
@export var damage = 1
@export var flight_time = 5

var velocity = Vector3(1, 1, 0)
var acceleration = Vector3.ZERO

var hit_something = false

var target
var shooter

const BOOM = preload("res://tanks/BoomTheMissile.tscn")

func _ready():
	var __ = get_tree().create_timer(flight_time).connect("timeout", Callable(self, "queue_free"))

func start(_transform, _target, _shooter = null):
	global_transform = _transform
	velocity = transform.basis.z * -speed
	
	target = _target
	shooter = _shooter

func _physics_process(delta):
	look_at(global_transform.origin + velocity, Vector3.UP)
	
	if is_instance_valid(target):
		var desired = global_transform.origin.direction_to(target.global_transform.origin) * speed
		velocity = velocity.lerp(desired, steer_force * delta)
	
	global_translate(velocity * delta)


func _on_missile_collision(body):
	if !hit_something and body.has_method("take_damage"):
		body.take_damage(velocity, damage)
	
	var boom = BOOM.instantiate()
	boom.position = position
	get_parent().add_child(boom)
	
	hit_something = true
	queue_free()
	set_physics_process(false)
	$Debug/DebugDraw3D.hide()
