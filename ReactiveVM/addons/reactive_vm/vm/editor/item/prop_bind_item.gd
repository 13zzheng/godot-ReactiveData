@tool
extends MarginContainer



var select_func: Callable
var prop_cfg: VMBinderPropConfig

@onready var edit_prop: LineEdit = $MarginContainer/HSplitContainer/EditProp
@onready var edit_key: LineEdit = $MarginContainer/HSplitContainer/EditDataKey

# Called when the node enters the scene tree for the first time.
func _ready():
	edit_prop.focus_entered.connect(_on_edit_focus_entered)
	edit_key.focus_entered.connect(_on_edit_focus_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_edit_focus_entered():
	if select_func:
		select_func.call()
	pass
