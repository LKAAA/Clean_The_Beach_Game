class_name DumpsterMan extends Area2D

var velocity: Vector2 = Vector2.ZERO
@export var friction: float = 0.9

func _physics_process(delta):
	if velocity.length() > 0.1:
		global_position += velocity * delta
		velocity *= friction  # slows it down over time
