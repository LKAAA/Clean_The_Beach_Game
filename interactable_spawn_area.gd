extends Area2D

const GRABBABLE_OBJECT = preload("uid://co54mxkglvavc")

@export var region_name: String = "Region_Name"
var trash_complete: bool = false
var coconut_complete: bool = false

@onready var spawnable_area: CollisionShape2D = %SpawnableArea

@export var max_spawned_trash: int = 20
@export var max_spawned_coconuts: int = 5

var spawned_trash: Array = []
var spawned_coconuts: Array = []

func _ready() -> void:
	for i in max_spawned_trash:
		spawn_trash()
	for c in max_spawned_coconuts:
		spawn_coconut()

func _physics_process(_delta: float) -> void:
	if spawned_coconuts.is_empty() and not coconut_complete:
		print("Found all coconuts in the " + region_name + ".")
		coconut_complete = true
	
	if spawned_trash.is_empty() and not trash_complete:
		print("Found all trash in the " + region_name + ".")
		Global.max_trash_count += 10
		trash_complete = true
	
	if coconut_complete and trash_complete:
		print("The " + region_name + " is fully complete!")
		Global.completed_regions += 1
		Global.emit_signal("region_complete")
		queue_free()
	 


func spawn_coconut() -> void:
	var spawn_pos = get_valid_spawn_position(global_position, spawnable_area.shape.radius, 8, 15)
	var new_obj: GrabbableObject = GRABBABLE_OBJECT.instantiate()
	add_child(new_obj)
	new_obj.global_position = spawn_pos
	new_obj.set_coconut()
	new_obj.grab_object.connect(object_taken)
	spawned_coconuts.append(new_obj)


func spawn_trash() -> void:
	var spawn_pos = get_valid_spawn_position(global_position, spawnable_area.shape.radius, 8, 15)
	var new_obj: GrabbableObject = GRABBABLE_OBJECT.instantiate()
	add_child(new_obj)
	new_obj.global_position = spawn_pos
	new_obj.set_trash()
	new_obj.grab_object.connect(object_taken)
	spawned_trash.append(new_obj)

func get_random_point_in_circle(radius: float) -> Vector2:
	var angle := randf() * TAU
	var r := sqrt(randf()) * radius
	return Vector2(cos(angle), sin(angle)) * r

func is_position_valid(test_position: Vector2, check_radius: float) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = check_radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, test_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	
	return results.is_empty()

func get_valid_spawn_position(origin: Vector2, radius: float, check_radius: float, max_attempts: int = 10) -> Vector2:
	var last_position := origin
	
	for i in range(max_attempts):
		var offset = get_random_point_in_circle(radius)
		var test_position = origin + offset
		if is_position_valid(test_position, check_radius):
			return test_position
		last_position = test_position
	
	print("Forcing spawn after ", max_attempts, " attempts")
	return last_position

func object_taken(object: GrabbableObject) -> void:
	if object.coconut:
		spawned_coconuts.erase(object)
	else:
		spawned_trash.erase(object)
