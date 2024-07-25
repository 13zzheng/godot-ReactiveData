extends VMSystemBase
class_name VMUpdate

var vm_mgr: VMManager

var update_stack = []

var update_stage = false

var update_handler: int

func set_vm_mgr(mgr):
	vm_mgr = mgr
	pass

func init():
	update_handler = vm_mgr.scheduler(_update)
	pass
	
func clear():
	if update_handler:
		vm_mgr.unscheduler(update_handler)
		update_handler = 0
	pass

func delay_update(update_func: Callable):
	return func(arg1=null,arg2=null,arg3=null):
		var args = []
		for arg in [arg1, arg2, arg3]:
			if arg != null:
				args.append(arg)
				
		update_stack.append({
			call = update_func,
			args = args,
		})
		pass
	pass
	
	
func _update(dt):
	update()

func update():
	var updated_cache = {}
	update_stage = true
	var i = 0

	while (i < update_stack.size()):
		var v = update_stack[i]
		var call = v.call
		if !updated_cache.has(call):
			var args = v.args
			call.callv(args)
			updated_cache[call] = true
		i += 1
		pass
	update_stack.clear()
	update_stage = false
	pass
	

