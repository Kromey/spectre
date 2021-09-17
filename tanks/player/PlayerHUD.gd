extends Control

onready var Armor = find_node("Armor")
onready var Ammo = find_node("Ammo")
onready var Score = find_node("Score")
onready var Kills = find_node("Kills")
onready var Level = find_node("Level")

var last_armor = 0

func update_armor(armor, _max_armor):
	Armor.get_node("Value").text = str(armor)
	
	if armor < last_armor:
		$DamageAnimation.play("Damage")
		var duration = $DamageAnimation.get_animation("Damage").length * 5
		if armor > 1:
			$DamageAnimation/DurationTimer.start(duration)
		else:
			$DamageCriticalAlarm.play()
			$DamageAnimation/DurationTimer.stop()
	elif armor > 1:
		# If we're repairing from 1 armor, we want to stop blinking
		reset_damage_animation()
	
	last_armor = armor

func reset_damage_animation():
	$DamageCriticalAlarm.stop()
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

func update_score(score):
	Score.get_node("Value").text = str(score)

func update_kills(kills):
	Kills.get_node("Value").text = str(kills)

func update_level(level):
	Level.get_node("Value").text = str(level)
