'HUDScore'
extends Label

export(bool) var shouldUseFormat :bool = false
const SCORE_FORMAT :String = "Score: %s"

func _ready():
	# warning-ignore:return_value_discarded
	GameManager.connect("score_changed", self, "_on_score_changed")
	_on_score_changed()
	
	
func _on_score_changed():
	modulate = Color(2,2,2)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.white, 1.0)
	# aftermath display uses score format
	if shouldUseFormat:
		text = SCORE_FORMAT % GameManager.get_score()
	else:
		text = str(GameManager.get_score())
