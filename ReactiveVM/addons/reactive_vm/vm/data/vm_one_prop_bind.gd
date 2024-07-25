extends RefCounted
class_name VMOnePropBind


var vm_mgr: VMManager
var target: Object
var prop: NodePath
var vm_data: VMData
var key_path: NodePath

var prop_config = null

var update_func: Callable

var enabled: bool = true : set = set_enabled
var is_bind_vm: bool = false
var is_bind_node: bool = false


var _signal_callback: Callable = Callable()



func _init(vm_mgr):
	self.vm_mgr = vm_mgr
	pass


func bind_vm():
	if is_bind_vm:
		return
	if update_func:
		vm_mgr.watcher.watch_update(vm_data, update_func, update_func)
		pass
	else:
		vm_mgr.watcher.watch_update(vm_data, _on_vm_data_changed, key_path)
		update_node_prop()
		pass

	is_bind_vm = true
	pass


func bind_node():
	if is_bind_node:
		return

	is_bind_node = true
	pass


func set_enabled(value: bool) -> void:
	enabled = value
	pass


func update_node_prop():
	var value = vm_data.get_indexed(key_path)
	#print("update_node_prop", value)
	var config = _get_prop_conifg()
	if config.has("update_object"):
		config["update_object"].call(target, prop, value)
		return
		
	if typeof(target) == TYPE_OBJECT and typeof(value) == TYPE_CALLABLE:
		if !value.is_valid():
			return
		var signal_name = String(prop)
		if target.has_signal(signal_name):
			# disconnect old first.
			if _signal_callback.is_valid() and target.is_connected(signal_name, _signal_callback):
				target.disconnect(signal_name, _signal_callback)
				_signal_callback = Callable()
			# connect new.
			if !target.is_connected(signal_name, value):
				target.connect(signal_name, value)
				_signal_callback = value
		return
			
	target.set_indexed(prop, value)
	pass


func _on_vm_data_changed(vm):
	update_node_prop()
	pass

func _on_node_prop_changed():
	pass
	
	
func _get_prop_conifg():
	if prop_config == null:
		prop_config = vm_mgr.register.get_object_property_config(target, prop)
		prop_config = {} if prop_config == null else prop_config
	return prop_config
