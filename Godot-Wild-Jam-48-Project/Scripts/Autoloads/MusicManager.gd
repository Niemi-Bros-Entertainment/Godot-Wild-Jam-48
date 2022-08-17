'MusicManager'
extends Node

onready var serviceProvider :MusicProvider = MusicProvider.new(self)


func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _process(_delta :float):
	serviceProvider.process(_delta)


func enqueue(type :int):
	serviceProvider.enqueue(type)
	
	
func push(type :int):
	serviceProvider.push(type)
	
	
func pop():
	serviceProvider.pop()
	
	
func stop():
	serviceProvider.stop()


func set_mute(_value :bool):
	var index :int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(index, _value)


func is_mute() -> bool:
	var index :int = AudioServer.get_bus_index("Music")
	return AudioServer.is_bus_mute(index)


func get_pushed_track_count() -> int:
	return serviceProvider.get_pushed_track_count()



class MusicProvider extends Reference:
	const MusicType = Enums.MusicType

	var manager :Node
	var lastTrackIndex :int = 0
	var num_players :int = 1
	var bus :String = "Music"

	var available :Array = []  # The available players.
	var queue :Array = []  # The queue of clip sets to play by path.
	var playing :Dictionary = {} # <ClipSet, player>
	var pushed :Array = []

	# range of delays after a track finishes
	const DELAY_VARIATION = Vector2(5.0, 45.0)
	const MUSIC_PATH_FORMAT = "res://Audio/Music/Clip Sets/%s.tres"


	func _init(_manager :Node):
		manager = _manager
		
		# Create the pool of AudioStreamPlayer nodes.
		for i in num_players:
			var p = AudioStreamPlayer.new()
			manager.add_child(p)
			p.name = "Music " + str(i)
			#p.volume_db = 0 # for now
			available.append(p)
			#p.connect("finished", self, "_on_stream_finished", [p])
			p.bus = bus


	func _on_pushed_stream_finished(_player):
		#print("%s finished" % _player)
		pop()


	func push(type :int):
		available[0].stop()
		var index :int = MusicType.values().find(type)
		var path :String = MUSIC_PATH_FORMAT % MusicType.keys()[index]
		if not ResourceLoader.exists(path):
			return
		var clipSet :AudioClipSet = load(path)
		if clipSet:
			var p = AudioStreamPlayer.new()
			manager.add_child(p)
			p.name = "Pushed Music " + str(pushed.size()+1)
			pushed.append(p)
			p.bus = bus
			p.connect("finished", self, "_on_pushed_stream_finished", [p])
			
			var stream :AudioStreamOGGVorbis = clipSet.get_clip(lastTrackIndex)
			#stream.loop = false
			p.stream = stream
			p.volume_db = clipSet.get_volume_db()
			p.pitch_scale = clipSet.get_pitch()
			p.play()


	func pop():
		var popped = pushed.pop_back()
		if not popped:
			return
		popped.stop()
		popped.queue_free()
		if pushed.empty():
			available[0].volume_db = linear2db(0)
			available[0].play()


	func enqueue(type :int):
		match type:
			MusicType.None:
				stop()
				return
				
		var index :int = MusicType.values().find(type)
		var path :String = MUSIC_PATH_FORMAT % MusicType.keys()[index]
		#print("Enqueueing " + path)
		#queue.append(PlayInfo.new(path, pos))
		#if not queue.has(path):
		queue.append(path)


	func stop():
		for key in playing:
			key.stop()
			available.append(key)
			# warning-ignore:return_value_discarded
			playing.erase(key)
		#while (playing.size() > 0):
		#	playing_tracks.erase(playing[0].stream)
		#	playing[0].stop()
		#	available.append( playing.pop_front() )


	func process(_delta :float):
		if not pushed.empty():
			return
			
		# Play a queued sound if any players are available.
		if not queue.empty():
			var path = queue.pop_front()
			if not ResourceLoader.exists(path):
				return
			var clipSet :AudioClipSet = load(path)
			if clipSet:
				if playing.values().has(clipSet):
					return
				lastTrackIndex = clipSet.get_random_clip_index()
				var stream :AudioStreamOGGVorbis = clipSet.get_clip(lastTrackIndex)
				#stream.loop = false
				available[0].stream = stream
				available[0].volume_db = clipSet.get_volume_db()
				available[0].pitch_scale = clipSet.get_pitch()
				playing[available[0]] = clipSet
				available[0].play()
				#available.pop_front()


	func get_pushed_track_count() -> int:
		return pushed.size()

