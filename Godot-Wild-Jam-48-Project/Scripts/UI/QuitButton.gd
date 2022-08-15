'QuitButton'
extends Button

func _pressed():
	get_tree().quit()
	SfxManager.enqueue2d(Enums.SoundType.MenuCancel)
