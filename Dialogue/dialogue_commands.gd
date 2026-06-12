class_name DialogueCommands extends Node

# Regular expression to find {p=%d} tags
const PAUSE_PATTERN := "({p=\\d([.]\\d+)?[}])"

# Additional cleanup patterns
const BBCODE_I_PATTERN := "\\[(?!\\/)(.*?)\\]"
const BBCODE_E_PATTERN := "\\[\\/(.*?)\\]"

# Not that we are defining here that all of our custom tags will be defined as {%s}, so
# we use this global pattern to match all of them.
const CUSTOM_TAG_PATTERN := "({(.*?)})"

# List of pauses found for the last parsed string
var _pauses := []

# Pause Regex
var _pause_regex := RegEx.new()

# Auxiliary Regexes
var _bbcode_i_regex := RegEx.new()
var _bbcode_e_regex := RegEx.new()
var _custom_tag_regex := RegEx.new()

signal pause_requested(duration)

func _ready() -> void:
	# Tags
	_pause_regex.compile(PAUSE_PATTERN)

	# Auxiliary
	_bbcode_i_regex.compile(BBCODE_I_PATTERN)
	_bbcode_e_regex.compile(BBCODE_E_PATTERN)
	_custom_tag_regex.compile(CUSTOM_TAG_PATTERN)

func extract_pauses_from_string(source_string: String) -> String:
	_pauses = []
	var dialogue_string = source_string
	_find_pauses(dialogue_string)
	return _extract_tags(dialogue_string)

func check_at_position(pos: int) -> void:
	for _pause in _pauses:
		if _pause.pause_pos == pos:
			emit_signal("pause_requested", _pause.duration)

func _find_pauses(source: String) -> void:
	print("Finding pauses")
	_pauses = []
	
	var index := 0
	var visible_index := 0
	
	while index < source.length():
		if source[index] == '{':
			var end_index := source.find('}', index)
			if end_index != -1:
				var tag := source.substr(index, end_index - index + 1)
				if tag.begins_with("{p="):
					var _value := tag.substr(3, tag.length() - 4).to_float()
					_pauses.append(Pause.new(visible_index, tag))
				index = end_index + 1
				continue
		elif source[index] == '[':
			var end_index := source.find(']', index)
			if end_index != -1:
				# Skip BBCode tag
				index = end_index + 1
				continue
		
		# Count as visible character
		visible_index += 1
		index += 1

# Removes all custom tags from the string
func _extract_tags(from_string: String) -> String:
	return _custom_tag_regex.sub(from_string, "", true)
