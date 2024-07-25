extends RefCounted
class_name VMData

## VM数据对象


var target

func set_target(tar):
	target = tar



func get_path_value(path: StringName):
	var keys = path.split(".")
	var obj = self
	for key in keys:
		if obj is VMData:
			obj = obj.get_value(key)
		else:
			obj = obj[key]
	return obj

func get_value(key: StringName):
	printerr("get_value must be overridden")
	pass
