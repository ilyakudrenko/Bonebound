extends Label

const FLOAT_DISTANCE := 28.0
const LIFETIME := 0.65


func setup(amount: int) -> void:
	text = str(amount)


func _ready() -> void:
	pivot_offset = size * 0.5

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position:y", global_position.y - FLOAT_DISTANCE, LIFETIME)
	tween.tween_property(self, "modulate:a", 0.0, LIFETIME)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
