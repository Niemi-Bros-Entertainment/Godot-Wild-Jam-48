'Sfx Manager'
extends Node

const SFX_PATH_FORMAT = "res://Audio/SFX/Clip Sets/%s.tres"
const CLIP_SETS_DIRECTORY = "res://Audio/SFX/Clip Sets"
const MAX_DISTANCE :float = 50.0
const UNIT_SIZE :float = 10.0
const BUS :String = "SFX"

onready var serviceProvider :SfxProvider = SfxProvider.new(self)


func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _ready():
	# warning-ignore:return_value_discarded
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_change")


func _on_gui_focus_change(_arg :Control):
	if SceneManager.is_loading():
		return
		
	if _arg.is_visible_in_tree():
		enqueue2d(Enums.SoundType.MenuNavigate)


func set_mute(_value :bool):
	var index :int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(index, _value)
	
	
func _process(delta :float):
	serviceProvider.process(delta)


func enqueue2d(type :int, pitchScale :float = 1.0):
	serviceProvider.enqueue2d(type, pitchScale)


func enqueue(type :int, pos :Vector3, pitchScale :float = 1.0):
	serviceProvider.enqueue(type, pos, pitchScale)


func get_clip_set(id :String):
	return serviceProvider.get_clip_set_by_path(SFX_PATH_FORMAT % id)


func get_clip_set_by_path(path :String):
	return serviceProvider.get_clip_set_by_path(path)


func is_mute() -> bool:
	var index :int = AudioServer.get_bus_index("SFX")
	return AudioServer.is_bus_mute(index)


class SfxProvider extends Reference:
	const SoundType = Enums.SoundType

	enum PlayerType {
		Positional = 0,
		Mono,
	}

	var manager :Node
	# <type, array>
	var available :Dictionary = {}  # The available players.
	# <type, array>
	var queue :Dictionary = {}  # The queue of sounds to play via PlayInfos.

	var clipSetLookup :Dictionary = {}

	const NUM_PLAYERS :int = 32

	const COMBINE_WINDOW :float = 0.1
	const COMBINE_WINDOW_MS :int = int(COMBINE_WINDOW * 1000) # in ms


	func _init(_manager :Node):
		manager = _manager
		_populate_lookup()
		
		# Create the pool of AudioStreamPlayer nodes.
		for pType in PlayerType.values():
			var players :Array = []
			for i in NUM_PLAYERS:
				var p
				match pType:
					PlayerType.Mono:
						p = AudioStreamPlayer.new()
						p.name = "Sfx Mono " + str(i)
					_:
						p = AudioStreamPlayer3D.new()
						p.pause_mode = Node.PAUSE_MODE_STOP #3D sfx dont process on pause
						p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
						p.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
						p.emission_angle_enabled = false
						p.max_distance = MAX_DISTANCE
						p.unit_size = UNIT_SIZE # affects attenuation
						p.name = "Sfx 3D " + str(i)
				manager.add_child(p)
				players.append(p)
				if p.connect("finished", self, "_on_stream_finished", [pType, p]) != OK:
					.push_error("Failed to connect AudioStreamPlayer to _on_stream_finished")
				p.bus = BUS
			available[pType] = players
			queue[pType] = []


	func _populate_lookup():
		print("\n")
		print("Loading SFX Clip Sets...")
		clipSetLookup.clear()
		var dir = Directory.new()
		if dir.open(CLIP_SETS_DIRECTORY) == OK:
			dir.list_dir_begin(true, true)
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					var path = CLIP_SETS_DIRECTORY + "/" + file_name
					clipSetLookup[path] = load(path)
				file_name = dir.get_next()
			print("Successfully Loaded SFX Clip Sets\n")
		else:
			print("An error occurred when trying to access the path.")


	func _on_stream_finished(playerType :int, player):
		# When finished playing a stream, make the player available again.
		available.get(playerType).append(player)


	func enqueue2d(type :int, pitchScale :float):
		if type == SoundType.None:
			return
		var index = SoundType.values().find(type)
		var path = SFX_PATH_FORMAT % SoundType.keys()[index]
		#print("Enqueueing 2D SFX " + path)
		if !queue.has(PlayerType.Mono):
			push_error("No Mono player type queue available!?")
			return
		# merge frequent occurances of same sound type
		if not queue.get(PlayerType.Mono).empty():
			var last = queue.get(PlayerType.Mono).back()
			if abs(OS.get_ticks_msec() - last.time) <= COMBINE_WINDOW_MS and last.path == path:
				#print("Ignoring " + path + " matches last recent sound type")
				return
		queue.get(PlayerType.Mono).append(PlayInfo.new(path, Vector3.ZERO, pitchScale))


	func enqueue(type :int, pos :Vector3, pitchScale :float):
		if type == SoundType.None or manager.get_tree().paused:
			return
		var index = SoundType.values().find(type)
		var path = SFX_PATH_FORMAT % SoundType.keys()[index]

		if !queue.has(PlayerType.Positional):
			push_error("No Positional/3D player type queue available!?")
			return
		# merge frequent occurances of same sound type
		if not queue.get(PlayerType.Positional).empty():
			var last = queue.get(PlayerType.Positional).back()
			if last.path == path and abs(OS.get_ticks_msec() - last.time) <= COMBINE_WINDOW_MS:
				last.position = last.position.move_toward(pos, 0.5) # average of positions
				# average of pitches
				last.pitch += pitchScale
				last.pitch *= 0.5
				return
		queue.get(PlayerType.Positional).append(PlayInfo.new(path, pos, pitchScale))


	func process(_delta :float):
		for key in queue:
			_process_queue(key)
		
		
	func _process_queue(key :int):
		var array :Array = queue.get(key)
		# Play a queued sound if any players are available.
		if not array.empty() and not available.get(key).empty():
			var playInfo = queue[key].pop_front()
			#var clipSet = load(playInfo.path)
			var clipSet :AudioClipSet = get_clip_set_by_path(playInfo.path)
			if clipSet:
				match key:
					PlayerType.Positional:
						#available[key][0].attenuation = 1.0
						#available[key][0].max_distance = MAX_DISTANCE
						available[key][0].unit_db = clipSet.get_volume_db()
						available[key][0].global_transform.origin = playInfo.position
						continue # proceed to default
						
					PlayerType.Mono:
						available[key][0].volume_db = clipSet.get_volume_db()
						continue # proceed to default
						
					_:
						available[key][0].stream = clipSet.get_random_clip()
						available[key][0].pitch_scale = playInfo.pitch * clipSet.get_pitch()
						available[key][0].play()
			available.get(key).pop_front()
		
		
	func get_clip_set_by_path(path :String) -> AudioClipSet:
		if not clipSetLookup.has(path):
			push_warning("Audio Clip Set at %s does not exist!" % path)
		return clipSetLookup.get(path)
		

	# --- Nested Classes ---

	# TODO: volume and pitch multipliers? Custom audio bus?
	class PlayInfo extends Reference:
		func _init(_path :String, _position = Vector3.ZERO, pitchScale :float = 1.0):
			position = _position
			path = _path
			pitch = pitchScale
			time = OS.get_ticks_msec()
		
		var time :int
		var position :Vector3
		var pitch :float
		var path :String
