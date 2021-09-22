extends Label

const CREDITS_LINE_TIME := 0.3
const CREDITS_TITLE_COLOR := Color.lightgreen
const CREDITS_TITLE_SPACING := 5
const CREDITS_SPEED := 125

var fading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	set_physics_process(false)

func _physics_process(delta):
	rect_global_position.y -= round(CREDITS_SPEED * delta)
	
	if rect_global_position.y <= 0:
		queue_free()
	elif rect_global_position.y < CREDITS_SPEED and !fading:
		fading = true
		fade_out()

func start(line: String, is_title := false):
	rect_global_position.x = 25
	rect_global_position.y = OS.window_size.y + CREDITS_TITLE_SPACING
	text = line
	show()
	add_to_group("running_credits")
	if is_title:
		add_color_override("font_color", CREDITS_TITLE_COLOR)
		rect_scale = Vector2(1.1, 1.1)
		rect_global_position.y -= CREDITS_TITLE_SPACING
	
	show()
	set_physics_process(true)

func fade_out():
	var tween = Tween.new()
	tween.interpolate_property(self, "modulate", modulate, Color(1, 1, 1, 0), 0.5)
	add_child(tween)
	tween.start()
