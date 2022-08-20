extends Label

const FORMAT = "Godot %s"


func _ready():
	text = FORMAT % Engine.get_version_info().string
