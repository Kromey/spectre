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


# Non-greedy version, will find the shortest valid command
#func read_command(cmd: String, args: Array):
#	cmd = cmd.replace("-", "_")
#
#	if commands.command_aliases.has(cmd):
#		return commands.command_aliases[cmd]
#	if commands.command_aliases.has(cmd.replace("_", "")):
#		return commands.command_aliases[cmd.replace("_", "")]
#
#	if commands.commands.has(cmd):
#		return cmd
#
#	if args.size() > 0:
#		cmd = str(cmd, "_", args.pop_front())
#		return read_command(cmd, args)


# Greedily attempt to consume argument tokens until the longest valid command
# is found
func read_command(args: Array):
	var cmd_tokens = args.duplicate()
	args.clear()
	
	while cmd_tokens.size() > 0:
		var cmd = PoolStringArray(cmd_tokens).join("_")
		cmd = cmd.replace("-", "_")
	
		if commands.command_aliases.has(cmd):
			return commands.command_aliases[cmd]
		if commands.command_aliases.has(cmd.replace("_", "")):
			return commands.command_aliases[cmd.replace("_", "")]
		
		if commands.commands.has(cmd):
			return cmd
		
		args.push_front(cmd_tokens.pop_back())
	
	return ""


# Validate argument types and cast their values
func read_args(cmd: String, args: Array):
	var arg_types = commands.commands[cmd]
	
	if arg_types.size() != args.size():
		return "Expected %d arguments, got %d arguments" % [arg_types.size(), args.size()]
	
	for i in args.size():
		match arg_types[i]:
			commands.ARG_STRING:
				# no-op, already a string
				pass
			
			commands.ARG_INT:
				if not args[i].is_valid_integer():
					return "Parameter %d (%s) is not an integer" % [i+1, args[i]]
				args[i] = args[i].to_int()
			
			commands.ARG_FLOAT:
				if not args[i].is_valid_float():
					return "Parameter %d (%s) is not a float" % [i+1, args[i]]
				args[i] = args[i].to_float()
			
			commands.ARG_BOOL:
				match args[i].to_lower():
					"true": args[i] = true
					"false": args[i] = false
					_: return "Parameter %d (%s) is not a boolean" % [i+1, args[i]]
	
	return ""


func execute(input: String):
	input = input.strip_edges()
	if input.empty():
		return
	
	var args = Array(input.split(" ", false))
	
	var cmd = read_command(args)
	
	if !commands.commands.has(cmd):
		return "ERROR: Unknown command: %s" % input
	
	var arg_result = read_args(cmd, args)
	if arg_result:
		return "ERROR: %s" % arg_result
	
	return commands.callv(cmd, args)


func _on_Input_text_entered(new_text: String):
	cmd_input.clear()
	
	var result = execute(new_text)
	if result:
		var txt = "%s\n%s" % [cmd_output.text, result]
		cmd_output.text = txt.strip_edges()
		
		cmd_output.scroll_vertical = INF
