extends Label

const FLOAT_DISTANCE := 28.0
const LIFETIME := 0.65


func setup(amount: int, is_critical: bool = false) -> void:
	if is_critical:
		text = "CRIT " + str(amount)
		add_theme_color_override("font_color", Color(1.0, 0.35, 0.9, 1.0))
		add_theme_font_size_override("font_size", 18)
		return

	text = str(amount)


func _ready() -> void:
	pivot_offset = size * 0.5

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position:y", global_position.y - FLOAT_DISTANCE, LIFETIME)
	tween.tween_property(self, "modulate:a", 0.0, LIFETIME)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
