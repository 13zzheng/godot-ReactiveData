@tool
extends Control

const NodeItem = preload("res://addons/reactive_vm/vm/editor/item/node_item.tscn")

const PropBindItem = preload("res://addons/reactive_vm/vm/editor/item/prop_bind_item.tscn")
const PropBindAddItem = preload("res://addons/reactive_vm/vm/editor/item/prop_bind_add_item.tscn")

const NodeDrop = preload("res://addons/reactive_vm/vm/editor/item/node_drop.gd")

@export var prop_list_view: ListContainer = null

@export var node_drop: Control = null

@export var nodes_panel: VMBinderNodesPanel = null

signal show_vmbinder_view

var vm_binder: VMBinder

var vm_mgr: VMManager

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.is_editor_hint():
		return
	node_drop.drop_nodes.connect(_on_nodes_drop_in)
	nodes_panel.item_selected.connect(_on_node_item_selected)
	nodes_panel.item_deleted.connect(_on_node_item_deleted)
	
	pass # Replace with function body.

func _enter_tree():
	if Engine.is_editor_hint():
		var selection = EditorInterface.get_selection()
		selection.selection_changed.connect(_on_selected_node_changed)
	
func _exit_tree():
	if Engine.is_editor_hint():
		var selection = EditorInterface.get_selection()
		selection.selection_changed.disconnect(_on_selected_node_changed)

	
	
func _on_selected_node_changed():
	if !Engine.is_editor_hint():
		return
	var nodes = EditorInterface.get_selection().get_selected_nodes()
	prints("_on_selected_node_changed 1", nodes)
	if is_instance_valid(vm_binder):
		var is_cur_scene = vm_binder.owner == EditorInterface.get_edited_scene_root()
		if !is_cur_scene:
			unload_vm_binder()
			return
		pass
	if nodes.size() == 0:
		return
		
	var select_node = nodes[0]
	prints("_on_selected_node_changed 2", select_node, vm_binder)
		
	if select_node is VMBinder:
		load_vm_binder(select_node)
		show_vmbinder_view.emit()
	elif is_instance_valid(vm_binder):
		var idx = vm_binder.nodes.find(select_node)
		if idx != -1:
			select_node(vm_binder.nodes[idx])
			pass
	pass
	
	
#region VMBinder层处理
	
func load_vm_binder(binder):
	if vm_binder == binder:
		return
	vm_binder = binder
	if !vm_binder.tree_exiting.is_connected(unload_vm_binder):
		vm_binder.tree_exiting.connect(unload_vm_binder, CONNECT_ONE_SHOT)
	#prints("load_vm_binder", vm_binder, vm_binder.nodes)
	vm_binder.filter_valid_nodes()
	for node in vm_binder.nodes:
		_on_node_add_to_list(node)
		pass
	nodes_panel.set_node_list(vm_binder.nodes)
	
func unload_vm_binder():
	if !vm_binder:
		return
	#print("unload_vm_binder")
	vm_binder = null
	nodes_panel.clear()
	
func check_valid():
	if !vm_binder:
		return false
	if vm_binder.owner != EditorInterface.get_edited_scene_root():
		return false
	return true
	
#endregion


#region 节点层操作处理

func add_nodes(nodes: Array):
	if !vm_binder:
		return
	for i in range(nodes.size()):
		var node = get_node(nodes[i])
		if i == nodes.size() - 1:
			add_node(node, true)
		else:
			add_node(node)
	pass
	
func add_node(node: Node, select: bool = false):
	if !vm_binder:
		return
	if vm_binder.exist_node(node):
		return
	vm_binder.add_node(node)
	_on_node_add_to_list(node)
	nodes_panel.add_node_item(node, select)
	#print('mark_scene_as_unsaved -------1')
	EditorInterface.mark_scene_as_unsaved()
	pass
	
func remove_node(node: Node):
	#prints("VMBinderView remove node", node)
	if !vm_binder:
		return
	
	vm_binder.remove_node(node)
	nodes_panel.remove_node_item(node)
	#print('mark_scene_as_unsaved -------2')
	EditorInterface.mark_scene_as_unsaved()
	pass
	
func select_node(node: Node):
	if !vm_binder:
		return
	nodes_panel.select_node_item(node)

	
func _on_node_add_to_list(node: Node):
	if !node.tree_exited.is_connected(_on_node_tree_exited):
		node.tree_exited.connect(_on_node_tree_exited.bind(node), CONNECT_ONE_SHOT)
	pass
	
func _on_nodes_drop_in(nodes):
	add_nodes(nodes)
	pass
	
func _on_node_tree_exited(node: Node):
	prints("_on_node_tree_exited!!!!!!!!!", node)
	if !vm_binder:
		return
	vm_binder.filter_valid_nodes()
	nodes_panel.set_node_list(vm_binder.nodes)
	pass
	
func _on_node_item_selected(item):
	update_prop_bind_list()
	pass
	
func _on_node_item_deleted(item):
	if item.node:
		remove_node(item.node)

#endregion
	

#region propbind
func update_prop_bind_list():
	var selected_node = nodes_panel.get_selected_node()
	if !selected_node:
		_clear_prop_bind_list()
		return
	var node_cfg = vm_binder.get_node_config(selected_node)
	prints("update_prop_bind_list", selected_node, node_cfg.prop_config_arr)
	if node_cfg:
		_clear_prop_bind_list()
		for prop_cfg in node_cfg.prop_config_arr:
			var item = _add_prop_bind_item()
			item.prop_cfg = prop_cfg
		_add_prop_bind_add_item()
		
	pass

func _clear_prop_bind_list():
	prop_list_view.remove_all()
	pass
	
func _add_empty_prop_bind():
	var cur_node = nodes_panel.get_selected_node()
	if !cur_node:
		return
	vm_binder.add_node_prop_bind(cur_node, "", "")
	pass

func _add_prop_bind_item():
	var item = PropBindItem.instantiate()
	item.select_func = prop_list_view.select_node.bind(item)
	prop_list_view.add_item(item)
	return item
	pass
	
func _add_prop_bind_add_item():
	var item = PropBindAddItem.instantiate()
	prop_list_view.add_item(item)
	pass
#endregion

