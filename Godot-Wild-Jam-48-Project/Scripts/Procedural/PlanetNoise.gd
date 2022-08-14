tool
class_name PlanetNoise extends Resource

export var noise :OpenSimplexNoise setget set_noise
export var amplitude :float = 1.0 setget set_amplitude
export var minHeight :float = 1.0 setget set_min_height


func set_noise(value):
	noise = value
	emit_signal("changed")
	# trigger our change, when noise resource changes
	if noise != null and not noise.is_connected("changed", self, "on_data_changed"):
		noise.connect("changed", self, "on_data_changed")


func set_amplitude(value):
	amplitude = value
	emit_signal("changed")


func set_min_height(value):
	minHeight = value
	emit_signal("changed")


func on_data_changed():
	emit_signal("changed")
