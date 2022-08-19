'ControlPanel'
extends Node

onready var meshInstance :MeshInstance = $ControlPanel
onready var overlayMat :Material = meshInstance.material_overlay


func _ready():
	meshInstance.material_overlay = null
	# warning-ignore:return_value_discarded
	GameManager.connect("cheese_goal_reached", self, "_on_cheese_goal")


func operate():
	SfxManager.enqueue2d(Enums.SoundType.Ship2)
	if GameManager.get_cheese_score() < Constants.CHEESE_GOAL:
		GameManager.mission_over(Enums.AftermathType.InsufficientCheese)
	else:
		GameManager.mission_over(Enums.AftermathType.Success)


func _on_cheese_goal():
	SfxManager.enqueue2d(Enums.SoundType.CheeseGoal)
	meshInstance.material_overlay = overlayMat
