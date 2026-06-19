extends Area2D

const GRABBABLE_OBJECT = preload("uid://co54mxkglvavc")

@export var region_name: String = "Region_Name"

@export var max_spawned_trash: int = 20
@export var max_spawned_coconuts: int = 5

@onready var spawnable_area: CollisionShape2D

var spawned_trash: Array[Node2D] = []
var spawned_coconuts: Array[Node2D] = []

var trash_complete := false
var coconut_complete := false
var region_complete := false

# Minimum spacing between spawned objects
const MIN_DISTANCE := 16.0

# ========================
# READY
# ========================
func _ready() -> void:
	spawnable_area = get_child(0)
	randomize()
	spawn_all()

func spawn_all() -> void:
	spawn_group(max_spawned_trash, false)
	spawn_group(max_spawned_coconuts, true)

# ========================
# SPAWNING
# ========================
func spawn_group(amount: int, is_coconut: bool) -> void:
	var spawned := 0
	var attempts := 0
	var max_attempts := amount * 10
	
	while spawned < amount and attempts < max_attempts:
		var pos = get_random_point_in_box()
		
		if is_position_valid(pos):
			var obj: GrabbableObject = GRABBABLE_OBJECT.instantiate()
			add_child(obj)
			obj.global_position = pos
			
			if is_coconut:
				obj.set_coconut()
				spawned_coconuts.append(obj)
			else:
				obj.set_trash()
				spawned_trash.append(obj)
			
			obj.grab_object.connect(object_taken)
			spawned += 1
		
		attempts += 1
	
	if spawned < amount:
		print("⚠ Could only spawn ", spawned, "/", amount, " in ", region_name)

# ========================
# POSITIONING
# ========================
func get_random_point_in_box() -> Vector2:
	var rect: RectangleShape2D = spawnable_area.shape
	var half_extents = rect.size / 2.0
	
	var local = Vector2(
		randf_range(-half_extents.x, half_extents.x),
		randf_range(-half_extents.y, half_extents.y)
	)
	
	return spawnable_area.global_transform * local

# ========================
# VALIDATION
# ========================
func is_position_valid(pos: Vector2) -> bool:
	# 1. Prevent overlap with our own spawned objects
	for obj in spawned_trash:
		if obj.global_position.distance_to(pos) < MIN_DISTANCE:
			return false
	
	for obj in spawned_coconuts:
		if obj.global_position.distance_to(pos) < MIN_DISTANCE:
			return false
	
	# 2. Physics check (optional but good)
	var space_state = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = MIN_DISTANCE / 2.0
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collide_with_areas = false   # 🔥 IMPORTANT
	query.collide_with_bodies = true
	
	var result = space_state.intersect_shape(query)
	return result.is_empty()

# ========================
# TRACKING
# ========================
func object_taken(object: GrabbableObject) -> void:
	if object.coconut:
		spawned_coconuts.erase(object)
	else:
		spawned_trash.erase(object)

# ========================
# PROGRESSION
# ========================
func _physics_process(_delta: float) -> void:
	if not coconut_complete and spawned_coconuts.is_empty():
		print("Found all coconuts in ", region_name)
		coconut_complete = true
	
	if not trash_complete and spawned_trash.is_empty():
		print("Found all trash in ", region_name)
		Global.max_trash_count += 10
		trash_complete = true
	
	if coconut_complete and trash_complete and not region_complete:
		region_complete = true
		print("Region complete:", region_name)
		Global.completed_regions += 1
		Global.emit_signal("region_complete")
		queue_free()
