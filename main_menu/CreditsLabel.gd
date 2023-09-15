extends Label

const CREDITS_TITLE_COLOR := Color.LIGHT_GREEN
const CREDITS_SPEED := 100

var fading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	set_process(false)

func _process(delta):
	global_position.y -= round(CREDITS_SPEED * delta)
	
	if global_position.y <= 0:
		queue_free()
	elif global_position.y < CREDITS_SPEED and !fading:
		fading = true
		fade_out()

func start(offset: int, line: String, is_title := false):
	global_position.x = 25
	global_position.y = get_window().size.y + offset
	text = line
	show()
	add_to_group("running_credits")
	if is_title:
		add_theme_color_override("font_color", CREDITS_TITLE_COLOR)
		scale = Vector2(1.1, 1.1)
	
	show()
	set_process(true)

func fade_out():
	var tween = Tween.new()
	tween.interpolate_property(self, "modulate", modulate, Color(1, 1, 1, 0), 0.5)
	add_child(tween)
	tween.start()
