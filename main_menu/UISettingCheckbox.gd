@tool
extends Control

# Emitted when the `CheckBox` state changes
signal toggled(is_button_pressed)

# The text of the Leval should be changed to identify the setting.
# Using a setter lets us change the text when the `title` variable changes.
@export var title := "": set = set_title

@export var enabled := false: set = set_enabled

# We store a reference to the Label node to update its text
@onready var label := $Label

func _on_CheckBox_toggled(button_pressed):
	emit_signal("toggled", button_pressed)

# Setter for the `title` variable
func set_title(value: String) -> void:
	title = value
	# Wait until the scene is ready if `label` is null
	if not label:
		await self.ready
	# Update the label's text
	label.text = title

func set_enabled(_enabled):
	enabled = _enabled
	$CheckBox.button_pressed = enabled
