@tool
extends Control


signal property_changed(text: String)


@onready var line_edit: LineEdit = $HBoxContainer/LineEdit


@export var property_name: StringName = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	line_edit.text_submitted.connect(test_input)
	pass # Replace with function body.

func test_input(new_text):
	prints("test_input", new_text)
	property_changed.emit(new_text)
	pass
