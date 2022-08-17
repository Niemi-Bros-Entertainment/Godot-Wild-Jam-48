# Sources:
# https://www.youtube.com/playlist?list=PL43PN07AM4J_7ZkZAUotpfijJSoibrvbr
# https://www.youtube.com/playlist?list=PLFt_AvWsXl0cONs3T0By4puYy6GM22ko8

tool
class_name PlanetData extends Resource

export(Material) var material :Material setget set_material
export(GradientTexture) var planetColor :GradientTexture setget set_planet_color
export var resolution :int = 10 setget set_resolution
export var radius :float = 50.0 setget set_radius
export(Array, Resource) var planetNoise setget set_planet_noise

#export var noise :OpenSimplexNoise setget set_noise
#export var amplitude :float = 1.0 setget set_amplitude
#export var minHeight :float = 1.0 setget set_min_height

var minHeight :float = 99999.0
var maxHeight :float = 0.0
var _seed :int = 0


func update_seed(s :int):
	_seed = s


func reset():
	minHeight = 99999.0
	maxHeight = 0.0


func set_planet_color(value):
	planetColor = value
	if planetColor != null and not planetColor.is_connected("changed", self, "on_data_changed"):
		# warning-ignore:return_value_discarded
		planetColor.connect("changed", self, "on_data_changed")
	#emit_signal("changed")


func set_material(value):
	material = value
	emit_signal("changed")


func set_radius(value):
	radius = value
	emit_signal("changed")


func set_resolution(value):
	resolution = value
	resolution = int(clamp(resolution, 2, 256))
	emit_signal("changed")


func set_planet_noise(value):
	planetNoise = value
	emit_signal("changed")
	for n in planetNoise:
		n.update_seed(_seed)
		# trigger our change, when noise resource changes
		if n != null and not n.is_connected("changed", self, "on_data_changed"):
			n.connect("changed", self, "on_data_changed")


func on_data_changed():
	emit_signal("changed")


func point_on_planet(pointOnUnitSphere :Vector3) -> Vector3:
	var elevation :float = 0.0
	for n in planetNoise:
		var levelElevation = n.noise.get_noise_3dv(pointOnUnitSphere * 100.0) # -1 to 1
		levelElevation = levelElevation + 1 / 2.0 * n.amplitude
		levelElevation = max(0.0, levelElevation - n.minHeight)
		elevation += levelElevation
	return pointOnUnitSphere * radius * (elevation+1.0)
