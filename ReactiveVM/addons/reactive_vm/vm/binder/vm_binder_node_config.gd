extends Resource
class_name VMBinderNodeConfig


@export var prop_config_arr: Array[VMBinderPropConfig] = []


func add_prop_config(prop: String, data_path: String):
	var prop_cfg = VMBinderPropConfig.new()
	prop_cfg.node_prop = prop
	prop_cfg.data_path = data_path
	prop_config_arr.append(prop_cfg)
	pass
