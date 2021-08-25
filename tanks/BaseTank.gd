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
export(float) var FIRE_RATE = 1.5
export(float) var RELOAD_TIME = 3
export(float) var GUN_RANGE = 30
var ammo = 0
var reloading = false


enum Direction {
	FORWARD = -1,
	BACK = 1,
	LEFT = 1,
	RIGHT = -1
}

const Bullet = preload("res://tanks/Bullet.tscn")

signal damage_changed
signal ammo_changed
signal reloading
signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	reload_immediate()

func _physics_process(delta):
	velocity += Vector3.DOWN * GRAVITY * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
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

func turn(direction, delta):
	if is_on_floor():
		var turn_input = direction * TURN_RATE * delta
		
		var accel = TURN_ACCEL * delta
		if abs(turn_input) < abs(angular_velocity):
			# Stop turning twice as fast as we started
			accel *= 2
		
		angular_velocity = lerp(angular_velocity, turn_input, accel)
	
	rotate_y(angular_velocity)

func shoot(gun_damage = 1):
	if ammo > 0 and !reloading and $FireRate.is_stopped():
		$FireRate.start(FIRE_RATE)
		ammo -= 1
		emit_signal("ammo_changed", ammo)
		
		var bullet_speed = MAX_SPEED * 1.2
		
		var bullet = Bullet.instance()
		bullet.BULLET_TIME = GUN_RANGE / bullet_speed
		bullet.BULLET_SPEED = bullet_speed
		bullet.BULLET_DAMAGE = gun_damage
		bullet.global_transform = $BulletSpawn.global_transform
		get_tree().root.add_child(bullet)
		
		$MuzzleFlare.restart()

func reload():
	if !reloading:
		emit_signal("reloading", true)
		reloading = true
		var _e = get_tree().create_timer(RELOAD_TIME).connect("timeout", self, "reload_immediate")

func reload_immediate():
	ammo = MAX_AMMO
	emit_signal("ammo_changed", ammo)
	reloading = false
	emit_signal("reloading", false)
	# Ensure reloading clears fire rate timer
	$FireRate.stop()

func take_damage(_force, amount):
	damage = clamp(damage + amount, 0, MAX_DAMAGE)
	emit_signal("damage_changed", damage, MAX_DAMAGE)
	
	if damage >= MAX_DAMAGE:
		die()

func repair_damage(amount):
	take_damage(0, -amount)

func die():
	emit_signal("dead")
	queue_free()
