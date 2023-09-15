extends RigidBody3D

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var material = PhysicsMaterial.new()
	material.bounce = (rng.randf() + rng.randf()) / 2.0
	set_physics_material_override(material)
	
	position = Vector3(rng.randf_range(-5.0, 5.0), rng.randf_range(5.0, 10.0), rng.randf_range(-5.0, 5.0))
	angular_velocity = Vector3(rng.randf(), rng.randf(), rng.randf()).normalized()

func _physics_process(_delta):
	if position.y < -5:
		queue_free()

func take_damage(velocity, amount):
	apply_central_impulse(velocity * amount)
