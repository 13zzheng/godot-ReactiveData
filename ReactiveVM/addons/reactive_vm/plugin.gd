@tool
extends EditorPlugin

const VMBinderView = preload("res://addons/reactive_vm/vm/editor/vm_binder_view.tscn")

const SingletonName = VMManager.SingletonName

var vmbinder_view: Control

func _enter_tree():
	add_autoload_singleton(SingletonName, "res://addons/reactive_vm/vm/vm_manager.gd")
	vmbinder_view = VMBinderView.instantiate()
	add_control_to_bottom_panel(vmbinder_view, "VM Binder")
	vmbinder_view.show_vmbinder_view.connect(_on_show_vmbinder_view)
	print("VM initialized!")

func _disable_plugin():
	remove_control_from_bottom_panel(vmbinder_view)
	remove_autoload_singleton(SingletonName)
	print("VM disabled.")
	
	
func _on_show_vmbinder_view():
	make_bottom_panel_item_visible(vmbinder_view)
	pass
