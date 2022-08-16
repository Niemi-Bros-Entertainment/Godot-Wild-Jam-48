'CheesePlacer'
extends Control
	
const SWISS_PICKUP = preload("res://Scenes/Prefabs/Pickups/Swiss.tscn")
const CHEESE_COUNT :int = 100
const MOON_RADIUS = Constants.MOON_RADIUS
const MESSAGE = "Locating Cheese..."

var frameDelay :int = 30
var cheeseChoices :Array = [SWISS_PICKUP]

onready var label :Label = $Label

var pickups :Array = []
var moon :Moon


func _ready():
	randomize()
	moon = get_tree().get_nodes_in_group("Moon")[0]
	assert(moon)


func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			set_process(is_visible_in_tree())


func _process(_delta):
	if frameDelay > 0:
		frameDelay -= 1
		return
		
	if label.visible_characters < MESSAGE.length():
		SfxManager.enqueue2d(Enums.SoundType.Beep)
		
	if pickups.size() < CHEESE_COUNT:
		label.visible_characters += 1
		_instance_cheese()
	else:
		if label.visible_characters >= MESSAGE.length():
			visible = false


func _instance_cheese():
	var pos = moon.get_point_on_planet( Vector3(rand_range(-1.0, 1.0), \
	rand_range(-1.0, 1.0), \
	rand_range(-1.0, 1.0)))
	
	# select a random cheese
	cheeseChoices.shuffle()
	var pickup = cheeseChoices[0].instance()
	
	pickup.transform.origin = pos
	add_child(pickup)
	pickups.append(pickup)
	#pickup.global_transform.origin = pos
