class_name GrabbableObject extends Area2D

@onready var sprite: Sprite2D = %Sprite
@onready var shadow_sprite: Sprite2D = %ShadowSprite

const TRASH_SPRITES = preload("uid://cs5uqyjinp2l1")
const TRASH_BAG = preload("uid://dyatiwg2jcp8")
const TRASH_SHADOWS = preload("uid://cpqcyukv2cqvu")
const TRASH_BAG_SHADOW = preload("uid://6lqbxc8wyrjp")
const DUMPSTER = preload("uid://cpbywcmuy45am")
const COCONUT_VENDING_MACHINE = preload("uid://7ovlb1b2fx1f")

@export var trash_points: int = 0
@export var dumpster: bool = false
@export var coconut: bool = false
@export var trash_bag: bool = false
@export var coconut_shop: bool = false

var velocity: Vector2 = Vector2.ZERO
@export var friction: float = 0.9

signal grab_object(obj)

func _ready() -> void:
	if dumpster:
		sprite.texture = DUMPSTER
	if trash_bag:
		sprite.texture = TRASH_BAG
		shadow_sprite.texture = TRASH_BAG_SHADOW
	if coconut_shop:
		sprite.texture = COCONUT_VENDING_MACHINE

func _physics_process(delta):
	if velocity.length() > 0.1:
		global_position += velocity * delta
		velocity *= friction  # slows it down over time

func set_coconut() -> void:
	sprite_setup()
	coconut = true
	# Rect2(position_x, position_y, size_width, size_height)
	sprite.region_rect = Rect2(0, 0, 16, 16)
	shadow_sprite.region_rect = Rect2(0, 0, 16, 16)

func set_trash() -> void:
	sprite_setup()
	trash_points = 5
	var i = randi_range(1,3)
	
	match i: # Can add trash points into it if I want it to be different per trash
		1:
			# Rect2(position_x, position_y, size_width, size_height)
			sprite.region_rect = Rect2(16, 0, 16, 16)
			shadow_sprite.region_rect = Rect2(16, 0, 16, 16)
		2:
			# Rect2(position_x, position_y, size_width, size_height)
			sprite.region_rect = Rect2(0, 16, 16, 16)
			shadow_sprite.region_rect = Rect2(0, 16, 16, 16)
		_:
			# Rect2(position_x, position_y, size_width, size_height)
			sprite.region_rect = Rect2(16, 16, 16, 16)
			shadow_sprite.region_rect = Rect2(16, 16, 16, 16)

func sprite_setup() -> void:
	sprite.texture = TRASH_SPRITES
	sprite.region_enabled = true
	shadow_sprite.texture = TRASH_SHADOWS
	shadow_sprite.region_enabled = true
