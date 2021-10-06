extends Node

const OBSERVER = preload("res://scenery/Observer.tscn")

export(float, 0.0, 1.0) var OBSERVER_SPAWN_RATE := 0.05

var pool := [] # Instanced Observers waiting to be used
var active := [] # Active Observers

func new_observer():
	print("\tInstancing new observer")
	var observer = OBSERVER.instance()
	add_child(observer)
	
	return observer

func spawn_observer(count = 1):
	for __ in count:
		var observer = pool.pop_back() if pool.size() else new_observer()
		active.append(observer)
		observer.start()

func remove_observer(count = 1):
	active.shuffle()
	
	for __ in count:
		if active.empty():
			return
		
		var observer = active.back()
		observer.current_state = observer.State.Evacuating


func check_spawn():
	if randf() < OBSERVER_SPAWN_RATE:
		prints(get_tree().get_frame(), "Warping new observer")
		spawn_observer()
		prints("\t", active.size(), pool.size())
	
	if randf() < OBSERVER_SPAWN_RATE:
		prints(get_tree().get_frame(), "Removing observer")
		remove_observer()
		prints("\t", active.size(), pool.size())
	
	# Use idle time to clean up
	call_deferred("maintain_pools")

func maintain_pools():
	for i in active.size():
		var observer = active[i]
		if observer.current_state == observer.State.Idle:
			pool.append(observer)
			active.remove(i)
			
			prints("\t", active.size(), pool.size())
			break
	
	if pool.size() == 0:
		pool.append(new_observer())
	elif pool.size() > 5:
		pool.pop_back().queue_free()
