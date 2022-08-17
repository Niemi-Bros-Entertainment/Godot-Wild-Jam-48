class_name HUDAftermath extends Control

var _delay :int = 30 # HACK: delay to prevent an immediate click of thedone button
var _score :int = 0
var _success :bool = false

const SCORE_FORMAT = "Score: %s"


func update_display(score :int, success :bool):
	_success = success
	_score = score
	$Margin/Fail.visible = not _success
	$Margin/Success.visible = _success
	$Margin/Info.text = SCORE_FORMAT % _score


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	$Margin/DoneButton.disabled = true
	TimeManager.add_tree_pause_source(self)
	MusicManager.enqueue(Enums.MusicType.Theme)


func _physics_process(delta):
	if _delay <= 0:
		set_physics_process(false)
		$Margin/DoneButton.disabled = false
	_delay -= 1


func _exit_tree():
	TimeManager.remove_tree_pause_source(self)
