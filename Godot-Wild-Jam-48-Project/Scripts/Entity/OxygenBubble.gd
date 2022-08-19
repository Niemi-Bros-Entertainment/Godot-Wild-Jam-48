'OxygenBubble'
extends Area

var _bodies :Array = []
const OXYGEN_DEPLETION_MULTIPLIER :float = 0.0 # zero stops all oxygen depletion


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if not body.is_in_group("Player") or _bodies.has(body):
		return
	_bodies.append(body)
	body.add_oxygen_depletion_multiplier(self, OXYGEN_DEPLETION_MULTIPLIER)


func _on_body_exited(body):
	_bodies.erase(body)
	if body.is_in_group("Player"):
		body.remove_oxygen_depletion_multiplier(self)
	set_process(not _bodies.empty())
