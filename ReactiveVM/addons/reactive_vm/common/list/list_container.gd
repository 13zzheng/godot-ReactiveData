@tool
extends ScrollContainer
class_name ListContainer

const TouchItem = preload("res://addons/reactive_vm/common/touch_node.gd")


signal on_item_click(list, item)
signal on_item_selected(list, item)

@export var content: Control = null
@export var enable_item_click: bool = false
@export var enable_item_select: bool = false

var list_items: Array[ListItem] = []
var cur_selected: int

func get_items() -> Array[ListItem]:
	return list_items
	pass
	
func get_item(idx: int) -> ListItem:
	var items = get_items()
	if idx >= items.size():
		return null
	return items[idx]
	
func get_item_node(idx: int) -> Node:
	return get_item(idx).node
	

#region 添加子项

func add_item(item: Node):
	var list_item = _new_list_item()
	list_item.node = item
	content.add_child(item)
	if enable_item_click:
		_add_list_item_touch(list_item)
	return list_item
	pass
	
#endregion
	
	
#region 移除子项
func remove(idx: int):
	var item = get_item(idx)
	if item:
		remove_item(item)
	pass
	
func remove_item(item: ListItem):
	_remove_list_item(item)
	
func remove_all():
	for item in get_items():
		item.destory()
	list_items.clear()
	pass
	
#endregion

func get_selected() -> ListItem:
	if cur_selected == -1:
		return null
	return get_items()[cur_selected]
	
func select(idx: int):
	var item = get_item(idx)
	select_item(item)
	
func select_item(p_item: ListItem):
	for item in get_items():
		if item == p_item:
			_on_item_select(item)
		else:
			_on_item_unselect(item)
			
func select_node(node: Node):
	var idx = -1
	for i in range(list_items.size()):
		var item = list_items[i]
		if item.node == node:
			idx = i
			break
	if idx == -1:
		return
	select(idx)
	pass
			
func _on_item_click(item: ListItem):
	if enable_item_select:
		for _item in get_items():
			if _item == item:
				_on_item_select(_item)
			else:
				_on_item_unselect(_item)
	
	on_item_click.emit(self, item)
	pass
	
func _on_item_select(item: ListItem):
	cur_selected = item.idx
	item.on_selected(true)
	on_item_selected.emit(self, item)
	pass
	
func _on_item_unselect(item: ListItem):
	item.on_selected(false)
	pass
	
#func _on_item_click(item: Node):
	#select_item(item)
	#pass
	
#region list_item 处理

func _new_list_item():
	var list_item = ListItem.new()
	list_items.append(list_item)
	list_item.list = self
	list_item.idx = list_items.size() - 1
	
	return list_item
	
func _remove_list_item(item: ListItem):
	item.destory()
	list_items.remove_at(item.idx)
	pass

func _add_list_item_touch(item: ListItem):
	var touch = TouchItem.new()
	touch.full_parent = true
	item.node.add_child(touch, false, Node.INTERNAL_MODE_FRONT)
	touch.pressed.connect(_on_item_click.bind(item))
	pass

#endregion
