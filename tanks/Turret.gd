extends "res://tanks/AITank.gd"

func _ready():
	for i in NUM_RAYS:
		# Turrets don't need to worry about avoiding dangers
		danger[i] = 0.0

func set_danger():
	# Turrets don't need to worry about avoiding dangers
	pass
