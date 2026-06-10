extends CharacterBody2D

@onready var interaction_timer: Timer = %InteractionTimer
@onready var interaction_progress_bar: ProgressBar = %InteractionProgressBar

@export var speed: float
var input_vector: Vector2

var grab_obj_list: Array[GrabbableObject] = []
var interacting: bool = false
var cur_grab_obj: GrabbableObject = null
var interaction_time: float = 1.0

var trash_bags_dumped: int = 0

func _ready() -> void:
	interaction_progress_bar.visible = false

func _physics_process(delta: float) -> void:
	_handle_movement()
	
	if Input.is_action_just_pressed("interact") and interacting == false:
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
					print("Now front")
			
			cur_grab_obj = grab_obj_list.front()
			print("Here")
		
		if not cur_grab_obj:
			print("No cur")
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
		elif cur_grab_obj.coconut_shop:
			if Global.interact_level != 9 and Global.coconut_count > 0:
				Global.interact_level += 1
				Global.coconut_count -= 1
			else:
				print("Interact level max")
			print("Open Shop")
		# If coconut or trash pick up
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
		
	
	#_handle_movement_anims()
	
	move_and_slide()

func _handle_movement() -> void:
	input_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

	velocity = input_vector * speed
	
	velocity = velocity.limit_length(speed)


#func _handle_movement_anims() -> void:
	#if input_vector.x > 0:
		#sprite.play("Walk_Right")
		#prev_direction = 3
	#elif input_vector.x < 0:
		#sprite.play("Walk_Left")
		#prev_direction = 4
	#elif input_vector.y < 0:
		#sprite.play("Walk_Up")
		#prev_direction = 1
	#elif input_vector.y > 0:
		#sprite.play("Walk_Down")
		#prev_direction = 2
	#else:
		#_play_idle_animation()
#
#func _play_idle_animation() -> void:
	#match prev_direction:
		#1: sprite.play("Idle_Up")
		#2: sprite.play("Idle_Down")
		#3: sprite.play("Idle_Right")
		#4: sprite.play("Idle_Left")
		#_: sprite.play("Idle_Down")

func stop_interacting() -> void:
	cur_grab_obj = null
	print("Stopped interacting")
	interaction_timer.stop()
	interaction_progress_bar.visible = false

func _on_interactable_area_entered(area: Area2D) -> void:
	if area is GrabbableObject:
		print("Is a grabble object")
		grab_obj_list.append(area)
	else:
		print("Area entered, idk what is")

func _on_interactable_area_exited(area: Area2D) -> void:
	if area is GrabbableObject:
		if grab_obj_list.has(area): # If is in the list of grabbable objects
			grab_obj_list.erase(area)
		if area == cur_grab_obj:
			stop_interacting()
	else:
		print("Area entered, idk what is")
	

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
	
