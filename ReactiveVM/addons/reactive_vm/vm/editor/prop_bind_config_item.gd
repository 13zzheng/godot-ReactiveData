@tool
extends MarginContainer



@onready var content = $VBox/Content
@onready var pro_tab = $VBox/PropTabItem

# Called when the node enters the scene tree for the first time.
func _ready():
	pro_tab.fold_changed.connect(_on_fold_changed)
	pro_tab.fold()
	pass # Replace with function body.


func _on_fold_changed(fold):
	if fold:
		set_content_visible(false)
	else:
		set_content_visible(true)
		
		
func set_content_visible(visible: bool):
	content.visible = visible
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
