extends Spatial

const FLAG := preload("res://pickups/Flag.tscn")
const FLAG_COUNT := 5

var pool := []
var rng: RandomNumberGenerator
var collected := 0


func _ready():
	for __ in FLAG_COUNT:
		var flag = FLAG.instance()
		add_child(flag)
		flag.hide()
		flag.add_to_group("goals")
		var _e = flag.connect("body_entered", self, "_on_flag_pickup", [flag])
		pool.append(flag)
	
	rng = RandomNumberGenerator.new()
	rng.randomize()

func spawn_flags(min_dist = 50, from = Vector3.ZERO):
	collected = 0
	
	var dist_sq = pow(min_dist, 2)
	
	for flag in pool:
		var x = from.x
		var z = from.z
		flag.translation = Vector3(x, 0, z)
		
		while flag.translation.distance_squared_to(from) < dist_sq:
			x = rng.randf_range(-90, 90)
			z = rng.randf_range(-90, 90)
			flag.translation = Vector3(x, 0, z)
		
		flag.show()

func _on_flag_pickup(_body, flag: Spatial):
	$FlagPickup.play()
	flag.hide()
	
	Game.flag_collected()
	collected += 1
	if collected >= pool.size():
		Game.level_up()
