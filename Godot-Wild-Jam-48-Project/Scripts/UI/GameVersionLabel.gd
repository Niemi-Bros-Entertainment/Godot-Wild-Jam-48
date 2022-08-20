extends Label

const FORMAT = "%s"


func _ready():
	text = FORMAT % Constants.GAME_VERSION
