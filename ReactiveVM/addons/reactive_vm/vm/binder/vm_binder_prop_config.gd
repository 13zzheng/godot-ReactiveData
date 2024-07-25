extends Resource
class_name VMBinderPropConfig

@export var node_prop: String
@export var data_path: String



func check_valid():
	if node_prop.is_empty() or data_path.is_empty():
		return false
	return true
