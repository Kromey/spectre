extends Node

const MAX_BONUS = 400

var player_score = 0
var player_kills = 0
var level_bonus = 0

var level = 1

@onready var bonus_timer = Timer.new()

enum State {
	Waiting,
	LoadingGame,
	MainMenu,
	LoadingLevel,
	Running,
	Paused,
	GameOver,
}
var current_state = State.Waiting: set = set_state

var world

func set_state(new_state):
	current_state = new_state
	
	match current_state:
		State.MainMenu:
			if get_tree().get_current_scene().get_name() != "MainMenu":
				var __ = get_tree().change_scene_to_file("MainMenu.tscn")
		State.LoadingGame:
			if get_tree().get_current_scene().get_name() != "Main":
				var __ = get_tree().change_scene_to_file("Main.tscn")
		State.LoadingLevel:
			world.start()
			reset_stats()
			set_state(State.Running)
			world.player.show_message("Level 1!")

func _ready():
	randomize()
	
	bonus_timer.one_shot = false
	bonus_timer.wait_time = 0.25
	add_child(bonus_timer)
	var __ = bonus_timer.connect("timeout", Callable(self, "decrement_bonus"))

func reset_stats():
	set_score(0)
	reset_bonus()
	set_kills(0)
	set_level(1)

func reset_bonus(add = false):
	if add:
		add_to_score(level_bonus)
	
	set_bonus(MAX_BONUS)

func set_level(new_level):
	level = new_level
	world.player.update_level(level)
	
	bonus_timer.start()

func set_score(new_score):
	player_score = new_score
	world.player.update_score(player_score)

func set_bonus(new_bonus):
	level_bonus = max(new_bonus, 0)
	world.player.update_bonus(level_bonus)

func set_kills(new_kills):
	player_kills = new_kills
	world.player.update_kills(player_kills)

func level_up():
	bonus_timer.stop()
	
	reset_bonus(true)
	set_level(level + 1)
	
	get_tree().call_group("enemies", "die")
	world.start()
	world.player.show_message("Level %s!" % level)

func decrement_bonus():
	if current_state == State.Running and is_instance_valid(world.player):
		if world.player.is_running():
			set_bonus(level_bonus - 1)

func flag_collected():
	add_to_score(20)

func enemy_killed():
	add_to_kills(1)
	add_to_score(10)

func add_to_score(change):
	set_score(player_score + change)

func add_to_kills(change):
	set_kills(player_kills + change)
