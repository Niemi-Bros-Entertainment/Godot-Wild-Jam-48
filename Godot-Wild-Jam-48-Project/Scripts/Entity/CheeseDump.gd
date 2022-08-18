'CheeseDump'
extends Area

var _bodies :Array = []

var _delay :float = DELAY_PER_CHEESE

const DELAY_PER_CHEESE :float = 0.15
const PICKUP_PARTICLE_PREFAB = Constants.PICKUP_PARTICLE_PREFAB


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if not body.is_in_group("Player") or _bodies.has(body):
		return
	_bodies.append(body)
	set_process(not _bodies.empty())


func _on_body_exited(body):
	_bodies.erase(body)
	set_process(not _bodies.empty())
	
	
# continually dump cheese while in the area
func _process(delta):
	if _delay > 0:
		_delay -= delta
	else:
		for b in _bodies:
			_dump_cheese(b)
		_delay = DELAY_PER_CHEESE


func _dump_cheese(b):
	if b.dump_cheese():
		var particle = PICKUP_PARTICLE_PREFAB.instance()
		particle.transform.origin = transform.origin
		get_parent().add_child(particle)
		SfxManager.enqueue(Enums.SoundType.CheeseDump, global_transform.origin)
