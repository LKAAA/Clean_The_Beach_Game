class_name Core extends Node2D

@onready var dialogue_manager: DialogueManager = %Dialogue_Manager
@onready var dialogue_cooldown_timer: Timer = %DialogueCooldownTimer
@onready var player: CharacterBody2D = %Player
@onready var random_timer: Timer = %RandomTimer

var dialogue_cooldown: bool = false

func _ready() -> void:
	Global.core = self

#region dialogue

func _request_dialogue(messages: Array[String], display_name: String) -> void:
	print("Requesting Dialogue")
	if not dialogue_cooldown:
		dialogue_manager.show_messages(messages, display_name)
		player.sprite.stop()

func _on_dialogue_manager_finished() -> void:
	dialogue_cooldown_timer.start(0.5)
	dialogue_cooldown = true
	
	if Global.current_tutorial_part == 3:
		Global.cur_man.queue_free()
	if Global.game_complete:
		get_tree().change_scene_to_file("res://end_screen.tscn")

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

func start_random_timer() -> void:
	random_timer.start(randi_range(30, 90))

func _on_random_timer_timeout() -> void:
	var d = randi_range(0, 2)
	
	match d:
		0:
			_request_dialogue(["Bzzt*{p=0.3} Workin’ hard?", 
				"I want that beach...{p=0.3} uh...{p=0.3} what’s the opposite of spick and span?", 
				"...", 
				"whatever...{p=0.3} I want it dirty!{p=0.3} Get to it!{p=0.3} Bzzt*"], 
				"Radio")
		1: 
			_request_dialogue(["Bzzt*{p=0.3} I know it’s your first day on the job and all...", 
				"BUT I DON'T SEE THAT BEACH GETTING DIRTIER.", 
				"GET TO IT.{p=0.3} Bzzt*"], 
				"Radio")
		2: 
			_request_dialogue(["Bzzt*{p=0.3} Ya know, it’s strange.", 
				"I feel like I’m seeing a lot less trash around here...", 
				"must be my imagination.{p=0.3} Bzzt*"], 
				"Radio")
	
	random_timer.start(randi_range(30, 90))
	
	
