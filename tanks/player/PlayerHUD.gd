extends Control

onready var Armor = find_node("Armor")
onready var Ammo = find_node("Ammo")

func update_damage(new_value, max_value):
	Armor.get_node("Value").text = str(max_value - new_value)

func update_ammo(new_value):
	Ammo.get_node("Value").text = str(new_value)

func reloading(is_reloading):
	if is_reloading:
		update_ammo(0)
