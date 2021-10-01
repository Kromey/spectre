extends Node

enum {
	ARG_MULTI_STRING,
	ARG_STRING,
	ARG_INT,
	ARG_FLOAT,
	ARG_BOOL,
}

var commands = {
	"echo": [ARG_MULTI_STRING],
	"level_up": [],
	"walls_down": [],
	"walls_up": [],
	"new_walls": [],
	"spawn_observer": [ARG_INT],
	"evacuate_observer": [ARG_INT],
	"kill_all": [],
	"god_mode": [],
}

var command_aliases = {
	"observer": "spawn_observer",
	"evac_observer": "evacuate_observer",
	"god": "god_mode",
	"make_me_god": "god_mode",
}


func _ready():
	for cmd in commands.keys():
		var alias = cmd.replace("_", "")
		if cmd != alias:
			command_aliases[alias] = cmd


func echo(input: String):
	return str(input)

func level_up():
	Game.level_up()
	return "Leveled up!"

func walls_down():
	get_tree().current_scene.find_node("WallSpawner").descend()
	
	return "Walls lowering"

func walls_up():
	get_tree().current_scene.find_node("WallSpawner").rise()
	
	return "Walls rising"

func new_walls():
	get_tree().current_scene.find_node("WallSpawner").rebuild_walls()
	
	return "Rebuilding level's walls"

func spawn_observer(num: int):
	for __ in num:
		get_tree().current_scene.spawn_observer()
	
	return str(num, " Observers warping in!")

func evacuate_observer(num: int):
	for __ in num:
		get_tree().current_scene.evacuate_observer()
	
	return str(num, " Observers warping away!")

func kill_all():
	get_tree().call_group("enemies", "die", get_tree().get_nodes_in_group("player")[0])
	
	return "All enemies dead!"

func god_mode():
	var player = get_tree().get_nodes_in_group("player")[0]
	var god = player.toggle_god_mode()
	
	if god:
		return "God Mode!"
	else:
		return "Normal Mode"