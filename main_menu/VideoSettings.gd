extends Object
class_name VideoSettings

const SETTINGS_FILE = "user://settings.dat"

var resolution := Vector2(1280, 720) setget set_resolution
var fullscreen := false setget set_fullscreen
var vsync := true setget set_vsync

func _init():
	pass

func set_resolution(new_resolution):
	resolution = new_resolution

func set_fullscreen(new_fullscreen):
	fullscreen = new_fullscreen

func set_vsync(new_vsync):
	vsync = new_vsync

func apply_settings(screen):
	OS.window_fullscreen = fullscreen
	screen.set_screen_stretch(
		SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, resolution
	)
	OS.set_window_size(resolution)
	OS.vsync_enabled = vsync
	
	OS.center_window()

func from_dict(settings: Dictionary):
	set_resolution(settings.resolution)
	set_fullscreen(settings.fullscreen)
	set_vsync(settings.vsync)

func to_dict():
	return {
		resolution = resolution,
		fullscreen = fullscreen,
		vsync = vsync,
	}

func save():
	var file = File.new()
	file.open(SETTINGS_FILE, File.WRITE)
	file.store_var(to_dict(), true)
	file.close()

func load_from_file():
	var file = File.new()
	if file.file_exists(SETTINGS_FILE):
		file.open(SETTINGS_FILE, File.READ)
		var data = file.get_var(true)
		file.close()
		
		from_dict(data)
