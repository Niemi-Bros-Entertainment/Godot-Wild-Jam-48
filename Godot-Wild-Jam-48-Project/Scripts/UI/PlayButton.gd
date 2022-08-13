'PlayButton'
extends Button


func _ready():
	grab_focus() # PlayButton starts focused for menu navigation


func _pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(Constants.GAME_SCENE_PATH)
