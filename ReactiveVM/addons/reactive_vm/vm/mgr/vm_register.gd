extends VMSystemBase
class_name VMRegister

var vm_mgr: VMManager


var _registed_class = {}
var _registed_script = {}

func set_vm_mgr(mgr):
	vm_mgr = mgr
	pass
	
	
func reg_class(cls_name, property_path: String, handler: Dictionary = {}):
	if !_registed_class.has(cls_name):
		_registed_class[cls_name] = {}
	var cls_config = _registed_class[cls_name]
	if !cls_config.has(property_path):
		cls_config[property_path] = {}
	var config = cls_config[property_path]
	if handler.has("update_object"):
		config["update_object"] = handler["update_object"]
		
	if handler.has("update_data"):
		config["update_data"] = handler["update_data"]
	
func reg_script(script: Script, property_path: String, handler: Dictionary = {}):
	var script_key = _get_script_key(script)
	if !_registed_script.has(script_key):
		_registed_script[script_key] = {}
	var cls_config = _registed_script[script_key]
	if !cls_config.has(property_path):
		cls_config[property_path] = {}
	var config = _registed_script[property_path]
	if handler.has("update_object"):
		config["update_object"] = handler["update_object"]
		
	if handler.has("update_data"):
		config["update_data"] = handler["update_data"]
	
	
func get_object_property_config(obj: Object, property: String):
	var script = obj.get_script()
	if script == null:
		return get_class_property_config(obj.get_class(), property)
	return get_script_property_config(script, property)
	
func get_class_property_config(cls_name: String, property: String):
	var search_cls = cls_name
	var property_coinfg = null
	while !search_cls.is_empty() and property_coinfg == null:
		property_coinfg = _get_class_self_property_config(search_cls, property)
		search_cls = ClassDB.get_parent_class(search_cls)
	return property_coinfg
	
func get_script_property_config(script: Script, property: String):
	var search_script = script
	var property_config = null
	while search_script != null and property_config == null:
		property_config = _get_script_self_property_config(search_script, property)
		search_script = search_script.get_base_script()
	if property_config == null:
		var cls_name = script.get_instance_base_type()
		property_config = get_class_property_config(cls_name, property)
	return property_config
	
func _get_script_key(script: Script):
	return script.resource_path
	
	
func _get_class_self_property_config(cls_name: String, property: String):
	var config = _registed_class.get(cls_name)
	if config == null:
		return
		
	var property_config = config.get(property)
	return property_config
	pass
	
func _get_script_self_property_config(script: Script, property: String):
	var script_key = _get_script_key(script)
	var config = _registed_script.get(script_key)
	if config == null:
		return
		
	var property_config = config.get(property)
	return property_config
	pass
