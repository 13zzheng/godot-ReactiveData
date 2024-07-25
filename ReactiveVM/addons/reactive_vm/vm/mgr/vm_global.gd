extends VMSystemBase
class_name VMGlobal

var vm_mgr: VMManager

var _global_vm = {}

func set_vm_mgr(mgr):
	vm_mgr = mgr
	pass
	
func add_vm(tag: StringName, vm: VMData):
	if _global_vm.has(tag):
		push_error("global vm tag is already exit", tag, vm)
		return
	_global_vm[tag] = vm
	
func remove_vm(tag: StringName):
	if !_global_vm.has(tag):
		return
		
	_global_vm.erase(tag)
	pass
	
func get_vm(tag: StringName):
	return _global_vm.get(tag)
	
func clear():
	_global_vm.clear()
	pass
	

