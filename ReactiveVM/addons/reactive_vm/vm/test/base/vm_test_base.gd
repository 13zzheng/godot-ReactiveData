extends Node


var vm_mgr: VMManager

var test_num = 0
var failed_num = 0
var success_num = 0
var called_num = 0

var calling_method_name: String
var calling_failed = false


func _ready():
	vm_mgr = VMManager.new()
	add_child(vm_mgr)

func call_test(method_name: String):
	test_num = test_num + 1
	call_deferred("_call_one_test", method_name)
	
func _call_one_test(method_name: String):
	if called_num == 0:
		print()
		prints(name, "Start!")
	calling_method_name = method_name
	calling_failed = false
	call(method_name)
	called_num = called_num + 1
	if not calling_failed:
		_success(method_name)
	
	if called_num == test_num:
		prints(name, "Result:", "Total:", test_num, "Success:", success_num, "Failed:", failed_num)
	pass

func equal(value1, value2):
	if value1 != value2:
		_failed(calling_method_name)
	pass
	
func not_equal(value1, value2):
	if value1 == value2:
		_failed(calling_method_name)
	pass
	
func _success(method_name: String):
	success_num = success_num + 1
	prints(method_name, "Run Success!")
	pass
	
func _failed(method_name: String):
	failed_num = failed_num + 1
	calling_failed = true
	printerr(method_name + " Run Failed!")
	push_error(method_name + " Run Failed!")
	pass
