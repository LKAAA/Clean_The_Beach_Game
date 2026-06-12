class_name DialogueManager extends Node

@onready var dialogue: Control = %Dialogue

signal message_requested()
signal message_completed()
signal finished()

var _messages := []
var cur_char: String
var _active_dialogue_offset := 0
var _is_active := false

func _ready() -> void:
	dialogue.message_completed.connect(_on_message_completed)

func show_messages(message_list: Array, char_name: String = "") -> void:
	# Only allow triggering if not currently showing something
	if _is_active:
		print("Dialogue is already active")
		return
	
	if message_list == []:
		print("No Dialogue to Choose")
		return
	
	_is_active = true
	Global.dialogue_active = true
	
	_messages = message_list
	cur_char = char_name
	_active_dialogue_offset = 0
	
	_show_current()

func _show_current() -> void:
	message_requested.emit()
	var message = _messages[_active_dialogue_offset]
	dialogue.update_message(message, cur_char)

func _input(event: InputEvent) -> void:
	if (event.is_pressed() and 
		!event.is_echo() and
		(event is InputEventKey or event is InputEventMouseButton) and 
		event.is_action_pressed("ui_dialogue_interact") and
		_is_active and
		dialogue.message_is_fully_visible()
	):
		if _active_dialogue_offset < _messages.size() - 1:
			_active_dialogue_offset += 1
			_show_current()
		else:
			_hide()
	elif(event.is_pressed() and 
		!event.is_echo() and
		(event is InputEventKey or event is InputEventMouseButton) and 
		event.is_action_pressed("ui_dialogue_interact") and
		_is_active and
		not dialogue.message_is_fully_visible()
	):
		dialogue.fast_forward_message()



func _hide() -> void:
	_is_active = false
	dialogue.visible = false
	Global.dialogue_active = false
	finished.emit()

func _on_message_completed() -> void:
	message_completed.emit()
