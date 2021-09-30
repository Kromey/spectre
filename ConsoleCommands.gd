extends Node


func echo(input: String):
	return input

func level_up():
	Game.level_up()

func spawn_observer(num: int = 1):
	for __ in num:
		get_tree().current_scene.spawn_observer()

func observer(num: int = 1):
	spawn_observer(num)

func evacuate_observer(num: int = 1):
	for __ in num:
		get_tree().current_scene.evacuate_observer()

func evac_observer(num: int = 1):
	evacuate_observer(num)

func kill_all():
	get_tree().call_group("enemies", "die", get_tree().get_nodes_in_group("player")[0])
	
	return "All enemies dead!"

func killall():
	return kill_all()

func god_mode():
	var player = get_tree().get_nodes_in_group("player")[0]
	var god = player.toggle_god_mode()
	
	if god:
		return "God Mode!"
	else:
		return "Normal Mode"
