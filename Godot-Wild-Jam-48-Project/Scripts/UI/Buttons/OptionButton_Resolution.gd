'OptionButton_Resolution'
extends OptionButton

enum ResolutionOptions {
	Auto,
	x240p, 
	x360p,
	x480p,
	x720p,
	x1080p,
}


const RESOLUTIONS = {
	ResolutionOptions.x240p:Vector2(426, 240),
	ResolutionOptions.x360p:Vector2(640, 360),
	ResolutionOptions.x480p:Vector2(854,480),
	ResolutionOptions.x720p:Vector2(1280, 720),
	ResolutionOptions.x1080p:Vector2(1920, 1080),
}


func _ready():
#	add_to_group(Constants.SELECTABLE_UI_GROUP)
	for i in ResolutionOptions.keys().size():
#		if i == 0:
#			continue
		var display = ResolutionOptions.keys()[i]
		add_item("%s" % display)
	
	var viewportSize :Vector2 = get_viewport().size
	#print(viewportSize)
	var result :int = 0
	var i: int = 0
	for v in ResolutionOptions.values():
		if viewportSize == RESOLUTIONS.get(v, Vector2.ZERO):
			result = i
			break
		i += 1
	
	selected = result
	
	
	# warning-ignore:return_value_discarded
	connect("item_selected", self, "_on_item_selected")


func _on_item_selected(i :int):
	GameManager.defaultResolution = RESOLUTIONS.get(i, OS.get_screen_size())
	GameManager.on_window_resize()
