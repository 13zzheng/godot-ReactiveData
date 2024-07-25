@tool
extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal pressed
signal hover_start
signal hover_end

var mouse_hover_time = 0.5
@export var full_parent = true
var _mouse_entered_time = 0
var _mouse_entered_flag = false
var _mouse_hover_flag = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = FOCUS_ALL
	pass # Replace with function body.
	
func _process(delta):
	if _mouse_entered_flag and not _mouse_hover_flag:
		_mouse_entered_time += delta
		if _mouse_entered_time >= mouse_hover_time:
			emit_signal("hover_start")
			_mouse_hover_flag = true
	
func resize_to_full():
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1
	
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	
	
func _enter_tree():
	if full_parent:
		resize_to_full()
		position = Vector2()
	pass
	
func _notification(what):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_mouse_entered_flag = true
			pass # Mouse entered the area of this control.
		NOTIFICATION_MOUSE_EXIT:
			_mouse_entered_flag = false
			_mouse_hover_flag = false
			_mouse_entered_time = 0
			pass # Mouse exited the area of this control.
		NOTIFICATION_FOCUS_ENTER:
			pass # Control gained focus.
		NOTIFICATION_FOCUS_EXIT:
			pass # Control lost focus.
		NOTIFICATION_THEME_CHANGED:
			pass # Theme used to draw the control changed;
			# update and redraw is recommended if using a theme.
		NOTIFICATION_VISIBILITY_CHANGED:
			pass # Control became visible/invisible;
			# check new status with is_visible().
		NOTIFICATION_RESIZED:
			pass # Control changed size; check new size
			# with get_size().
	
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			emit_signal("pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
