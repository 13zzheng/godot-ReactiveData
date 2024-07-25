@tool
extends Control

signal drop_nodes(nodes)

func _can_drop_data(position, data):
	return data["type"] == "nodes"

func _drop_data(position, data):
	prints("_drop_data")
	print(data)
	var nodes = data["nodes"]
	if nodes.size() > 0:
		prints(nodes)
		drop_nodes.emit(nodes)
