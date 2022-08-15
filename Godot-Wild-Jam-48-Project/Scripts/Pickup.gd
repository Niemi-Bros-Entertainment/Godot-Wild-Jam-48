'Pickup'
extends Area

func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	
	
func _on_body_entered(_body):
	collect()


func collect():
	SfxManager.enqueue(Enums.SoundType.Pickup, global_transform.origin)
	queue_free() # goodbye!
