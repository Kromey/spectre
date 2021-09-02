extends MarginContainer

var player

const Icon = preload("res://tanks/player/radar/RadarIcon.tscn")
const EnemyIcon = preload("res://tanks/player/radar/EnemyIcon.tscn")

var zoom = 1.5

func _ready():
	set_physics_process(false)
	call_deferred("initialize")

func initialize():
	var p = get_tree().get_nodes_in_group("player")
	if p.size() > 0:
		player = p[0]
	else:
		print("Failed to initialize radar, retrying...")
		call_deferred("initialize")
		return
	
	var icon = Icon.instance()
	icon.me = get_tree().get_nodes_in_group("zoomzoom")[0]
	icon.center = Vector2(120, 120)
	add_child(icon)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_icon = EnemyIcon.instance()
		enemy_icon.me = enemy
		enemy_icon.center = Vector2(120, 120)
		add_child(enemy_icon)
	
	set_physics_process(true)

func _physics_process(_delta):
	get_tree().call_group("radar_icons", "update_pos", player.global_transform, zoom)
