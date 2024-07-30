extends VMManagerBase
class_name VMManager

const SingletonName = "ReactiveVM"
const SingletonPath = "/root/" + SingletonName

var bind: VMBind
var reactive: VMReactive
var watcher: VMWatcher
var update: VMUpdate
var register: VMRegister
var global: VMGlobal

func _ready():
	_set_system()
	init_system()

func _set_system():
	bind = add_system(VMBind.new())
	reactive = add_system(VMReactive.new())
	watcher = add_system(VMWatcher.new())
	update = add_system(VMUpdate.new())
	register = add_system(VMRegister.new())
	global = add_system(VMGlobal.new())
	pass
	
	
func reactive_data(data, computed: Dictionary = {}) -> VMDict:
	var vm = reactive.reactive(data, computed)
	return vm
	
func reactive_data_global(tag: StringName, data, computed: Dictionary = {}):
	var vm = reactive_data(data, computed)
	global.add_vm(tag, vm)
	return vm
	
func get_vm(tag: StringName):
	return global.get_vm(tag)
	
	
func _exit_tree():
	clear_system()

