extends VMSystemBase
class_name VMBind

## 负责处理VM属性绑定相关

var vm_mgr: VMManager

func set_vm_mgr(mgr):
	vm_mgr = mgr
	pass



## 绑定Node属性到VMData属性上 [br]
## [param target]: 节点 [br]
## [param prop]: 节点属性 [br]
## [param vm_data]: [VMData]对象 [br]
## [param key_path]: [VMData]对象的属性key [br]
func bind(target: Node, prop: NodePath, vm_data: VMData, key_path: NodePath) -> VMOnePropBind:
	var bind = create_bind(target, prop, vm_data, key_path)
	bind.bind_vm()
	return bind
	pass


#func bind_func(target: Node, prop: NodePath, update_func: Callable):
	#var bind = create_bind_with_func(target, prop, update_func)
	#bind.bind_vm()
	#return bind
	#pass


func create_bind(target: Node, prop: NodePath, vm_data: VMData, key_path: NodePath) -> VMOnePropBind:
	var bind = VMOnePropBind.new(vm_mgr)

	bind.target = target
	bind.prop = prop
	bind.vm_data = vm_data
	bind.key_path = key_path

	return bind
	pass

#func create_bind_with_func(target: Node, prop: NodePath, update_func: Callable) -> VMOnePropBind:
	#var bind = VMOnePropBind.new(vm_mgr)
#
	#bind.target = target
	#bind.prop = prop
	#bind.update_func = update_func
	#
	#return bind
	#pass
