extends Node
class_name VideoSettings

const SETTINGS_FILE = "user://settings.dat"

var resolution := Vector2(1280, 720): set = set_resolution
var fullscreen := false: set = set_fullscreen
var vsync := true: set = set_vsync

func _init():
	pass

func set_resolution(new_resolution):
	resolution = new_resolution

func set_fullscreen(new_fullscreen):
	fullscreen = new_fullscreen

func set_vsync(new_vsync):
	vsync = new_vsync

func apply_settings(screen):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if (fullscreen) else DisplayServer.WINDOW_MODE_WINDOWED)
	#screen.set_screen_stretch(
	#	SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, resolution
	#)
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (vsync) else DisplayServer.VSYNC_DISABLED)
	
	#OS.center_window()

func from_json(settings: String):
	var parsed = JSON.parse_string(settings)
	from_dict(parsed)

func from_dict(settings: Dictionary):
	set_resolution(settings.resolution)
	set_fullscreen(settings.fullscreen)
	set_vsync(settings.vsync)

func to_json():
	return JSON.stringify(to_dict())

func to_dict():
	return {
		resolution = resolution,
		fullscreen = fullscreen,
		vsync = vsync,
	}

func save():
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_var(to_dict())
	file.close()

func load_from_file():
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		from_dict(data)
