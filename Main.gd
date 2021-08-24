extends Spatial

#const PillBomb = preload("res://PillBomb.tscn")
const PlayerTank = preload("res://tanks/PlayerTank.tscn")
const AITank = preload("res://tanks/AITank.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = PlayerTank.instance()
	player.translate(Vector3.UP * 3.0)
	player.add_to_group("player")
	add_child(player)
	var _e = player.connect("dead", self, "player_death")
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for _i in 20:
		var x = rng.randf_range(75, 90)
		var z = rng.randf_range(75, 90)
		
		if rng.randi_range(0, 1) == 1:
			x = -x
		if rng.randi_range(0, 1) == 1:
			z = -z
		
		var tank = AITank.instance()
		tank.translate(Vector3(x, 1, z))
		tank.add_to_group("enemies")
		add_child(tank)
		_e = tank.connect("dead", self, "tank_death")

func player_death():
	print("Player died!")

func tank_death():
	print("Enemy tank died!")
