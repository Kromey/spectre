extends Node

enum {
	ARG_MULTI_STRING,
	ARG_STRING,
	ARG_INT,
	ARG_FLOAT,
	ARG_BOOL,
}

var commands = {
	"help": [],
	"aliases": [],
	"echo": [ARG_MULTI_STRING],
	"message": [ARG_MULTI_STRING],
	"reload": [],
	"level_up": [],
	"walls_down": [],
	"walls_up": [],
	"new_walls": [],
	"spawn_observer": [ARG_INT],
	"evacuate_observer": [ARG_INT],
	"kill_all": [],
	"kill_me": [],
	"god_mode": [],
}

var command_aliases = {
	"msg": "message",
	"observer": "spawn_observer",
	"evac_observer": "evacuate_observer",
	"remove_observer": "evacuate_observer",
	"god": "god_mode",
	"make_me_god": "god_mode",
	"suicide": "kill_me",
	"?": "help",
}

var hidden_aliases = []


func _ready():
	for alias in command_aliases.keys():
		var a = alias.replace("_", "")
		if a != alias:
			command_aliases[a] = command_aliases[alias]
			hidden_aliases.append(a)
	
	for cmd in commands.keys():
		var alias = cmd.replace("_", "")
		if cmd != alias:
			command_aliases[alias] = cmd
			hidden_aliases.append(alias)


func help():
	var cmds = commands.keys()
	cmds.sort()
	
	return ", ".join(PackedStringArray(cmds))

func aliases():
	var a = command_aliases.keys()
	a.sort()
	
	var cmds = PackedStringArray()
	for alias in a:
		if not alias in hidden_aliases:
			cmds.append("%s: %s" % [alias, command_aliases[alias]])
	
	return ", ".join(cmds)

func echo(input: String):
	return str(input)

func message(msg: String):
	Game.world.player.show_message(msg)

func reload():
	Game.world.player.reload_immediate()

func level_up():
	Game.level_up()
	return "Leveled up!"

func walls_down():
	get_tree().current_scene.find_child("WallController").descend()
	
	return "Walls lowering"

func walls_up():
	get_tree().current_scene.find_child("WallController").rise()
	
	return "Walls rising"

func new_walls():
	get_tree().current_scene.find_child("WallController").rebuild_walls()
	
	return "Rebuilding level's walls"

func spawn_observer(num: int):
	for __ in num:
		get_tree().current_scene.find_child("ObserverController").spawn_observer()
	
	return str(num, " Observers warping in!")

func evacuate_observer(num: int):
	for __ in num:
		get_tree().current_scene.find_child("ObserverController").remove_observer()
	
	return str(num, " Observers warping away!")

func kill_all():
	get_tree().call_group("enemies", "die", get_tree().get_nodes_in_group("player")[0])
	
	return "All enemies dead!"

func kill_me():
	Game.world.player.die(null)
	$"..".close_console()

func god_mode():
	var player = get_tree().get_nodes_in_group("player")[0]
	var god = player.toggle_god_mode()
	
	if god:
		return "God Mode!"
	else:
		return "Normal Mode"
