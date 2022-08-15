'PlaySound'
class_name PlaySound extends Node

const SoundType = Enums.SoundType
export(bool) var shouldPlayOnReady :bool = true
export(String) var typeString :String = "None"


func _ready():
	if shouldPlayOnReady:
		call_deferred("play_sound")


func play_sound():
	var i :int = SoundType.keys().find(typeString)
	SfxManager.enqueue2d(SoundType.values()[i])
