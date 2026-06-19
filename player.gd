class_name Player extends CharacterBody2D 

const GRABBABLE_OBJECT = preload("uid://co54mxkglvavc")
const DUMPSTER_MAN = preload("uid://c4kp3dg10nc8k")

@onready var sprite: AnimatedSprite2D = %Sprite

@onready var interaction_timer: Timer = %InteractionTimer
@onready var interaction_progress_bar: ProgressBar = %InteractionProgressBar

@export var throw_distance: float = 200.0   # how far below player
@export var throw_spread: float = 160.0      # horizontal randomness
@export var throw_force: float = 400.0      # speed of throw
@export var speed: float
var prev_direction: int
var input_vector: Vector2

var grab_obj_list: Array[GrabbableObject] = []
var interacting: bool = false
var cur_grab_obj: GrabbableObject = null
var interaction_time: float = 1.0

var trash_bags_dumped: int = 0

var cur_door: CoconutDoor = null
var cur_man: DumpsterMan = null

var coconut_given: bool = false


func _ready() -> void:
	interaction_progress_bar.visible = false

func _physics_process(delta: float) -> void:
	if Global.dialogue_active:
		return
	_handle_movement()
	
	if Input.is_action_just_pressed("interact") and Global.current_tutorial_part == 1:
		if grab_obj_list.is_empty():
			print("No interactable object")
			return
		cur_grab_obj = grab_obj_list.front()
		
		if cur_grab_obj.dumpster:
			print("Throw trash out")
			if Global.current_tutorial_part == 1:
				if not Global.thrown_trash == 4:
					var new_obj: GrabbableObject = GRABBABLE_OBJECT.instantiate()
					get_parent().add_child(new_obj)
					new_obj.global_position = global_position
					new_obj.set_trash()
					new_obj.grab_object.connect(tutorial_trash_taken)
					throw_object(new_obj, global_position)
					Global.thrown_trash += 1
				
				elif Global.thrown_trash == 4:
					print("Throw man instead")
					var new_obj: DumpsterMan = DUMPSTER_MAN.instantiate()
					get_parent().add_child(new_obj)
					new_obj.global_position = global_position
					throw_object(new_obj, global_position, true)
					Global.current_tutorial_part = 2
			else:
				var new_obj: GrabbableObject = GRABBABLE_OBJECT.instantiate()
				get_parent().add_child(new_obj)
				new_obj.global_position = global_position
				new_obj.set_trash()
				new_obj.grab_object.connect(tutorial_trash_taken)
				throw_object(new_obj, global_position)
	
	if Input.is_action_just_pressed("interact") and Global.current_tutorial_part == 2 and cur_man:
		print("Open dialogue with dumpster man for tutorial")
		Global.core._request_dialogue(["AH! I was cleaning in there!", 
		"*He looks you up and down.*", 
		"Oh. One of those Bad Corp guys eh? Tired of you all dirtying up the beaches!", 
		"What’s that?" ,
		"You’re only doing it because of the benefits?", 
		"You don’t really want to dirty the beach?", 
		"Well why didn’t you say so! I’m part of Good Group!", 
		"You should join and fight Bad Corp, like a man on the inside!", 
		"We have great benefits! Like free cookies~!", 
		"Alright I’ll leave these trash bags here.", 
		"If you decide you want to clean the beach, just press E on them.", 
		"Walk over to some trash, hold E to pick up the trash.", 
		"Then throw the trash bag in the dumpster by pressing E again.", 
		"Simple! If you pick up all the trash you threw out then consider yourself in!", 
		"Bye now!"], 
		"Man")
		Global.cur_man = cur_man
		Global.current_tutorial_part = 3
	
	if Input.is_action_just_pressed("interact") and interacting == false and (Global.current_tutorial_part == 3 or Global.current_tutorial_part == 4):
		print("We made it to here")
		if grab_obj_list.is_empty():
			print("No interactable object")
			return
		
		if not grab_obj_list.is_empty():
			# Always target coconuts first
			for grab_obj in grab_obj_list:
				if grab_obj.coconut:
					var temp = grab_obj
					grab_obj_list.erase(grab_obj)
					grab_obj_list.push_front(temp)
			
			cur_grab_obj = grab_obj_list.front()
		
		if not cur_grab_obj:
			return
		# If Dumpster
		if cur_grab_obj.dumpster:
			if Global.holding_trash_bag:
				Global.holding_trash_bag = false
				trash_bags_dumped += 1
				Global.cur_trash_count = 0
				print("Dumped tutorial trash bag.")
				print("Bags dumped: " + str(trash_bags_dumped))
				Global.core._request_dialogue(["*You hear muffled shuffling as you drop the bag in*", 
				"Wow great job cleaning up. Never seen a beach so sandy and so not trashy!", 
				"Here take this as your first benefit!", 
				"*A coconut gets thrown out of the dumpster*", 
				"Sorry we ran out of cookies. But this is just as good!", 
				"Now, there are more beaches to clean! Go beat Bad Corp into the sand!"], 
				"Man")
				var new_obj: GrabbableObject = GRABBABLE_OBJECT.instantiate()
				get_parent().add_child(new_obj)
				new_obj.global_position = global_position
				new_obj.set_coconut()
				throw_object(new_obj, global_position)
				Global.current_tutorial_part = 5
				Global.core.start_random_timer()
				
		# If Trash Bag
		elif cur_grab_obj.trash_bag:
			if not Global.holding_trash_bag:
				Global.holding_trash_bag = true
				Global.cur_trash_count = 0
				print("Picked up a trashbag")
			else:
				print("Already holding a trash bag. Take it to the dumpster first.")
		else:
			if Global.holding_trash_bag or cur_grab_obj.coconut:
				interacting = true
				print("Begun interacting with " + str(cur_grab_obj))
				interaction_timer.start(interaction_time - (0.1 * Global.interact_level))
				interaction_progress_bar.max_value = (interaction_time - (0.1 * Global.interact_level)) * 100
				interaction_progress_bar.visible = true
			else:
				print("Not holding trash bag")
	
	if Input.is_action_just_pressed("interact") and interacting == false and Global.current_tutorial_part >= 5:
		if cur_door:
			print("Open door")
			
			if Global.coconut_count > 0:
				cur_door.open_door()
		
		if grab_obj_list.is_empty():
			print("No interactable object")
			return
		
		
		if not grab_obj_list.is_empty():
			# Always target coconuts first
			for grab_obj in grab_obj_list:
				if grab_obj.coconut:
					var temp = grab_obj
					grab_obj_list.erase(grab_obj)
					grab_obj_list.push_front(temp)
			
			cur_grab_obj = grab_obj_list.front()
		
		if not cur_grab_obj:
			return
		# If Dumpster
		if cur_grab_obj.dumpster:
			if Global.holding_trash_bag:
				Global.holding_trash_bag = false
				trash_bags_dumped += 1
				Global.cur_trash_count = 0
				print("Dumped a trash bag.")
				print("Bags dumped: " + str(trash_bags_dumped))
				
		# If Trash Bag
		elif cur_grab_obj.trash_bag:
			if not Global.holding_trash_bag:
				Global.holding_trash_bag = true
				Global.cur_trash_count = 0
				print("Picked up a trashbag")
			else:
				print("Already holding a trash bag. Take it to the dumpster first.")
		elif cur_grab_obj.coconut_shop and not Global.dialogue_active and not Global.core.dialogue_cooldown and not coconut_given:
			coconut_given = true
			
			# First interaction (no coconut used)
			if not Progression.met_squirrel:
				Global.core._request_dialogue([
					"*The machine shakes and buzzes*", 
					"*You squint at it*", 
					"*There is faint writing that says 'insert coconut for cool thing'"
				], "Machine")
				Progression.met_squirrel = true
			
			# Can use coconut
			elif Global.coconut_count > 0 or Global.interact_level == 5:
				
				# Levels 0–3
				if Global.interact_level < 4:
					Global.core._request_dialogue([
						"*You shove a coconut into the machine's slot*",  
						"*The machine starts shaking violently and theres alot of screeching*", 
						"*The machine goes silent*", 
						"*A hastily scrawled note gets shoved back out of the slot*", 
						"It says: 'Cool reward'",
						"*You feel slightly angrier* (You pick up things faster now)"
					], "Machine")
					
					Global.interact_level += 1
					Global.coconut_count -= 1   # ✅ ONLY HERE
				
				# Level 4
				elif Global.interact_level == 4:
					Global.core._request_dialogue([
						"*You shove a coconut into the machine's slot*",  
						"*The machine starts shaking violently and theres alot of screeching*", 
						"*The machine goes silent*", 
						"*A hastily scrawled note gets shoved back out of the slot*", 
						"It says: 'omg I'm so full pls stop'"
					], "Machine")
					
					Global.interact_level += 1
					Global.coconut_count -= 1   # ✅ ONLY HERE
				
				# Level 5+
				else:
					Global.core._request_dialogue([
						"Theres a note taped to the front. It reads:",
						"'Please leave me alone I can't eat anymore'"
					], "Machine")
			
			# No coconuts
			else:
				Global.core._request_dialogue([
					"There seems to be a slot for coconuts."
				], "Machine")
			
			print("Open Shop")
			
			# Small delay recommended instead of instant reset
			await get_tree().create_timer(0.2).timeout
			coconut_given = false
		else:
			if Global.holding_trash_bag or cur_grab_obj.coconut:
				interacting = true
				print("Begun interacting with " + str(cur_grab_obj))
				interaction_timer.start(interaction_time - (0.1 * Global.interact_level))
				interaction_progress_bar.max_value = (interaction_time - (0.1 * Global.interact_level)) * 100
				interaction_progress_bar.visible = true
			else:
				print("Not holding trash bag")
	
	if Input.is_action_just_released("interact") and interacting == true:
		interacting = false
		if cur_grab_obj:
			stop_interacting()
	
	if not interaction_timer.is_stopped():
		interaction_progress_bar.value = ((interaction_time - (0.1 * Global.interact_level)) - interaction_timer.time_left) * 100
		
	
	_handle_movement_anims()
	
	move_and_slide()

