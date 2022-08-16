extends Node

const CHEESE_PICKUP = preload("res://Scenes/Prefabs/Pickups/Pickup.tscn")
const CHEESE_COUNT :int = 50
const MOON_RADIUS = Constants.MOON_RADIUS

var pickups :Array = []
var moon :Moon

func _ready():
	moon = get_tree().get_nodes_in_group("Moon")[0]
	assert(moon)
	


func _process(_delta):
	if pickups.size() < CHEESE_COUNT:
		_instance_cheese()
	else:
		set_process(false)


func _instance_cheese():
	var pos = moon.get_point_on_planet( Vector3(rand_range(-1.0, 1.0), \
	rand_range(-1.0, 1.0), \
	rand_range(-1.0, 1.0)))
	var pickup = CHEESE_PICKUP.instance()
	pickup.transform.origin = pos
	add_child(pickup)
	#pickup.global_transform.origin = pos
