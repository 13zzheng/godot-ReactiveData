extends VMData
class_name VMArray


static func rget(proxy: VMArray, index: int):
	var target = proxy.target
	if target == null:
		return null
	return target[index]
	pass
	
static func rset(proxy: VMArray, index: int, value):
	var target = proxy.target
	if target == null:
		return false
	target[index] = value
	return true
	pass


var setter: Callable
var getter: Callable
var array_changed: Callable

func _init(object, handler: Dictionary = {}):
	set_target(object)
	if handler.has(&"get"):
		getter = handler[&"get"]
	if handler.has(&"set"):
		setter = handler[&"set"]
	if handler.has(&"array_changed"):
		array_changed = handler[&"array_changed"]
	pass
	
func for_each(method: Callable):
	for i in range(target.size()):
		var v = target[i]
		method.call(v, i)
	pass
	
func geti(idx: int):
	var result
	if getter:
		result = getter.call(idx, self)
	else:
		result = target[idx]
	return result
	
func seti(idx: int, value):
	var result
	if setter:
		result = setter.call(idx, value, self)
	else:
		target[idx] = value
		result = true
	pass
	
func _set(property, value: Variant) -> bool:
	if target == null:
		return false
	var result
	if property.is_valid_int():
		seti(property.to_int(), value)
		result = true
	return result
	pass
	
func _get(property) -> Variant:
	#prints("_get", property)
	if target == null:
		return null
	var result = null
	if property.is_valid_int():
		result = geti(property.to_int())
	return result
	pass

func get_value(key: StringName):
		return geti(key.to_int())

func append(value):
	target.append(value)
	pass
	
func append_array(array):
	target.append_array(array)
	
func all(method: Callable):
	return target.all(method)
	pass
	
func any(method: Callable):
	return target.any(method)
	
func assign(array):
	target.assign(array)
	
func back():
	return target.back()
	
func size():
	return target.size()
	
func _to_string():
	return var_to_str(target)
