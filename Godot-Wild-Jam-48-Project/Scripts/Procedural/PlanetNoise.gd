# Sources:
# https://www.youtube.com/playlist?list=PL43PN07AM4J_7ZkZAUotpfijJSoibrvbr
# https://www.youtube.com/playlist?list=PLFt_AvWsXl0cONs3T0By4puYy6GM22ko8

tool
class_name PlanetNoise extends Resource

export var noise :OpenSimplexNoise setget set_noise
export var amplitude :float = 1.0 setget set_amplitude
export var minHeight :float = 1.0 setget set_min_height


func update_seed(s :int):
	# NOTE: this triggers a changed signal
	if is_instance_valid(noise):
		noise.seed = s


func set_noise(value):
	value.seed = randi()
	noise = value
	emit_signal("changed")
	# trigger our change, when noise resource changes
	if noise != null and not noise.is_connected("changed", self, "on_data_changed"):
		# warning-ignore:return_value_discarded
		noise.connect("changed", self, "on_data_changed")


func set_amplitude(value):
	amplitude = value
	emit_signal("changed")


func set_min_height(value):
	minHeight = value
	emit_signal("changed")


func on_data_changed():
	emit_signal("changed")
