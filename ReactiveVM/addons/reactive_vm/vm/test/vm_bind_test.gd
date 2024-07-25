extends "res://addons/reactive_vm/vm/test/base/vm_test_base.gd"


func _ready():
	super._ready()

	call_test("test_label")
	call_test("test_signal")
	call_test("test_user_signal")


func test_label():
	var label = Label.new()
	add_child(label)

	var data = {
		"name": "Hello World",
	}

	var vm_data = vm_mgr.reactive.reactive(data)

	var bind = vm_mgr.bind.bind(label, "text", vm_data, "name")

	equal(label.text, "Hello World")

	vm_data.name = "AAAAA"
	vm_data.name = "CCCCCCC"
	vm_data.name = 'Test!!!'
	vm_mgr.update.update()
	equal(label.text, "Test!!!")
	
	label.queue_free()
	pass
	
func test_signal():
	var label = Label.new()
	add_child(label)
	
	var t = {
		num = 0
	}
	
	var cb1 = func():
		t.num += 1
	var cb2 = func():
		t.num += 2

	var data = {
		signal_cb = cb1,
	}

	var vm_data = vm_mgr.reactive.reactive(data)

	var bind = vm_mgr.bind.bind(label, "renamed", vm_data, "signal_cb")
	label.name = "HelloWorld1"
	equal(t.num, 1)
	label.name = "HelloWorld2"
	equal(t.num, 2)
	
	vm_data.signal_cb = cb2
	vm_mgr.update.update()
	label.name = "HelloWorld3"
	equal(t.num, 4)
	label.name = "HelloWorld4"
	equal(t.num, 6)
	
	label.queue_free()
	pass
	
func test_user_signal():
	var node = TestNode.new()
	add_child(node)
	
	var t = {
		num = 0
	}

	var cb1 = func():
		t.num += 1
	var cb2 = func():
		t.num += 2

	var data = {
		signal_cb = cb1,
	}

	var vm_data = vm_mgr.reactive.reactive(data)
	var bind = vm_mgr.bind.bind(node, "test_signal", vm_data, "signal_cb")
	node.test_signal.emit()
	equal(t.num, 1)
	node.test_signal.emit()
	equal(t.num, 2)
	
	vm_data.signal_cb = cb2
	vm_mgr.update.update()
	node.test_signal.emit()
	equal(t.num, 4)
	node.test_signal.emit()
	equal(t.num, 6)
	
	node.queue_free()
	
class TestNode extends Node:
	signal test_signal
