extends RefCounted
class_name ListItem

var node: Node = null
var list: ListContainer = null
var idx: int = -1

func on_selected(selected: bool):
	if node.has_method('set_selected'):
		node.set_selected(selected)
	pass
	
func destory():
	if node:
		node.queue_free()
