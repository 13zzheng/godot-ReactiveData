extends "res://addons/reactive_vm/vm/test/base/vm_test_base.gd"


var register: VMRegister

func _ready():
	super._ready()
	register = vm_mgr.register
	call_test("test_regist_class")
	call_test("test_regist_update_object")
	return
	
func test_regist_class():
	var config = register.get_class_property_config("Node", "name")
	equal(config, null)
	var udpate_object_func = func(node, prop, value):
		node.set_indexed(prop, value)
		pass
	var update_data_func = func(vm, prop, value):
		vm.set_indexed(prop, value)
		pass
	register.reg_class("Node", "name", {
		update_object = udpate_object_func,
		update_data = update_data_func,
	})
	config = register.get_class_property_config("Node", "name")
	not_equal(config, null)
	equal(config.update_object, udpate_object_func)
	equal(config.update_data, update_data_func)
	pass
	
func test_regist_update_object():
	var udpate_object_func = func(node, prop, value):
		node.set_indexed(prop, value + "1")
		pass
	register.reg_class("Node", "name", {
		update_object = udpate_object_func
	})
	
	
	var node = Node.new()
	add_child(node)
	
	var data = {
		"name": "Hello World",
	}

	var vm_data = vm_mgr.reactive.reactive(data)
	var bind = vm_mgr.bind.bind(node, "name", vm_data, "name")

	equal(node.name, "Hello World1")

	vm_data.name = 'Test!!!'
	vm_mgr.update.update()
	equal(node.name, "Test!!!1")
	pass
