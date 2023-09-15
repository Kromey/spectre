extends CharacterBody3D

var falling = 0.0
const GRAVITY = 2

@export var MAX_ARMOR: int = 1
@onready var armor = MAX_ARMOR

var velocity = Vector3.ZERO
@export var MAX_SPEED: float = 10
@export var ACCEL: float = 9 # Acceleration per second

var angular_velocity = 0
@export var TURN_RATE: float = PI / 2.0
@export var TURN_ACCEL: float = 8

@export var MAX_AMMO: float = 3
@export var FIRE_RATE: float = 1.5
@export var RELOAD_TIME: float = 3
@export var GUN_RANGE: float = 30
@export var BULLET_SPEED: float = 0
@export var GUN_DAMAGE: int = 1
var ammo = 0
var reloading = false

@export var TRAUMA_DECAY: float = 0.8
@export var max_offset: float = 0.3

var trauma = 0.0
var trauma_power = 2


enum Direction {
	FORWARD = -1,
	BACK = 1,
	LEFT = 1,
	RIGHT = -1
}

const Bullet = preload("res://tanks/Bullet.tscn")
const BOOM = preload("res://tanks/BoomTheTank.tscn")

@onready var ShootSound = find_child("ShootAudio")

signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	if BULLET_SPEED <= 0:
		BULLET_SPEED = MAX_SPEED + 2
	reload_immediate()

func _physics_process(delta):
	velocity += Vector3.DOWN * GRAVITY * delta
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity
	
	if position.y < -5:
		take_damage(Vector3.DOWN, INF)
	
	if trauma:
		trauma = max(trauma - TRAUMA_DECAY * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	position += global_transform.basis.x * max_offset * amount * randf_range(-1, 1)

func drive(direction, delta):
	if is_on_floor():
		var hvel = velocity
		hvel.y = 0
		
		var dir = transform.basis.z * clamp(direction, -1.0, 1.0)
		
		var target = dir * MAX_SPEED
		
		var accel = ACCEL
		if dir.dot(hvel) <= 0:
			accel *= 2
		
		hvel = hvel.move_toward(target, accel * delta)
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

func shoot():
	if ammo > 0 and !reloading and $FireRate.is_stopped():
		$FireRate.start(FIRE_RATE)
		ammo -= 1
		
		var bullet = Bullet.instantiate()
		bullet.BULLET_TIME = GUN_RANGE / BULLET_SPEED
		bullet.BULLET_SPEED = BULLET_SPEED
		bullet.BULLET_DAMAGE = GUN_DAMAGE
		bullet.shooter = self
		bullet.global_transform = $BulletSpawn.global_transform
		get_tree().root.add_child(bullet)
		
		$MuzzleFlare.restart()
		ShootSound.play()
		
		if ammo <= 0:
			reload()

func reload():
	if !reloading:
		reloading = true
		var _e = get_tree().create_timer(RELOAD_TIME).connect("timeout", Callable(self, "reload_immediate"))
		
		return true
	
	return false

func reload_immediate():
	ammo = MAX_AMMO
	reloading = false
	
	# Ensure reloading clears fire rate timer
	$FireRate.stop()

func take_damage(_force, amount, shooter = null):
	armor = clamp(armor - amount, 0, MAX_ARMOR)
	
	if armor <= 0:
		die(shooter)
	else:
		trauma = min(trauma + amount / 2.0, 1.0)
		$HitSound.play()

func repair_damage(amount):
	take_damage(0, -amount)

func die(killer = null):
	var boom = BOOM.instantiate()
	boom.position = position
	get_parent().add_child(boom)
	
	emit_signal("dead", killer)
	queue_free()
