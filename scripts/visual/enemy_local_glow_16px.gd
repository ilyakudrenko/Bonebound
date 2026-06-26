extends Node2D

@export var glow_padding: Vector2 = Vector2(2, 2)
@export_range(0.0, 1.0, 0.01) var glow_alpha: float = 0.18
@export var glow_tint: Color = Color(0.85, 0.95, 1.0, 1.0)

var glow_pairs: Array[Dictionary] = []


func _ready() -> void:
	z_index = -1
	build_glow_parts()
	update_glow_parts()


func _process(_delta: float) -> void:
	update_glow_parts()


func build_glow_parts() -> void:
	glow_pairs.clear()

	for child in get_children():
		child.queue_free()

	var target_root := get_parent()
	if target_root == null:
		return

	for child in target_root.get_children():
		if child == self or not (child is ColorRect):
			continue

		var target := child as ColorRect
		var glow := ColorRect.new()
		glow.name = "%sGlow" % target.name
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(glow)
		glow_pairs.append({
			"target": target,
			"glow": glow,
		})


func update_glow_parts() -> void:
	for pair in glow_pairs:
		var target := pair["target"] as ColorRect
		var glow := pair["glow"] as ColorRect

		if target == null or glow == null or not is_instance_valid(target):
			continue

		glow.visible = target.visible
		glow.position = target.position
		glow.offset_left = target.offset_left - glow_padding.x
		glow.offset_top = target.offset_top - glow_padding.y
		glow.offset_right = target.offset_right + glow_padding.x
		glow.offset_bottom = target.offset_bottom + glow_padding.y
		glow.color = Color(
			target.color.r * glow_tint.r,
			target.color.g * glow_tint.g,
			target.color.b * glow_tint.b,
			glow_alpha
		)
