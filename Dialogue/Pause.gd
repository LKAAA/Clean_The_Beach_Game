class_name Pause extends RefCounted

var pause_pos: int
var duration: float

func _init(pos: int, tag: String):
	pause_pos = pos
	var val := tag.substr(3, tag.length() - 4)
	duration = val.to_float()
