'QuitButton'
extends Button

func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuCancel)
	GameManager.quit_game()
