class_name GameUI extends Control

@onready var coconut_count: RichTextLabel = %CoconutCount
@onready var trash_capacity: RichTextLabel = %TrashCapacity
@onready var completion_percent: RichTextLabel = %CompletionPercent

var global_connected: bool = false

func _physics_process(delta: float) -> void:
	if not global_connected:
		Global.region_complete.connect(region_completion_update)
		global_connected = true
	
	update_ui()


func update_ui() -> void:
	coconut_count.text = "%d" % Global.coconut_count
	if Global.cur_trash_count == Global.max_trash_count:
		trash_capacity.text = "FULL"
	elif Global.holding_trash_bag:
		trash_capacity.text = "%d/%d" % [Global.cur_trash_count, Global.max_trash_count]
	else:
		trash_capacity.text = "NO BAG"
	
	if Global.all_regions_complete and not Global.cur_trash_count <= 0:
		completion_percent.text = "99%"
	elif Global.all_regions_complete:
		completion_percent.text = "100%"
		Global.game_complete = true

func region_completion_update() -> void:
	var percent := (float(Global.completed_regions) / float(Global.total_region_count)) * 100.0
	completion_percent.text = "%.0f%%" % round(percent)
	if Global.total_region_count == Global.completed_regions:
		Global.all_regions_complete = true
