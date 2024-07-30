@tool
extends Node
class_name VMBinder

var node_config_arr: Array[VMBinderNodeConfig] = []
var nodes: Array[Node] = []

var vm_data: VMDict = null

var _bind_handlers: Array[VMOnePropBind] = []

@onready var vm_mgr: VMManager = get_node_or_null(VMManager.SingletonPath)

func _ready():
	pass
	
func bind(data: Dictionary) -> VMDict:
	var d = vm_mgr.reactive_data(data)
	vm_data = d
	_do_bind()
	return vm_data
	
func bind_node_prop(node: Node, prop: StringName, vm_path: String):
	add_node_prop_bind(node, prop, vm_path)
	
func get_node_config(node: Node) -> VMBinderNodeConfig:
	var idx = nodes.find(node)
	if idx == -1:
		return
	return node_config_arr[idx]
	
func filter_valid_nodes():
	for node in nodes:
		prints("filter_valid_nodes 1", node)
		if !is_instance_valid(node) or !node.is_inside_tree():
			prints("filter_valid_nodes 2", node)
			remove_node(node)
	pass
	

func add_node(node: Node):
	if !Engine.is_editor_hint():
		return
	var idx = nodes.find(node)
	if idx != -1:
		return
	_add_node(node)
	pass

func remove_node(node: Node):
	if !Engine.is_editor_hint():
		return
	var idx = nodes.find(node)
	if idx == -1:
		return
	_remove_node(node)
	
func exist_node(node: Node):
	var idx = nodes.find(node)
	return idx != -1
	
func add_node_prop_bind(node: Node, prop: StringName, vm_path: String):
	if !exist_node(node):
		_add_node(node)
	var cfg = get_node_config(node)
	if !cfg:
		return
	cfg.add_prop_config(prop, vm_path)
	pass
	
func _add_node(node: Node):
	nodes.append(node)
	var config = VMBinderNodeConfig.new()
	node_config_arr.append(config)
	pass
	
func _remove_node(node: Node):
	prints("VMBinder remove node", node)
	var idx = nodes.find(node)
	nodes.remove_at(idx)
	node_config_arr.remove_at(idx)
	
func _do_bind():
	if !vm_data:
		return
	var bind: VMBind = vm_mgr.bind
	for i in range(nodes.size()):
		var node = nodes[i]
		var cfg = node_config_arr[i]
		for prop_cfg: VMBinderPropConfig in cfg.prop_config_arr:
			if prop_cfg.check_valid():
				var handle = bind.bind(node, prop_cfg.node_prop, vm_data, prop_cfg.data_path)
				_bind_handlers.append(handle)
				pass
	pass
	
func _get_property_list():
	var properties = []
	properties.append({
		"name": "node_config_arr",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR, # See above assignment.
		"hint": PROPERTY_HINT_ENUM,
#		"hint_string": "Wooden,Iron,Golden,Enchanted"
	})
	
	properties.append({
		"name": "nodes",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT , # See above assignment.
		"hint" : PROPERTY_HINT_TYPE_STRING,
		"hint_string" : "24/34:Node",
	})
	return properties


