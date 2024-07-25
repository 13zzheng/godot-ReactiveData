extends RefCounted

var getter: Callable
var vm
var value

var key_cb: Callable
var update_cb: Callable


var new_dep_ids = []
var deps: Array[Dep] = []

var lazy = false
var dirty = false

func _init(vm: VMData, exp_or_func, options: Dictionary = {}) -> void:
	self.vm = vm
		
	lazy = options.get("lazy", false)
	key_cb = options.get("key_cb", Callable())
	update_cb = options.get("update_cb", Callable())
	
	var type = typeof(exp_or_func)
	if type == TYPE_STRING or type == TYPE_NODE_PATH or type == TYPE_STRING_NAME:
		getter = func(vm):
			return vm.get_indexed(exp_or_func)
	elif type == TYPE_CALLABLE:
		getter = exp_or_func
		
	pass
	
func watch():
	#new_dep_ids.clear()
	Dep.push_target(self)
	var v = getv()
	Dep.pop_target()
	#new_dep_ids.clear()
	
	value = v
	pass
	
func getv():
	return getter.call(vm)


func update():
	if lazy:
		dirty = true
		return
	if key_cb.is_valid():
		var old_value = value
		value = getter.call(vm)
		key_cb.call(vm, value, old_value)
	elif update_cb.is_valid():
		update_cb.call(vm)
	else:
		value = getter.call(vm)
	pass
	
func evaluate():
	value = getter.call(vm)
	dirty = false
	
	
func add_dep(dep: Dep):
	#if new_dep_ids.has(dep.id):
		#return
	deps.append(dep)
	#new_dep_ids.append(dep.id)
	
func depend():
	for dep in deps:
		dep.depend()
	pass
