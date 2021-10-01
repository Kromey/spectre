extends Node


func echo(input: String):
	return input

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

func spawn_observer(num: int = 1):
	for __ in num:
		get_tree().current_scene.spawn_observer()
	
	return str(num, " Observers warping in!")

func observer(num: int = 1):
	return spawn_observer(num)

func evacuate_observer(num: int = 1):
	for __ in num:
		get_tree().current_scene.evacuate_observer()
	
	return str(num, " Observers warping away!")

func evac_observer(num: int = 1):
	return evacuate_observer(num)

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
