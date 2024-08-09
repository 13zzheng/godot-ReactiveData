@tool
extends Control
class_name VMBinderNodesPanel


signal item_deleted(item)
signal item_selected(item)

const NodeItem = preload("res://addons/reactive_vm/vm/editor/item/node_item.tscn")

@export var node_list_view: ListContainer = null
var node_2_list_idx: Dictionary = {}

func _ready():
	node_list_view.on_item_selected.connect(_on_node_list_item_selected)

func set_node_list(nodes: Array[Node]):
	#prints("set_node_list", nodes)
	clear()
	for node in nodes:
		add_node_item(node)
		pass
	pass
	
func clear():
	#print(node_list)
	node_2_list_idx.clear()
	node_list_view.remove_all()
	pass
	
func add_node_item(node: Node, select: bool = false):
	_on_node_added(node)
	var item = NodeItem.instantiate()
	var list_item = node_list_view.add_item(item)
	item.set_node(node)
	item.delete_cb = func(i):
		item_deleted.emit(item)
		remove_node_item(item.node)
		pass
	if select:
		node_list_view.select_item(list_item)
	pass
	
func remove_node_item(node: Node):
	var idx = node_2_list_idx.get(node, -1)
	if idx != -1:
		node_list_view.remove(idx)
		_on_node_removed(node)
	pass
	
func select_node_item(node: Node):
	var idx = node_2_list_idx.get(node, -1)
	if idx != -1:
		node_list_view.select(idx)
		
func get_selected_node():
	var selected_idx = node_list_view.cur_selected
	if selected_idx != -1:
		var item_node = node_list_view.get_item_node(selected_idx)
		if item_node:
			return item_node.node;
			
func _on_node_added(node: Node):
	node_2_list_idx[node] = node_list_view.get_items().size()
	
func _on_node_removed(node: Node):
	node_2_list_idx.erase(node)
	
func _on_node_list_item_selected(list, item):
	item_selected.emit(item)
	pass

func _on_node_list_item_click(list, item):
	pass
