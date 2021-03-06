extends Label

onready var origin = rect_global_position
var speed

var fading_out = false

const OFFSET = 100

func _ready():
	set_process(false)

func show_message(msg, duration = 2.0):
	text = msg
	rect_global_position.y += OFFSET
	
	speed = 2 * OFFSET / duration
	
	$Fader.play("Fade")
	
	set_process(true)

func show_critical(msg, duration = 2.0):
	add_color_override("font_color", Color.red)
	
	show_message(msg, duration)

func show_success(msg, duration = 2.0):
	add_color_override("font_color", Color.green)
	
	show_message(msg, duration)

func done(__):
	queue_free()


func _process(delta):
	rect_global_position.y -= delta * speed
	
	if not fading_out:
		if abs(origin.y - rect_global_position.y) >= OFFSET:
			$Fader.play_backwards("Fade")
			var __ = $Fader.connect("animation_finished", self, "done")
			
			fading_out = true