func _handle_movement() -> void:
	input_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

	velocity = input_vector * speed
	
	velocity = velocity.limit_length(speed)


func _handle_movement_anims() -> void:
	if Global.holding_trash_bag:
		if input_vector.y < 0 :
			sprite.play("Walk_Up_Trashbag")
			prev_direction = 1
		elif input_vector.y > 0:
			sprite.play("Walk_Down_Trashbag")
			prev_direction = 2
		elif input_vector.x > 0:
			sprite.play("Walk_Down_Trashbag")
			prev_direction = 2
		elif input_vector.x < 0:
			sprite.play("Walk_Down_Trashbag")
			prev_direction = 2
		else:
			_play_idle_animation()
	else:
		if input_vector.y < 0:
			sprite.play("Walk_Up")
			prev_direction = 1
		elif input_vector.y > 0:
			sprite.play("Walk_Down")
			prev_direction = 2
		elif input_vector.x > 0:
			sprite.play("Walk_Down")
			prev_direction = 2
		elif input_vector.x < 0:
			sprite.play("Walk_Down")
			prev_direction = 2
		else:
			_play_idle_animation()

func _play_idle_animation() -> void:
	if Global.holding_trash_bag:
		match prev_direction:
			1: sprite.play("Idle_Up_Trashbag")
			2: sprite.play("Idle_Down_Trashbag")
			_: sprite.play("Idle_Down_Trashbag")
	else:
		match prev_direction:
			1: sprite.play("Idle_Up")
			2: sprite.play("Idle_Down")
			_: sprite.play("Idle_Down")

