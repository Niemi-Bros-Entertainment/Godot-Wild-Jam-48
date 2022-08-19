tool
extends EditorPlugin

const ALIGN_SELECTED = "Align Selected to Gravity"

var eds = get_editor_interface().get_selection()
var targetNodes :Array = []


func _enter_tree():
	_setup_menu_entries()
	eds.connect("selection_changed", self, "_on_selection_changed")


func _exit_tree():
	_remove_menu_entries()


func _setup_menu_entries():
	add_tool_menu_item(ALIGN_SELECTED, self, "_align_selected")
	
	
func _remove_menu_entries():
	remove_tool_menu_item(ALIGN_SELECTED)
	
	
func _align_selected(_ud):
	for targetNode in targetNodes:
		if targetNode and (targetNode is Spatial):
			(targetNode as Spatial).global_transform = PhysicsUtility.align_with_y(targetNode.global_transform, -PhysicsUtility.get_gravity_dir(targetNode.global_transform))
			print("Updated %s rotation" % targetNode)
		elif targetNode and not (targetNode is Spatial):
			push_warning("%s is not a Spatial node..." % targetNode)
		else:
			pass


func _on_selection_changed():
	targetNodes = eds.get_selected_nodes() 
