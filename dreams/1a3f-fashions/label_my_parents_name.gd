@tool

extends Label

var p : Node

func _ready() -> void:
	p = get_parent()
	p.renamed.connect(_refresh_text)
	_refresh_text()
func _refresh_text() -> void:
	text = p.name
