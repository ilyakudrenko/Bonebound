extends "res://scripts/thrown_body_part.gd"

const ARM_FLYING_SIZE := Vector2(12, 5)
const ARM_DROPPED_SIZE := Vector2(6, 18)
const LEG_DROPPED_SIZE := Vector2(6, 16)
const HEAD_DROPPED_SIZE := Vector2(12, 12)
const DEFAULT_PART_SIZE := Vector2(9, 6)


func setup(
	new_direction: Vector2,
	new_color: Color,
	new_damage: int,
	new_body_part_type: String,
	new_carried_item_type: String = "",
	new_body_part_id: String = "",
	new_throw_owner: Node2D = null,
	new_carried_item_rarity: String = ItemDatabase.RARITY_COMMON
) -> void:
	super.setup(new_direction, new_color, new_damage, new_body_part_type, new_carried_item_type, new_body_part_id, new_throw_owner, new_carried_item_rarity)
	refresh_part_metadata()

	if new_body_part_type.ends_with("_arm"):
		set_part_size(ARM_FLYING_SIZE)
	else:
		set_part_size(DEFAULT_PART_SIZE)

	visual.color = part_color


func setup_dropped(
	new_color: Color,
	new_body_part_type: String,
	new_carried_item_type: String = "",
	new_body_part_id: String = "",
	new_carried_item_rarity: String = ItemDatabase.RARITY_COMMON
) -> void:
	super.setup_dropped(new_color, new_body_part_type, new_carried_item_type, new_body_part_id, new_carried_item_rarity)
	refresh_part_metadata()

	if new_body_part_type.ends_with("_arm"):
		set_part_size(ARM_DROPPED_SIZE)
	elif new_body_part_type == BodyPartDatabase.BODY_PART_GENERIC_LEG:
		set_part_size(LEG_DROPPED_SIZE)
	elif new_body_part_type == BodyPartDatabase.BODY_PART_HEAD:
		set_part_size(HEAD_DROPPED_SIZE)
	else:
		set_part_size(DEFAULT_PART_SIZE)


func refresh_part_metadata() -> void:
	set_meta("body_part_type", body_part_type)
	set_meta("body_part_id", body_part_id)
	set_meta("carried_item_type", carried_item_type)
	set_meta("carried_item_rarity", carried_item_rarity)


func set_part_size(new_size: Vector2) -> void:
	visual.offset_left = -new_size.x * 0.5
	visual.offset_top = -new_size.y * 0.5
	visual.offset_right = new_size.x * 0.5
	visual.offset_bottom = new_size.y * 0.5

	var collision_shape := $CollisionShape2D
	var rectangle_shape := collision_shape.shape as RectangleShape2D
	rectangle_shape.size = new_size
