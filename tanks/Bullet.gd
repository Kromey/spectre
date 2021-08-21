extends Spatial

export var BULLET_SPEED = 12.0
export var BULLET_TIME = 4.0
export var BULLET_DAMAGE = 1.0

var hit_something = false
var velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(BULLET_TIME)
	var _e = timer.connect("timeout", self, "queue_free")
	
	_e = $Area.connect("body_entered", self, "collided")
	
	velocity = transform.basis.z * -BULLET_SPEED

func _physics_process(delta):
	global_translate(velocity * delta)

func collided(target):
	if !hit_something and target.has_method("take_damage"):
		target.take_damage(velocity, BULLET_DAMAGE)
	
	hit_something = true
	queue_free()
