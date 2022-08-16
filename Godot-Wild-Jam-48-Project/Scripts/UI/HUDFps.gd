'HUDFps'
extends Label

var frames : float
var timescale :float

const DISPLAY_fORMAT = "FPS: {fps} (x{scale})"
const FONT_COLOR = "font_color"
const EMPTY_STRING = ""


func _ready():
	visible = OS.has_feature("debug")


func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible


func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			set_process(visible)


func _process(_delta: float):
	#frames = Engine.get_frames_per_second()
	frames = Performance.get_monitor(Performance.TIME_FPS)
	timescale = Engine.time_scale
	text = DISPLAY_fORMAT.format({"fps":frames, "scale":timescale})
	
	if frames >= 55:
		add_color_override(FONT_COLOR, Color(0.25, 1, 0.2, 1))
	elif frames <= 25:
		add_color_override(FONT_COLOR, Color(1, 0.5, 0, 1))
	elif frames <= 15:
		add_color_override(FONT_COLOR, Color(1, 0, 0, 1))
	else:
		add_color_override(FONT_COLOR, Color(1, 1, 0, 1))

