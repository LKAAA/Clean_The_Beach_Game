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
	
	if Global.current_tutorial_part == 3:
		Global.cur_man.queue_free()
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


func _on_start_timer_timeout() -> void:
	_request_dialogue(["*Bzzt*", 
	"Hey hey hey new hire!", 
	"Welcome to Bad Corp.", 
	"We here at Bad Corp{p=0.3}.{p=0.3}.{p=0.3}. ah whatever with this mumbo jumbo.", 
	"We hired you to dirty up the beach.", 
	"So that’s what you’re gonna do.", 
	"All you gotta do is go up to each dumpster you find, and press E on it.", 
	"That’s it.{p=0.5} Simple.{p=0.5} Don’t mess it up.", 
	"Now GET TO IT. Bzzt*"], 
	"Radio")
