extends Control

@onready var type_timer: Timer = %TypeTimer
@onready var pause_timer: Timer = %PauseTimer
@onready var dialogue_commands: DialogueCommands = %DialogueCommands
@onready var random_sound_player: RandomSoundPlayer = %RandomSoundPlayer

@onready var character_name_section: HBoxContainer = %Character_Name_Section
@onready var name_text_label: RichTextLabel = %Name_Text_Label
@onready var dialogue_text_label: RichTextLabel = %Dialogue_Text_Label

var _playing_voice := false

signal message_completed()

func update_message(message: String, npc_name: String = "") -> void:
	self.visible = true
	
	dialogue_text_label.bbcode_text = dialogue_commands.extract_pauses_from_string(message)
	dialogue_text_label.visible_characters = 0
	
	print(npc_name)
	if not npc_name == "":
		character_name_section.visible = true
		name_text_label.bbcode_text = npc_name
	else:
		character_name_section.visible = false
	
	type_timer.start()
	
	_playing_voice = true
	random_sound_player.playSFX(0)


func _on_random_sound_player_finished() -> void:
	if _playing_voice:
		random_sound_player.playSFX(0)


func _on_type_timer_timeout() -> void:
	dialogue_commands.check_at_position(dialogue_text_label.visible_characters)
	if dialogue_text_label.visible_characters < dialogue_text_label.get_total_character_count():
		dialogue_text_label.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()
		message_completed.emit()

func fast_forward_message() -> void:
	dialogue_text_label.visible_characters = dialogue_text_label.get_total_character_count()
	_playing_voice = false
	type_timer.stop()
	message_completed.emit()

# Returns true if there are no pending characters to show
func message_is_fully_visible() -> bool:
	return dialogue_text_label.visible_characters >= dialogue_text_label.get_total_character_count() - 1



func _on_pause_timer_timeout() -> void:
	_playing_voice = true
	random_sound_player.playSFX(0)
	type_timer.start()


func _on_dialogue_commands_pause_requested(duration: Variant) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()
