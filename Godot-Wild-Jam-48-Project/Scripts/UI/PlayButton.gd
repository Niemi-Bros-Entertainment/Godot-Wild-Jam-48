'PlayButton'
extends Button


func _ready():
	grab_focus() # PlayButton starts focused for menu navigation


func _pressed():
	GameManager.engage()
