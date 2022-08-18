class_name Inventory extends Node

signal inventory_changed

var items :Dictionary = {}
const CARRY_CAPACITY = Constants.CHEESE_CARRY_CAPACITY


func add_cheese(type :int):
	if is_full():
		return
	items[type] = items.get(type, 0) + 1
	emit_signal("inventory_changed")
	
	
func remove_cheese(type :int):
	if items.has(type):
		items[type] = items[type] - 1
		if items[type] <= 0:
			# warning-ignore:return_value_discarded
			items.erase(type)
		emit_signal("inventory_changed")


func dump_cheese() -> bool:
	for key in items:
		if items[key] > 0:
			remove_cheese(key)
			return true
	return false


func clear_inventory():
	items.clear()
	emit_signal("inventory_changed")


func get_carried_cheese_count() -> int:
	var result :int = 0
	for key in items:
		result += items[key]
	return result
	
	
func is_full() -> bool:
	return get_carried_cheese_count() >= CARRY_CAPACITY
