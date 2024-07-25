extends MarginContainer


var vm_binder: VMBinder : set = set_vm_binder

var configs: Array[VMBinderNodeConfig] = []


func _ready():
	pass # Replace with function body.
	
func set_vm_binder(binder):
	vm_binder = binder
	configs = vm_binder.node_binders
	
	
func add_config(prop: String, key_path: String):
	var cfg = new_config()
	cfg.node_prop = prop
	cfg.node_prop = key_path
	
	configs.append(cfg)
	pass
	
func new_config():
	var cfg = VMBinderNodeConfig.new()
	return cfg
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
