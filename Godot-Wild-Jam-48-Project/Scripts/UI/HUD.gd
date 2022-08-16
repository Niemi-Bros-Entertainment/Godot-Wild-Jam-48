'HUD'
extends CanvasLayer

onready var body = get_parent()


func _physics_process(_delta):
	var elevation :float = (Constants.ORIGIN - body.global_transform.origin).length()
	$Margin/ElevationProgressBarL.value = elevation
	$Margin/ElevationProgressBarR.value = elevation
