extends Node2D

const CREDITS := [
	["Game Design & Programming", "Travis Veazey",],
	["3D Models & Textures", "Travis Veazey",],
]
const CREDITS_LINE_TIME := 0.3

onready var line_timer = $LineTimer
var is_rolling := false

func roll():
	is_rolling = !is_rolling
	get_tree().call_group("running_credits", "queue_free")
	
	var label = $CreditsLabel
	var title: bool
	
	for section in CREDITS:
		if !is_rolling:
			return
		
		title = true
		
		for line in section:
			if !is_rolling:
				return
			
			var l = label.duplicate()
			add_child(l)
			l.start(line, title)

			title = false
			
			line_timer.start()
			yield(line_timer, "timeout")
		
		line_timer.start()
		yield(line_timer, "timeout")
	
	is_rolling = false
