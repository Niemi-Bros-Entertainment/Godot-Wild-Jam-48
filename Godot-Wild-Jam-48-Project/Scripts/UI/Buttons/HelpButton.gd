'HelpButton'
extends Button


func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
	SceneManager.go_to(Constants.HELP_SCENE_PATH)
