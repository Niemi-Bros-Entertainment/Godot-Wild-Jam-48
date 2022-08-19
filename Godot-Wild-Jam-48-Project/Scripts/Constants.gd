class_name Constants extends Reference

const CheeseType = Enums.CheeseType
const TITLE_SCENE_PATH :String = "res://Scenes/Title.tscn"
const TOUCHDOWN_SCENE_PATH :String = "res://Scenes/Touchdown.tscn"
const GAME_SCENE_PATH :String = "res://Scenes/Game.tscn"
const QUIT_SCENE_PATH :String = "res://Scenes/Quit.tscn"

const ORIGIN :Vector3 = Vector3.ZERO
const MOON_RADIUS :float = 50.0
const SHIP_RADIUS :float = 10.0
const CHEESE_CARRY_CAPACITY :float = 10.0

const SUCCESS_BONUS_POINTS :int = 1000

const PICKUP_PARTICLE_PREFAB = preload("res://Scenes/Prefabs/VFX/CheesePickupParticle.tscn")

const CHEESE_POINT_LOOKUP :Dictionary = {
	CheeseType.Swiss: 50,
	CheeseType.Cheddar: 100,
	CheeseType.Provolone: 250,
	CheeseType.Brie: 500,
	CheeseType.Gouda: 1000,
	CheeseType.Gorgonzola: 5000,
}
