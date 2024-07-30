@tool
extends Control

const NodeItem = preload("res://addons/reactive_vm/vm/editor/item/node_item.tscn")

const PropBindItem = preload("res://addons/reactive_vm/vm/editor/item/prop_bind_item.tscn")
const PropBindAddItem = preload("res://addons/reactive_vm/vm/editor/item/prop_bind_add_item.tscn")

const NodeDrop = preload("res://addons/reactive_vm/vm/editor/item/node_drop.gd")

@export var node_list_view: ListContainer = null

@export var prop_list_view: ListContainer = null

@export var node_drop: Control = null

signal show_vmbinder_view

var vm_binder: VMBinder

var node_2_list_idx: Dictionary

var vm_mgr: VMManager

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.is_editor_hint():
		return
	node_drop.drop_nodes.connect(_on_nodes_drop_in)
	node_list_view.on_item_selected.connect(_on_node_list_item_selected)
	
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
	if !(select_node is VMBinder):
		return
	load_vm_binder(select_node)
	show_vmbinder_view.emit()
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
	_set_node_list(vm_binder.nodes)
	
func unload_vm_binder():
	if !vm_binder:
		return
	#print("unload_vm_binder")
	vm_binder = null
	_clear_node_list()
	
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
	_add_node_list_item(node, select)
	#print('mark_scene_as_unsaved -------1')
	EditorInterface.mark_scene_as_unsaved()
	pass
	
func remove_node(node: Node):
	#prints("VMBinderView remove node", node)
	if !vm_binder:
		return
	
	vm_binder.remove_node(node)
	_remove_node_list_item(node)
	#print('mark_scene_as_unsaved -------2')
	EditorInterface.mark_scene_as_unsaved()
	pass
	

	
func _on_nodes_drop_in(nodes):
	add_nodes(nodes)
	pass
	
func _on_node_tree_exited(node: Node):
	prints("_on_node_tree_exited!!!!!!!!!", node)
	if !vm_binder:
		return
	vm_binder.filter_valid_nodes()
	_set_node_list(vm_binder.nodes)
	pass

#endregion
	
	
#region 节点显示列表层处理
func _set_node_list(nodes: Array[Node]):
	#prints("set_node_list", nodes)
	_clear_node_list()
	for node in nodes:
		_add_node_list_item(node)
		pass
	pass
	
func _clear_node_list():
	#print(node_list)
	node_2_list_idx.clear()
	node_list_view.remove_all()
	_clear_prop_bind_list()
	pass
	
func _add_node_list_item(node: Node, select: bool = false):
	if !node.tree_exited.is_connected(_on_node_tree_exited):
		node.tree_exited.connect(_on_node_tree_exited.bind(node), CONNECT_ONE_SHOT)
		
	node_2_list_idx[node] = node_list_view.get_items().size()
	var item = NodeItem.instantiate()
	var list_item = node_list_view.add_item(item)
	item.set_node(node)
	item.delete_cb = func(i):
		remove_node(node)
		pass
	if select:
		node_list_view.select_item(list_item)
	pass
	
func _remove_node_list_item(node: Node):
	var idx = node_2_list_idx[node]
	if idx != null:
		node_2_list_idx.erase(node)
		node_list_view.remove(idx)
	pass
	
func _on_node_list_item_selected(list, item):
	print("_on_node_list_item_selected")
	update_prop_bind_list()
	pass

func _on_node_list_item_click(list, item):
	pass
	
#endregion
	

#region propbind
func update_prop_bind_list():
	var selected = node_list_view.cur_selected
	print("update_prop_bind_list", selected)
	if selected == -1:
		return
	var selected_node = node_list_view.get_item_node(selected)
	if !selected_node:
		_clear_prop_bind_list()
		return
	var node_cfg = vm_binder.get_node_config(selected_node.node)
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
	var cur_selected= node_list_view.get_selected()
	var cur_node = cur_selected.node
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

