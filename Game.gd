extends Node

var player_score = 0
var player_kills = 0
var level_bonus = 0

var level = 0

onready var bonus_timer = Timer.new()

enum State {
	Waiting,
	LoadingGame,
	MainMenu,
	LoadingLevel,
	Running,
}
var current_state = State.Waiting setget set_state

var world

func set_state(new_state):
	current_state = new_state
	
	match current_state:
		State.MainMenu:
			if get_tree().get_current_scene().get_name() != "MainMenu":
				var __ = get_tree().change_scene("MainMenu.tscn")
		State.LoadingGame:
			reset_stats()
			if get_tree().get_current_scene().get_name() != "Main":
				var __ = get_tree().change_scene("Main.tscn")
		State.LoadingLevel:
			world.start()

func _ready():
	randomize()
	
	bonus_timer.one_shot = false
	bonus_timer.wait_time = 0.25
	add_child(bonus_timer)
	var __ = bonus_timer.connect("timeout", self, "decrement_bonus")
	
	reset_stats()

func reset_stats():
	set_score(0)
	set_bonus(400)
	set_kills(0)
	set_level(1)

func set_level(new_level):
	level = new_level
	get_tree().call_group("player", "update_level", level)
	
	bonus_timer.start()

func set_score(new_score):
	player_score = new_score
	get_tree().call_group("player", "update_score", player_score)

func set_bonus(new_bonus):
	level_bonus = max(new_bonus, 0)
	get_tree().call_group("player", "update_bonus", level_bonus)

func set_kills(new_kills):
	player_kills = new_kills
	get_tree().call_group("player", "update_kills", player_kills)

func level_up():
	bonus_timer.stop()
	add_to_score(level_bonus)
	
	set_level(level + 1)
	set_bonus(400)
	
	get_tree().call_group("enemies", "die", null)
	world.start()
	get_tree().paused = false

func decrement_bonus():
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
