'AbortButton - Return to title screen'
extends Button


func _ready():
	grab_focus() # starts focused for menu navigation


func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
	GameManager.abort()
