extends "res://addons/reactive_vm/vm/test/base/vm_test_base.gd"





# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	call_test("test_dict_get_normal")
	call_test("test_dict_get_array")
	call_test("test_dict_get_dict")
	call_test("test_dict_set_normal")
	call_test("test_dict_set_dict")
	call_test("test_dict_set_array")
	call_test("test_watch_update")
	call_test("test_watch_update_path")
	call_test("test_watch_key")
	call_test("test_define_computed")
	call_test("test_computed_with_other_vm")
	call_test("test_computed_call_num")
	call_test("test_global")
	pass # Replace with function body.

# region test get

func test_dict_get_normal():
	var dict = {
		"a" : 1,
	}
	
	var vm = vm_mgr.reactive.reactive(dict)
	equal(dict.a, vm.a)
	equal(dict.a, vm.get("a"))

	
func test_dict_get_array():
	var dict = {
		a = [1, 3]
	}
	var vm = vm_mgr.reactive.reactive(dict)
	var array = dict.a
	var vm_array = vm.a
	for i in range(array.size()):
		equal(array[i], vm_array.geti(i))
		
func test_dict_get_dict():
	var dict = {
		a = {
			b = 3,
			c = 2,
		}
	}
	var vm = vm_mgr.reactive.reactive(dict)
	var d = dict.a
	var vm_d = vm.a
	for key in d.keys():
		equal(d[key], vm_d[key])
	pass

# endregion


# region test set
func test_dict_set_normal():
	var dict = {
		a = 1,
		b = 2,
	}
	var vm = vm_mgr.reactive.reactive(dict)
	vm.a = 4
	equal(dict.a, 4)
	pass

func test_dict_set_array():
	var dict = {
		a = [1, 3]
	}
	var vm = vm_mgr.reactive.reactive(dict)
	vm.a.seti(0, 4)
	equal(dict.a[0], 4)
	
	var test = [5, 6]
	vm.a = test
	for i in range(test.size()):
		equal(test[i], dict.a[i])
	pass

func test_dict_set_dict():
	var dict = {
		a = {
			b = 3,
			c = 2,
		}
	}

	var vm = vm_mgr.reactive.reactive(dict)
	vm.a.b = 4
	equal(dict.a.b, 4)

	var test = {
		b = 5,
		c = 6,
	}
	dict.a = test

	for key in test.keys():
		equal(test[key], dict.a[key])

	pass

# endregion

# region test watcher
func test_watch_update():
	var dict = {
		a = 1,
		b = 2,
	}

	var test = {
		t = 10,
	}

	var vm = vm_mgr.reactive.reactive(dict)
	vm_mgr.watcher.watch_update(vm, func(vm):
		test.t = test.t + vm.a
	)
	equal(test.t, 11)

	vm.a = 3
	vm_mgr.update.update()
	equal(test.t, 14)

	vm.a = 30
	vm.a = 1
	vm_mgr.update.update()
	equal(test.t, 15)
	pass

func test_watch_update_path():
	var dict = {
		a = 1,
		b = 2,
	}

	var test = {
		t = 11,
	}

	var vm = vm_mgr.reactive.reactive(dict)
	vm_mgr.watcher.watch_update(vm, func(vm):
		test.t = vm.b + vm.a
	, "a")
	equal(test.t, 11)
	
	vm.b = 11
	vm_mgr.update.update()
	equal(test.t, 11)

	vm.a = 3
	vm_mgr.update.update()
	equal(test.t, 14)

	vm.a = 30
	vm.a = 1
	vm_mgr.update.update()
	equal(test.t, 12)
	pass

func test_watch_key():
	var dict = {
		a = 1,
		b = 2,
		c = {
			c1 = 1,
			c2 = 2,
			c3 = [3,4,5],
		}
	}
	
	var t = {
		num = 0
	}

	var vm = vm_mgr.reactive.reactive(dict)
	vm_mgr.watcher.watch_key(vm, "a", func(vm, nv, ov):
		t.num += 1
		equal(ov, 1)
		equal(nv, 3)
	)

	vm.a = 30
	vm.a = 3
	vm_mgr.update.update()
	equal(t.num, 1)
	
	vm_mgr.watcher.watch_key(vm, "c:c1", func(vm, nv, ov):
		t.num += 1
		equal(ov, 1)
		equal(nv, 5)
	)
	vm.c.c1 = 5
	vm_mgr.update.update()
	equal(t.num, 2)
	
	vm_mgr.watcher.watch_key(vm, "c:c3:0", func(vm, nv, ov):
		t.num += 1
		equal(ov, 3)
		equal(nv, 11)
	)
	vm.set_indexed("c:c3:0", 11)
	vm_mgr.update.update()
	equal(t.num, 3)
	pass

# endregion


# region test computed

func test_define_computed():
	var dict = {
		a = 1,
		b = 2,
	}

	var computed = {
		c = func(vm):
			return vm.a + vm.b
	}

	var vm = vm_mgr.reactive.reactive(dict, computed)
	equal(vm.c, 3)

	vm.a = 5
	equal(vm.c, 7)

	vm.b = 10
	vm.b = 7
	equal(vm.c, 12)
	pass
	
func test_computed_with_other_vm():
	var dict1 = {
		a = 1,
		b = 2,
	}
	var dict2 = {
		c = 3,
		d = 4,
	}
	
	var vm2 = vm_mgr.reactive.reactive(dict2)
	
	var computed = {
		c = func(vm):
			return vm.a + vm.b + vm2.c
	}
	
	var vm1 = vm_mgr.reactive.reactive(dict1, computed)
	equal(vm1.c, 6)
	vm2.c = 5
	equal(vm1.c, 8)
	pass

func test_computed_call_num():
	var dict = {
		a = 1,
		b = 2,
	}

	var d = {
		call_num = 0
	}

	var computed = {
		c = func(vm):
			d.call_num = d.call_num + 1
			return vm.a + vm.b
	}

	var vm = vm_mgr.reactive.reactive(dict, computed)
	equal(d.call_num, 0)
	vm.c
	equal(d.call_num, 1)

	vm.a = 5
	equal(d.call_num, 1)
	vm.c
	equal(d.call_num, 2)

	vm.b = 10
	vm.b = 7
	equal(d.call_num, 2)
	vm.c
	equal(d.call_num, 3)
	pass

# endregion
	
	
# region test global

func test_global():
	var dict = {
		a = 1,
		b = 2,
	}
	var tag = "TestTag1"
	var vm = vm_mgr.reactive_data_global(tag, dict)
	equal(vm, vm_mgr.get_vm(tag))
	
	vm_mgr.global.remove_vm(tag)
	equal(vm_mgr.get_vm(tag), null)

# endregion
	
