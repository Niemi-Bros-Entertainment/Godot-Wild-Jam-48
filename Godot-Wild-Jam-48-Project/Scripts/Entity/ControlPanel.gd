'ControlPanel'
extends Node

func operate():
	SfxManager.enqueue2d(Enums.SoundType.Ship2)
	if GameManager.get_score() < 500:
		GameManager.mission_over(Enums.AftermathType.InsufficientCheese)
	else:
		GameManager.mission_over(Enums.AftermathType.Success)