func stop_interacting() -> void:
	cur_grab_obj = null
	print("Stopped interacting")
	interaction_timer.stop()
	interaction_progress_bar.visible = false

func _on_interactable_area_entered(area: Area2D) -> void:
	if area is GrabbableObject:
		grab_obj_list.append(area)
	
	if area is CoconutDoor:
		cur_door = area
		print("Coconut door")
	
	if area is DumpsterMan:
		cur_man = area
		print("Dumpster Man")

func _on_interactable_area_exited(area: Area2D) -> void:
	if area is GrabbableObject:
		if grab_obj_list.has(area): # If is in the list of grabbable objects
			grab_obj_list.erase(area)
		if area == cur_grab_obj:
			stop_interacting()
	if area is CoconutDoor:
		cur_door = null
	if area is DumpsterMan:
		cur_man = null
	

func _on_interaction_timer_timeout() -> void:
	if not cur_grab_obj:
		print("Interaction timer went off but no grab object")
	print("Finished picking up")
	if cur_grab_obj.coconut:
		Global.coconut_count += 1
		print("Coconut count: " + str(Global.coconut_count))
		cur_grab_obj.grab_object.emit(cur_grab_obj)
		cur_grab_obj.queue_free()
		stop_interacting()
		return
	if Global.holding_trash_bag and (Global.cur_trash_count + cur_grab_obj.trash_points) <= Global.max_trash_count: 
		Global.cur_trash_count += cur_grab_obj.trash_points
		print("Trash Points: " + str(Global.cur_trash_count))
		cur_grab_obj.grab_object.emit(cur_grab_obj)
		cur_grab_obj.queue_free()
		if Global.cur_trash_count == Global.max_trash_count:
			print("Bag is now full")
	else:
		print("Too full to pick this up")
	
	
	stop_interacting()

func throw_object(obj: Area2D, player_pos: Vector2, man: bool = false, negative: bool = false):
	var target = get_random_throw_target(player_pos)
	if negative:
		target = -target
	var direction = (target - obj.global_position).normalized()
	var new_throw_force: float = 0
	if man:
		new_throw_force = (throw_force)
	else:
		new_throw_force = (throw_force + randf_range(100, 150))
	obj.velocity = direction * new_throw_force

func get_random_throw_target(player_pos: Vector2) -> Vector2:
	var random_x = randf_range(-throw_spread, throw_spread)
	return player_pos + Vector2(random_x, throw_distance)

func tutorial_trash_taken(yip) -> void:
	print("Tutorial Trash Taken")
	Global.tutorial_trash_collected += 1
	if Global.tutorial_trash_collected == 4:
		print("picked up all tutorial trash")
		Global.current_tutorial_part = 4
