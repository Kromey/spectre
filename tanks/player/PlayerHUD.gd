extends Control

onready var Armor = find_node("Armor")
onready var Ammo = find_node("Ammo")
onready var Score = find_node("Score")
onready var Bonus = find_node("Bonus")
onready var Kills = find_node("Kills")
onready var Level = find_node("Level")

const MESSAGE = preload("res://tanks/player/HUDMessage.tscn")

var last_armor = 0
onready var damage_anim_duration = $DamageAnimation.get_animation("Damage").length * 5

enum {
	MSG_NORMAL,
	MSG_CRITICAL,
	MSG_SUCCESS,
}

func update_armor(armor, max_armor):
	Armor.get_node("Value").text = str(armor)
	
	var bar = Armor.get_node("Bar")
	bar.max_value = max_armor
	$BarTween.interpolate_property(bar, "value", bar.value, armor, damage_anim_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not $BarTween.is_active():
		$BarTween.start()
	
	if armor < last_armor:
		$DamageAnimation.play("Damage")
#		var duration = $DamageAnimation.get_animation("Damage").length * 5
		if armor > 1:
			$DamageAnimation/DurationTimer.start(damage_anim_duration)
		else:
			$DamageCriticalAlarm.play()
			$DamageAnimation/DurationTimer.stop()
			show_message("Danger! Damage Critical!", MSG_CRITICAL)
	elif armor > 1:
		# If we're repairing from 1 armor, we want to stop blinking
		reset_damage_animation()
	
	last_armor = armor

func reset_damage_animation():
	$DamageCriticalAlarm.stop()
	if $DamageAnimation.is_playing():
		$DamageAnimation.seek(0, true)
		$DamageAnimation.stop(true)

func update_ammo(new_value, max_ammo):
	Ammo.get_node("Value").text = str(new_value)
	
	var bar = Ammo.get_node("Bar")
	if max_ammo:
		bar.max_value = max_ammo
	$BarTween.interpolate_property(bar, "value", bar.value, new_value, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not $BarTween.is_active():
		$BarTween.start()

func reloading(is_reloading, reload_time):
	if is_reloading:
		$ReloadingAnimation.play("Reloading")
		update_ammo(0, null)
		show_message("Reloading...")
		
		var bar = Ammo.get_node("Bar")
		$BarTween.interpolate_property(bar, "value", 0, bar.max_value, reload_time + 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$BarTween.interpolate_method(self, "round_ammo", 0, bar.max_value, reload_time + 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		if not $BarTween.is_active():
			$BarTween.start()
	else:
		if $ReloadingAnimation.is_playing():
			$ReloadingAnimation.seek(0, true)
			$ReloadingAnimation.stop(true)
		if $BarTween.is_active():
			$BarTween.stop(Ammo.get_node("Bar"), "value")

func round_ammo(ammo):
	Ammo.get_node("Value").text = str(round(ammo))

func update_score(score):
	Score.get_node("Value").text = str(score)

func update_kills(kills):
	Kills.get_node("Value").text = str(kills)

func update_level(level):
	Level.get_node("Value").text = str(level)

func update_bonus(bonus):
	Bonus.get_node("Value").text = str(bonus)

func show_message(msg, level = MSG_NORMAL):
	var m = MESSAGE.instance()
	add_child(m)
	
	match level:
		MSG_NORMAL:
			m.show_message(msg)
		MSG_CRITICAL:
			m.show_critical(msg)
		MSG_SUCCESS:
			m.show_success(msg)
