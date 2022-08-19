'SpeedBubble'
extends Area

const SPEED_MULTIPLIER :float = 4.0
const PLAYER_NODE_GROUP :String = "Player"


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(_body):
#	if body.is_in_group( PLAYER_NODE_GROUP ):
#		_boost(body)
	pass


func _on_body_exited(body):
	if body.is_in_group( PLAYER_NODE_GROUP ):
		_boost(body)


func _boost(body):
	body.boost(SPEED_MULTIPLIER)
	SfxManager.enqueue2d(Enums.SoundType.Boost)
	#SfxManager.enqueue(Enums.SoundType.Boost, global_transform.origin)
