extends Spatial

var PillBomb = load("res://PillBomb.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var _e = $PlayerTank.connect("dead", self, "player_death")

func respawn():
	self.add_child(PillBomb.instance())

func player_death():
	print("Player died!")
