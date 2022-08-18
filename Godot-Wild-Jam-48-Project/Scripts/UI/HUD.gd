'HUD'
extends CanvasLayer

onready var body = get_parent() # parent should be the player
onready var tween :Tween = $Tween
onready var timeLabel :Label = $Margin/TimeLabel
onready var cheeseProgress :TextureProgress = $Margin/CheeseProgress
onready var cheeseLabel :Label = $Margin/CheeseLabel
onready var scoreLabel :Label = $Margin/ScoreLabel
onready var jetpackProgress :TextureProgress = $Margin/JetpackProgress

var alarmTimer :float = 1.0
var orbitTimer :float = ORBIT_DANGER_TIME

const ORBIT_DANGER_TIME :float = 6.0
const CHEESE_STRING_FORMAT :String = "\n%s"
const MOON_ORBIT :float = Constants.MOON_RADIUS * 2.0


func _ready():
	# warning-ignore:return_value_discarded
	GameManager.connect("game_over", self, "_on_game_over")
	# warning-ignore:return_value_discarded
	get_tree().current_scene.find_node("CheesePlacer").connect("instance_cheese", self, "_update_cheese_label")
	
	cheeseProgress.max_value = Constants.CHEESE_CARRY_CAPACITY
	update_cheese(0)
	update_jetpack_01(0)


func _physics_process(_delta):
	var elevation :float = (Constants.ORIGIN - body.global_transform.origin).length()
	$Margin/ElevationProgressBarL.value = elevation
	$Margin/ElevationProgressBarR.value = elevation
	
	if elevation >= MOON_ORBIT * 0.8:	
		var isInOrbit :bool = elevation < MOON_ORBIT
		$OrbitLabel.visible = not isInOrbit
		if not isInOrbit:
			$OrbitLabel.visible_characters += 1
			orbitTimer -= _delta
			if orbitTimer <= 0:
				$OrbitLabel.hide()
				GameManager.mission_fail()
				set_physics_process(false)
				return
		else:
			$OrbitLabel.visible_characters = 0
			orbitTimer = ORBIT_DANGER_TIME
			
		if alarmTimer <= 0:
			_flash_elevation_meters()
			alarmTimer = 1.0
			SfxManager.enqueue2d(Enums.SoundType.Alarm)
			if not isInOrbit:
				SfxManager.enqueue2d(Enums.SoundType.ShipAlarm)
		else:
			alarmTimer -= _delta
	else:
		$OrbitLabel.visible_characters = 0
		orbitTimer = ORBIT_DANGER_TIME


func _flash_elevation_meters():
	# warning-ignore:return_value_discarded
	tween.interpolate_property($Margin/ElevationProgressBarL, "modulate", Color.red, Color.white, 1.0)
	# warning-ignore:return_value_discarded
	tween.interpolate_property($Margin/ElevationProgressBarR, "modulate", Color.red, Color.white, 1.0)
	# warning-ignore:return_value_discarded
	tween.start()


func update_cheese(amount :float):
	cheeseProgress.value = amount
	cheeseProgress.get_node("Label-2").text = "%s / %s" % [cheeseProgress.value, cheeseProgress.max_value]
	_update_cheese_label()
	
	
func _update_cheese_label():
# warning-ignore:return_value_discarded
	tween.interpolate_property(scoreLabel, "self_modulate", Color(2,2,2), Color.white, 1.0)
# warning-ignore:return_value_discarded
	tween.interpolate_property(cheeseLabel, "self_modulate", Color(2,2,2), Color.white, 1.0)
# warning-ignore:return_value_discarded
	tween.interpolate_property(cheeseProgress, "self_modulate", Color(2,2,2), Color.white, 1.0)
# warning-ignore:return_value_discarded
	tween.start()
	cheeseLabel.text = CHEESE_STRING_FORMAT % [get_tree().get_nodes_in_group("Pickup").size()]
	
	
func update_jetpack_01(amount01 :float):
#	if jetpackProgress.value > jetpackProgress.max_value * amount01:
#		# warning-ignore:return_value_discarded
#		tween.interpolate_property(jetpackProgress, "modulate", Color.dimgray, Color.white, 0.5)
#		# warning-ignore:return_value_discarded
#		tween.start()
	jetpackProgress.value = jetpackProgress.max_value * amount01
	jetpackProgress.get_node("Label-2").text = str(int(jetpackProgress.value)) + "% \n" + str(stepify(body.get_vertical_speed(), 0.01)) + "m/s"


func _on_game_over():
	hide()
	
