extends Camera2D

@export var target_path: NodePath
@export var target_offset := Vector2(0, -48)
@export var dead_zone_size := Vector2(320, 160)
@export var follow_speed := 4.0

var target: Node2D


func _ready() -> void:
	target = get_node_or_null(target_path) as Node2D

	if target == null:
		return

	global_position = get_camera_target_position()


func _process(delta: float) -> void:
	if target == null:
		return

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


func get_camera_target_position() -> Vector2:
	return target.global_position + target_offset
