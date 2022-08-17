'CheesePlacer'
extends Control

signal instance_cheese
	
enum CheeseType {
	Swiss = 0,
	Cheddar,
	Provolone,
	Brie,
	Wheel
}
	
	
const SWISS_PICKUP = preload("res://Scenes/Prefabs/Pickups/Swiss.tscn")
const CHEDDAR_PICKUP = preload("res://Scenes/Prefabs/Pickups/Cheddar.tscn")
const BRIE_PICKUP = preload("res://Scenes/Prefabs/Pickups/Brie.tscn")
const PROVOLONE_PICKUP = preload("res://Scenes/Prefabs/Pickups/Provolone.tscn")
const WHEEL_PICKUP = preload("res://Scenes/Prefabs/Pickups/Wheel.tscn")

const CHEESE_COUNT :Dictionary = {
	CheeseType.Swiss: 25,
	CheeseType.Cheddar: 10,
	CheeseType.Provolone: 5,
	CheeseType.Brie: 5,
	CheeseType.Wheel: 5
}
const MOON_RADIUS :float = Constants.MOON_RADIUS
const MESSAGE :String = "Locating Cheese..."
const CHEESE_VERTICAL_OFFSET_PER_TYPE :float = 10.0
const CHEESE_VERTICAL_OFFSET :float = 1.5

var frameDelay :int = 30
var cheeseChoices :Array = [
	SWISS_PICKUP, 
	CHEDDAR_PICKUP,
	PROVOLONE_PICKUP,
	BRIE_PICKUP,
	WHEEL_PICKUP
]

onready var label :Label = $Label

var pickups :Dictionary = {}
var moon :Moon


func _ready():
	# prepare the pickups lookup, array for each cheese type
	for i in range(CheeseType.size()):
		pickups[i] = []
	
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
		label.visible_characters += 1
		
	var isDone :bool = true
	for i in range(CheeseType.size()):
		if pickups[i].size() < CHEESE_COUNT.get(i, 1):
			isDone = false
			_instance_cheese(i)
			
	if isDone:
		hide()


func _instance_cheese(type :int):
	var randVector :Vector3 = Vector3(rand_range(-1.0, 1.0), \
	rand_range(-1.0, 1.0), \
	rand_range(-1.0, 1.0))
	randVector = randVector.normalized()
	var pos :Vector3 = moon.get_point_on_planet( randVector )
	
	# select a random cheese
	#cheeseChoices.shuffle()
	#var pickup = cheeseChoices[0].instance()
	var pickup = cheeseChoices[type].instance()
	
	pickup.transform.origin = pos
	add_child(pickup)
	pickups[type].append(pickup)
	
	# shift pickup away from gravity to avoid ground clipping
	pickup.global_transform.origin -= GameManager.get_gravity_dir(pickup.global_transform) * (CHEESE_VERTICAL_OFFSET + (CHEESE_VERTICAL_OFFSET_PER_TYPE * type))
	emit_signal("instance_cheese")
