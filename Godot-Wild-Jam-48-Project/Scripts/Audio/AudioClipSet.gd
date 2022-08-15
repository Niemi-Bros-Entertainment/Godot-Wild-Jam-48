class_name AudioClipSet extends Resource

export(Array, AudioStream) var clips :Array = []
export(float, 0.0, 2.0) var volumeMultiplier :float = 1.0
export(float, 0.0, 3.0) var pitchMultiplier :float = 1.0
export(float, 0.0, 3.0) var pitchRandomness :float = 0.1

var rng : RandomNumberGenerator


func _init():
	rng = RandomNumberGenerator.new()
	rng.randomize()


func get_random_clip_index() -> int:
	return rng.randi_range(0, clips.size())


func get_random_clip() -> AudioStream:
	clips.shuffle()
	return get_clip()


func get_clip(i = 0) -> AudioStream:
	i = clamp(i, 0, clips.size()-1)
	return clips[i]


func get_next_track_index(ref :int) -> int:
	ref += 1
	if ref >= clips.size():
		ref = 0
	return ref


func get_previous_track_index(ref :int) -> int:
	ref -= 1
	if ref < 0:
		ref = clips.size()-1
	return ref


func get_pitch() -> float:
	return rng.randf_range(pitchMultiplier - pitchRandomness, pitchMultiplier + pitchRandomness)


func get_volume_multiplier() -> float:
	return volumeMultiplier


func get_volume_db() -> float:
	return linear2db(get_volume_multiplier())
