extends AudioStreamPlayer
class_name RandomSoundPlayer

var _random_number_gen := RandomNumberGenerator.new()

func _ready() -> void:
	_random_number_gen.randomize()

func playSFX(sfx, _from_position := 0.0) -> void:
	pitch_scale = _random_number_gen.randf_range(0.9, 1.08)
	play(sfx)
