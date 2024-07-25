@tool
extends Control

signal click


@onready var icon: TextureRect = $Margin/Control/Icon
@onready var label: Label = $Margin/Control/Label
@onready var btn_dle: Button = $Margin/Control/BtnDel
@onready var selected_panel: Panel = $PanelSelected

var delete_cb: Callable

var _hold_del: bool = false

var node: Node

func _ready():
	prints("node_item_ready")
	set_selected(false)
	if Engine.is_editor_hint():
		btn_dle.icon = EditorInterface.get_editor_theme().get_icon('close', "Window")
	btn_dle.pressed.connect(_on_del_pressed)
	btn_dle.mouse_exited.connect(_on_mouse_exit)
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	btn_dle.visible = false
	pass # Replace with function body.

func set_node(p_node: Node):
	node = p_node
	var cls_name = node.get_class()
	if Engine.is_editor_hint():
		var icon_tex = EditorInterface.get_editor_theme().get_icon(cls_name, "EditorIcons")
		icon.texture = icon_tex
	label.text = node.name
	pass
	
func set_selected(selected: bool):
	prints("set_selected", selected)
	if selected:
		selected_panel.visible = true
	else:
		selected_panel.visible = false
	pass
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_released():
			click.emit(self)
	
			
func _on_mouse_enter():
	btn_dle.visible = true
	pass
	
func _on_mouse_exit():
	prints("_on_mouse_exit", get_local_mouse_position())
	if !Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
		btn_dle.visible = false
	pass
	
func _on_del_pressed():
	delete_cb.call(self)
	pass
	

