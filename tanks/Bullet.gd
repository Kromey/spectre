extends Node3D

@export var BULLET_SPEED = 12.0
@export var BULLET_TIME = 4.0
@export var BULLET_DAMAGE = 1.0

var hit_something = false
var velocity
var shooter

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(BULLET_TIME)
	var _e = timer.connect("timeout", Callable(self, "queue_free"))
	
	_e = $Area3D.connect("body_entered", Callable(self, "collided"))
	
	velocity = transform.basis.z * -BULLET_SPEED

func _physics_process(delta):
	global_translate(velocity * delta)

func collided(target):
	if target == shooter:
		# Ugly, shouldn't-be-necessary hack to prevent AITanks shooting themselves
		return
	
	if !hit_something and target.has_method("take_damage"):
		target.take_damage(velocity, BULLET_DAMAGE, shooter)
	
	hit_something = true
	queue_free()
