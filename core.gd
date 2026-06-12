class_name Core extends Node2D

@onready var dialogue_manager: DialogueManager = %Dialogue_Manager
@onready var dialogue_cooldown_timer: Timer = %DialogueCooldownTimer

var dialogue_cooldown: bool = false

func _ready() -> void:
	Global.core = self

#region dialogue

func _request_dialogue(messages: Array[String], display_name: String) -> void:
	print("Requesting Dialogue")
	if not dialogue_cooldown:
		dialogue_manager.show_messages(messages, display_name)

func _on_dialogue_manager_finished() -> void:
	dialogue_cooldown_timer.start(0.5)
	dialogue_cooldown = true
	pass

func _on_dialogue_manager_message_completed() -> void:
	#next_label.visible = false
	pass # Replace with function body.

func _on_dialogue_manager_message_requested() -> void:
	#next_label.visible = false
	pass # Replace with function body.

func _on_dialogue_cooldown_timer_timeout() -> void:
	dialogue_cooldown = false

#endregion
