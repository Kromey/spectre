extends Node

var player_score = 0
var player_bonus = 0
var player_kills = 0

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
		State.LoadingGame:
			get_tree().change_scene("Main.tscn")
		State.LoadingLevel:
			world.start()

func _ready():
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
	player_bonus = max(new_bonus, 0)
	get_tree().call_group("player", "update_bonus", player_bonus)

func set_kills(new_kills):
	player_kills = new_kills
	get_tree().call_group("player", "update_kills", player_kills)

func level_up():
	bonus_timer.stop()
	add_to_score(player_bonus)
	
	set_level(level + 1)
	set_bonus(400)

func decrement_bonus():
	set_bonus(player_bonus - 1)

func add_to_score(change):
	set_score(player_score + change)

func add_to_kills(change):
	set_kills(player_kills + change)
