class_name PlayMusic extends Node

const MusicType = Enums.MusicType
export(bool) var shouldPlayOnReady :bool = true
export(MusicType) var type :int = MusicType.None


func _ready():
	if shouldPlayOnReady:
		call_deferred("play_music")


func play_music():
	MusicManager.enqueue(type)
