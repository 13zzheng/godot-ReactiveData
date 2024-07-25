@tool
extends PanelContainer


const highlight_stylebox = preload("res://addons/reactive_vm/vm/res/stylebox/highlight.tres")
const tab_stylebox = preload("res://addons/reactive_vm/vm/res/stylebox/tab.tres")

signal fold_changed(fold)

@export var fold_arrow: TextureRect = null

var is_fold = true

# Called when the node enters the scene tree for the first time.
func _ready():
	fold_arrow.texture = EditorInterface.get_editor_theme().get_icon("arrow_collapsed", "Tree")
	
	pass # Replace with function body.
	
	
func set_highlight(highlight: bool):
	var stylebox
	if highlight:
		
		add_theme_stylebox_override("panel", highlight_stylebox)
		pass
	else:
		add_theme_stylebox_override("panel", tab_stylebox)
		pass
	
func fold():
	set_fold(true)
	fold_changed.emit(is_fold)
	pass
	
func unfold():
	set_fold(false)
	fold_changed.emit(is_fold)
	pass
	
func set_fold(v: bool):
	if v:
		fold_arrow.texture = EditorInterface.get_editor_theme().get_icon("arrow_collapsed", "Tree")
	else:
		fold_arrow.texture = EditorInterface.get_editor_theme().get_icon("arrow", "Tree")
	is_fold = v
	pass
	
func switch_fold():
	if is_fold:
		unfold()
	else:
		fold()
	pass
	
func _gui_input(event):
	if event.is_pressed():
		switch_fold()
	
func _notification(what):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			set_highlight(true)
			pass # Mouse entered the area of this control.
		NOTIFICATION_MOUSE_EXIT:
			set_highlight(false)
			pass # Mouse exited the area of this control.
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
