class_name HUDAftermath extends Control

const AftermathType = Enums.AftermathType
var _displayScore :int = 0

const DISPLAY_LOOKUP :Dictionary = {
	AftermathType.Crashed: "You crashed the ship!",
	AftermathType.InsufficientCheese: "Failed to gather enough cheese.",
	AftermathType.LeftOrbit: "You are lost in space...",
	AftermathType.NoOxygen: "You ran out of oxygen...",
	AftermathType.Success: "Gouda job!"
}


func update_display(type :int):
	var _success :bool = type == AftermathType.Success
	$Margin/Fail.visible = not _success
	$Margin/Success.visible = _success
	
	$Margin/VBoxContainer/Info.text = DISPLAY_LOOKUP.get(type, "")
	
	$Margin/VBoxContainer/CheeseScore.text = "CHEESE SCORE: %s" % GameManager.get_cheese_score()
	
	var elapsed = OS.get_unix_time() - GameManager.get_session_start_tick()
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	$Margin/VBoxContainer/Duration.text = "DURATION: %02d : %02d" % [minutes, seconds]
	
	$Margin/VBoxContainer/Bonuses.text = "BONUS:\n" + _get_bonuses_string(type)


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	$Margin/DoneButton.disabled = true
	TimeManager.add_tree_pause_source(self)
	MusicManager.enqueue(Enums.MusicType.Theme)


func _physics_process(_delta):
	$Margin/VBoxContainer/ScoreLabel.text = "TOTAL SCORE:\n%s" % _displayScore
	$Margin/DoneButton.disabled = _displayScore < GameManager.get_score()
	if _displayScore < GameManager.get_score():
		_displayScore = int(move_toward(_displayScore, GameManager.get_score(), 1000 if _has_skip_input() else 100))
		SfxManager.enqueue2d(Enums.SoundType.Beep)
	else:
		set_physics_process(false)


func _exit_tree():
	TimeManager.remove_tree_pause_source(self)


func _get_bonuses_string(type :int) -> String:
	match type:
		Enums.AftermathType.Success:
			return "Mission Success +%s" % Constants.SUCCESS_BONUS_POINTS
		_:
			return "-"


func _has_skip_input() -> bool:
	return Input.is_action_pressed("l-click") or Input.is_action_pressed("ui_accept")
