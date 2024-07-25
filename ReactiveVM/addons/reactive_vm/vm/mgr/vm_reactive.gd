extends VMSystemBase
class_name VMReactive

var vm_mgr: VMManager

func set_vm_mgr(mgr):
	vm_mgr = mgr
	pass

func reactive(data: Dictionary, computed: Dictionary = {}) -> VMDict:
	var d = _reactive(data)
	if computed.size() > 0:
		define_computed(d, computed)
	return d
	
func reactive_dict(data) -> VMDict:
	if not (data is Dictionary):
		return
	var property_dep = {}
	var proxy_dict = {}
	
	var proxy = VMDict.new(data, {
		&'get' : func(property: StringName, proxy: VMDict):
			if not property_dep.has(property):
				property_dep[property] = Dep.new()
			var dep = property_dep.get(property)
			if Dep.target:
				dep.depend()
			var result = VMDict.rget(proxy, property)
			if result is Dictionary or result is Array or result is Object:
				var p
				if not proxy_dict.has(result):
					p = _reactive(result)
					proxy_dict[result] = p
				else:
					p = proxy_dict[result]
				return p
			return result
			
			pass,
		&'set' : func(property: StringName, value, proxy: VMDict):
			var old_v = VMDict.rget(proxy, property)
			if value is VMData:
				value = value.target
			if old_v == value:
				return true
			
			var result = VMDict.rset(proxy, property, value)
			var dep: Dep = property_dep.get(property)
			if dep:
				dep.notify()
			return result
			pass
	})
	return proxy
	pass
	
func reactive_array(data) -> VMArray:
	if not (data is Array):
		return
	var property_dep = {}
	var proxy_dict = {}
	
	var proxy = VMArray.new(data, {
		&'get' : func(index: int, proxy: VMArray):
			if not property_dep.has(index):
				property_dep[index] = Dep.new()
			var dep = property_dep.get(index)
			if Dep.target:
				dep.depend()
			var result = VMArray.rget(proxy, index)
			if result is Dictionary or result is Array or result is Object:
				var p
				if not proxy_dict.has(result):
					p = _reactive(result)
					proxy_dict[result] = p
				else:
					p = proxy_dict[result]
				return p
			return result
			
			pass,
		&'set' : func(index: int, value, proxy: VMArray):
			var old_v = VMArray.rget(proxy, index)
			if old_v == value:
				return true
			
			var result = VMArray.rset(proxy, index, value)
			var dep: Dep = property_dep.get(index)
			if dep:
				dep.notify()
			return result
			pass
	})
	
	return proxy
	pass
	
func _reactive(data) -> VMData:
	if data is Dictionary:
		return reactive_dict(data)
	elif data is Array:
		return reactive_array(data)
	return data
	
func define_computed(proxy:VMDict, computed: Dictionary):
	for property in computed:
		var getter = computed[property]
		if typeof(getter) == TYPE_DICTIONARY:
			getter = getter[&"get"]
		if typeof(getter) != TYPE_CALLABLE:
			continue
		var computed_watchers = {}
		VMDict.define_property(proxy, property, {
			&"get" : func(property, proxy):
				if !computed_watchers.has(property):
					# New Computed Watcher
					var watcher = vm_mgr.watcher.watch_computed(proxy, getter)
					computed_watchers[property] = watcher
					pass
				var watcher = computed_watchers[property]
				if Dep.target:
					watcher.depend()
				if watcher.dirty:
					watcher.evaluate()
				return watcher.value
				pass,
			&"set" : func(property, value, proxy):
				return true
				pass
		})
			
	pass
	

