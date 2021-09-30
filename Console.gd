extends CanvasLayer

onready var cmd_input: LineEdit = find_node("Input")
onready var cmd_output: TextEdit = find_node("Output")

onready var expression := Expression.new()
onready var commands := $ConsoleCommands

func _ready():
	cmd_input.grab_focus()
	cmd_input.clear()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_tree().set_deferred("paused", false)


func run_command(cmd):
	var error = expression.parse(cmd, [])
	if error != OK:
		return expression.get_error_text()
	
	var result = expression.execute([], commands, false)
	if expression.has_execute_failed():
		return expression.get_error_text()
	elif result:
		return result


func _on_Input_text_entered(new_text: String):
	cmd_input.clear()
	
	new_text = new_text.strip_edges()
	if new_text.empty():
		return
	
	var result = run_command(new_text)
	if result:
		if !cmd_output.text.empty():
			cmd_output.text += "\n"
		
		cmd_output.text += str(result)
		cmd_output.scroll_vertical = INF
