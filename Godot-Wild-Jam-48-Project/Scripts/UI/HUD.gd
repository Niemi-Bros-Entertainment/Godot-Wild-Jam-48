'HUD'
extends CanvasLayer

onready var body = get_parent()
onready var tween :Tween = $Tween
var alarmTimer :float = 1.0

func _ready():
	update_cheese_01(0)
	update_jetpack_01(0)


func _physics_process(_delta):
	var elevation :float = (Constants.ORIGIN - body.global_transform.origin).length()
	$Margin/ElevationProgressBarL.value = elevation
	$Margin/ElevationProgressBarR.value = elevation
	
	if $Margin/ElevationProgressBarL.value >= 75:
		if alarmTimer <= 0:
			tween.interpolate_property($Margin/ElevationProgressBarL, "modulate", Color.red, Color.white, 1.0)
			tween.interpolate_property($Margin/ElevationProgressBarR, "modulate", Color.red, Color.white, 1.0)
			tween.start()
			alarmTimer = 1.0
			SfxManager.enqueue2d(Enums.SoundType.Alarm)
		else:
			alarmTimer -= _delta


func update_cheese_01(amount01 :float):
	$Margin/CheeseProgress.value = $Margin/CheeseProgress.max_value * amount01
	
	
func update_jetpack_01(amount01 :float):
	$Margin/JetpackProgress.value = $Margin/JetpackProgress.max_value * amount01
