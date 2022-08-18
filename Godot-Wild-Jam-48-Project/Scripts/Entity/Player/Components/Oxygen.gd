class_name Oxygen extends Node

enum {
	NORMAL,
	BACKUP
}

signal depleted
signal updated(amount01)

export(float) var time :float = 120.0
onready var _current :float = time
var _state :int = NORMAL

const BACKUP_DURATION :float = 30.0


func _physics_process(delta):
	_current -= delta
	match _state:
		NORMAL:
			if _current <= 0:
				_current = BACKUP_DURATION
				_state = BACKUP
				emit_signal("depleted")
		BACKUP:
			if _current <= 0:
				_done()
	emit_signal("updated", get_amount_01())


func _done():
	set_physics_process(false)
	var gouda1 = get_tree().get_nodes_in_group("Gouda-1")[0]
	if (gouda1.global_transform.origin - get_parent().global_transform.origin).length() > Constants.SHIP_RADIUS:
		GameManager.mission_fail()
	else:
		GameManager.mission_success()


func get_amount_01() -> float:
	match _state:
		BACKUP:
			return clamp(_current / BACKUP_DURATION, 0.0, 1.0)
		_:
			return clamp(_current / time, 0.0, 1.0)
