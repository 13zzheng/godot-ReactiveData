extends VMData
class_name VMDict

### return null to use normally get
var __getter: Callable
### return false to use normally set
var __setter: Callable

var __property_setter = {}
var __property_getter = {}

static func rget(proxy: VMDict, key: StringName):
	var target = proxy.target
	if target == null:
		return null
	return target[key]
	pass
	
static func rset(proxy: VMDict, key: StringName, value):
	var target = proxy.target
	if target == null:
		return false
	target[key] = value
	return true
	pass
	
static func define_property(proxy: VMDict, property: StringName, param = {}):
	if param.has(&"get"):
		proxy.__property_getter[property] = param[&"get"]
	if param.has(&"set"):
		proxy.__property_setter[property] = param[&"set"]


func _init(object, handler: Dictionary = {}):
	set_target(object)
	if handler.has(&'set'):
		__setter = handler.get(&'set')
	if handler.has(&'get'):
		__getter = handler.get(&'get')
	pass


func get_value(key: StringName):
	return self[key]


func _set(property, value: Variant) -> bool:
	if target == null:
		return false
	if __property_setter.has(property):
		return __property_setter[property].call(property, value, self)
	var result
	if __setter:
		result = __setter.call(property, value, self)
	else:
		target[property] = value
		result = true
	return result
	pass
	
func _get(property) -> Variant:
	#prints("_get", property)
	if target == null:
		return null
	#Log.info("_get", property);
	if __property_getter.has(property):
		return __property_getter[property].call(property, self)
	var result
	if __getter:
		result = __getter.call(property, self)
	else:
		result = target[property]
	return result
	pass
	
func _to_string():
	return "<VMDict>: " + var_to_str(target)
	pass
