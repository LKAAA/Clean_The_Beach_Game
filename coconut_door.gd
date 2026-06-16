class_name CoconutDoor extends Area2D

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

var door_opened: bool = false

func open_door() -> void:
	if not door_opened:
		print("Door opened")
		sprite.play("Open")
		collision_shape_2d.disabled = true
		door_opened = true
		Global.coconut_count -= 1
	else:
		print("Already open")

func close_door() -> void:
	sprite.play("Closed")
	collision_shape_2d.disabled = false
