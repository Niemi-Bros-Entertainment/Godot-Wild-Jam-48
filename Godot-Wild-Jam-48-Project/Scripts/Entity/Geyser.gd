'Geyser'
extends Area

export(float) var force :int = 3.0

var _bodies :Array = []


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if _bodies.has(body):
		return
	_bodies.append(body)


func _on_body_exited(body):
	_bodies.erase(body)
	
	
func _physics_process(delta):
	for b in _bodies:
		if b.is_in_group("Player"):
			b.apply_force(Vector3.UP * force * delta)
