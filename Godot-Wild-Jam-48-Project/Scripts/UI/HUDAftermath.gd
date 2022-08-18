class_name HUDAftermath extends Control

const AftermathType = Enums.AftermathType

var _delay :int = 30 # HACK: delay to prevent an immediate click of the 'done' button

const DISPLAY_LOOKUP :Dictionary = {
	AftermathType.Crashed: "You crashed the ship!",
	AftermathType.InsufficientCheese: "Failed to gather enough cheese.",
	AftermathType.LeftOrbit: "You are lost in space...",
	AftermathType.NoOxygen: "You ran out of oxygen...",
	AftermathType.Success: "Well done!"
}


func update_display(type :int):
	var _success :bool = type == AftermathType.Success
	$Margin/Fail.visible = not _success
	$Margin/Success.visible = _success
	$Margin/Info.text = DISPLAY_LOOKUP.get(type, "")


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	$Margin/DoneButton.disabled = true
	TimeManager.add_tree_pause_source(self)
	MusicManager.enqueue(Enums.MusicType.Theme)


func _physics_process(_delta):
	if _delay <= 0:
		set_physics_process(false)
		$Margin/DoneButton.disabled = false
	_delay -= 1


func _exit_tree():
	TimeManager.remove_tree_pause_source(self)
