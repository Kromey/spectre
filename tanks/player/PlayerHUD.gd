extends Control

onready var Armor = find_node("Armor")
onready var Ammo = find_node("Ammo")

var last_damage = 0

func update_damage(new_value, max_value):
	Armor.get_node("Value").text = str(max_value - new_value)
	
	if new_value > last_damage:
		$DamageAnimation.play("Damage")
		var duration = $DamageAnimation.get_animation("Damage").length * 5
		if max_value - new_value > 1:
			$DamageAnimation/DurationTimer.start(duration)
		else:
			$DamageAnimation/DurationTimer.stop()
	elif max_value - new_value > 1:
		# If we're repairing from 1 armor, we want to stop blinking
		reset_damage_animation()
	
	last_damage = new_value

func reset_damage_animation():
	if $DamageAnimation.is_playing():
		$DamageAnimation.seek(0, true)
		$DamageAnimation.stop(true)

func update_ammo(new_value):
	Ammo.get_node("Value").text = str(new_value)

func reloading(is_reloading):
	if is_reloading:
		$ReloadingAnimation.play("Reloading")
		update_ammo(0)
	else:
		if $ReloadingAnimation.is_playing():
			$ReloadingAnimation.seek(0, true)
			$ReloadingAnimation.stop(true)
