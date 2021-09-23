extends Node2D

const CREDITS := [
	["Game Design & Programming", "Travis Veazey",],
	["3D Models & Textures", "Travis Veazey",],
]
const LINE_HEIGHT = 38
const TITLE_SPACING = 8
const SECTION_SPACING = 65

func roll():
	get_tree().call_group("running_credits", "queue_free")
	
	var label := $CreditsLabel
	var title: bool
	var offset := 0
	
	for section in CREDITS:
		title = true
		
		for line in section:
			var l := label.duplicate()
			add_child(l)
			l.start(offset, line, title)

			offset += LINE_HEIGHT + (TITLE_SPACING if title else 0)
			title = false
		
		offset += SECTION_SPACING
