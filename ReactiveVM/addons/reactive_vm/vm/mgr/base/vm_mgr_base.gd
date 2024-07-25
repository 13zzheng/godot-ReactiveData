extends Node
class_name VMManagerBase


var systems = {}

var schedulers = {}
var cur_scheduler_id = 0
	
func init_system():
	for sys: VMSystemBase in systems.values():
		sys.init()
	pass
	
func clear_system():
	for sys: VMSystemBase in systems.values():
		sys.clear()
		
	systems.clear()

func add_system(system: VMSystemBase):
	system.set_vm_mgr(self)
	var id = system.get_instance_id()
	systems[id] = system
	return system
	

	
func scheduler(update: Callable):
	var id = get_scheduler_id()
	schedulers[id] = update
	return id
	pass
	
func unscheduler(id: int):
	if schedulers.has(id):
		schedulers.erase(id)
		pass
	pass
	
func get_scheduler_id():
	cur_scheduler_id += 1
	return cur_scheduler_id
	
func _process(delta):
	for key in schedulers:
		var cb = schedulers[key]
		if cb.is_valid():
			cb.call(delta)
		pass
	pass

func get_value(vm: VMData, path: NodePath):
	return vm.get_indexed(path)




func _get_value_with_path(vm: VMData, path: StringName):
	var keys = path.split(".")
	var obj = vm
	for key in keys:
		if obj is VMDict:
			obj = obj[key]
		elif obj is VMArray:
			obj = obj.geti(key.to_int())
		else:
			obj = obj[key]
	return obj
