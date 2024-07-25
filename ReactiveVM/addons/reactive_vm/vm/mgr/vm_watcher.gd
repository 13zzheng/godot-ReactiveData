extends VMSystemBase
class_name VMWatcher

const Watcher = preload("res://addons/reactive_vm/vm/data/watcher.gd")

var vm_mgr: VMManager

func set_vm_mgr(mgr):
	vm_mgr = mgr
	pass

func watch_update(data: VMData, update_func: Callable, dep_exp_or_func = null):
	var watcher
	if dep_exp_or_func:
		watcher = Watcher.new(data, dep_exp_or_func, {update_cb = vm_mgr.update.delay_update(update_func)})
	else:
		watcher = Watcher.new(data, update_func, {update_cb = vm_mgr.update.delay_update(update_func)})
	watcher.watch()
	return watcher
	pass


func watch_computed(data: VMData, computed_func: Callable):
	var watcher = Watcher.new(data, computed_func, {lazy = true})
	watcher.watch()
	return watcher
	pass
	
func watch_key(data: VMData, exp: NodePath, cb: Callable):
	var pack_cb = func(vm, new_v, old_v):
		cb.call(vm, vm.get_indexed(exp), old_v)
		pass
	var watcher = Watcher.new(data, exp, {key_cb = vm_mgr.update.delay_update(pack_cb)})
	watcher.watch()
	return watcher
	pass
