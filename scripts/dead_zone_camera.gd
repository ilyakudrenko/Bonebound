extends Camera2D

@export var target_path: NodePath
@export var target_offset := Vector2(0, -48)
@export var dead_zone_size := Vector2(320, 160)
@export var follow_speed := 3.25
@export var look_ahead_distance := 82.0
@export var look_ahead_speed := 3.0
@export var look_ahead_velocity_threshold := 8.0

var target: Node2D
var current_look_ahead_x := 0.0
var look_ahead_direction := 1
var has_right_position_limit: bool = false
var right_position_limit: float = 0.0


func _ready() -> void:
	target = get_node_or_null(target_path) as Node2D

	if target == null:
		return

	look_ahead_direction = get_target_facing_direction()
	current_look_ahead_x = get_desired_look_ahead_x()
	global_position = get_camera_target_position()


func _process(delta: float) -> void:
	if target == null:
		return

	update_look_ahead(delta)

	var target_position := get_camera_target_position()
	var half_zone := dead_zone_size * 0.5
	var desired_position := global_position
	var distance_from_camera := target_position - global_position

	if distance_from_camera.x > half_zone.x:
		desired_position.x = target_position.x - half_zone.x
	elif distance_from_camera.x < -half_zone.x:
		desired_position.x = target_position.x + half_zone.x

	if distance_from_camera.y > half_zone.y:
		desired_position.y = target_position.y - half_zone.y
	elif distance_from_camera.y < -half_zone.y:
		desired_position.y = target_position.y + half_zone.y

	var follow_amount := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(desired_position, follow_amount)

	if has_right_position_limit:
		global_position.x = minf(global_position.x, right_position_limit)


func get_camera_target_position() -> Vector2:
	return target.global_position + target_offset + Vector2(current_look_ahead_x, 0)


func update_look_ahead(delta: float) -> void:
	var target_velocity_x := get_target_velocity_x()
	if absf(target_velocity_x) > look_ahead_velocity_threshold:
		look_ahead_direction = get_axis_sign(target_velocity_x)
	else:
		look_ahead_direction = get_target_facing_direction()

	var desired_look_ahead_x := get_desired_look_ahead_x()
	var look_ahead_amount := 1.0 - exp(-look_ahead_speed * delta)
	current_look_ahead_x = lerpf(current_look_ahead_x, desired_look_ahead_x, look_ahead_amount)


func get_desired_look_ahead_x() -> float:
	return float(look_ahead_direction) * look_ahead_distance


func get_target_velocity_x() -> float:
	if target is CharacterBody2D:
		return (target as CharacterBody2D).velocity.x

	var velocity_value: Variant = target.get("velocity")
	if velocity_value is Vector2:
		return velocity_value.x

	return 0.0


func get_target_facing_direction() -> int:
	var facing_value: Variant = target.get("facing_direction")
	if facing_value == null:
		return look_ahead_direction

	var facing_sign := get_axis_sign(float(facing_value))
	if facing_sign == 0:
		return look_ahead_direction

	return facing_sign


func get_axis_sign(value: float) -> int:
	if value > 0.0:
		return 1
	if value < 0.0:
		return -1

	return 0


func set_right_position_limit(new_right_position_limit: float) -> void:
	if has_right_position_limit:
		right_position_limit = minf(right_position_limit, new_right_position_limit)
	else:
		right_position_limit = new_right_position_limit
		has_right_position_limit = true


func clear_right_position_limit() -> void:
	has_right_position_limit = false
