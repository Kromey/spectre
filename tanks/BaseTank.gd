extends KinematicBody

var falling = 0.0
const GRAVITY = 2
var damage = 0
export(int) var MAX_DAMAGE = 1
var velocity = Vector3.ZERO
export(float) var MAX_SPEED = 10
export(float) var ACCEL = 2

var angular_velocity = 0
export(float) var TURN_RATE = PI / 2.0
export(float) var TURN_ACCEL = 8

export(float) var MAX_AMMO = 3
var ammo

enum Direction {
	FORWARD = -1,
	BACK = 1,
	LEFT = 1,
	RIGHT = -1
}

const Bullet = preload("res://tanks/Bullet.tscn")

signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	reload()

func _physics_process(delta):
	falling += GRAVITY * delta
	
	var vel = move_and_slide(Vector3.DOWN * falling, Vector3.UP)
	falling = -vel.y
	
	if translation.y < -5:
		take_damage(Vector3.DOWN, MAX_DAMAGE * MAX_DAMAGE)

func drive(direction, delta):
	if is_on_floor():
		var hvel = velocity
		hvel.y = 0
		
		var dir = transform.basis.z * clamp(direction, -1.0, 1.0)
		
		var target = dir * MAX_SPEED
		
		var accel = ACCEL
		if dir.dot(hvel) <= 0:
			accel *= 2
		
		hvel = hvel.linear_interpolate(target, accel * delta)
		velocity.x = hvel.x
		velocity.z = hvel.z
	
	velocity = move_and_slide(velocity, Vector3.UP)

func turn(direction, delta):
	if is_on_floor():
		var turn_input = direction * TURN_RATE * delta
		
		var accel = TURN_ACCEL * delta
		if abs(turn_input) < abs(angular_velocity):
			# Stop turning twice as fast as we started
			accel *= 2
		
		angular_velocity = lerp(angular_velocity, turn_input, accel)
	
	rotate_y(angular_velocity)

func shoot(bullet_speed, gun_range, gun_damage = 1):
	if ammo > 0:
		ammo -= 1
		
		var bullet = Bullet.instance()
		bullet.BULLET_TIME = gun_range / bullet_speed
		bullet.BULLET_SPEED = bullet_speed
		bullet.BULLET_DAMAGE = gun_damage
		bullet.global_transform = $BulletSpawn.global_transform
		get_tree().root.add_child(bullet)
		
		$MuzzleFlare.restart()

func reload():
	ammo = MAX_AMMO

func take_damage(_force, amount):
	damage += amount
	
	if damage >= MAX_DAMAGE:
		die()

func die():
	emit_signal("dead")
	queue_free()
