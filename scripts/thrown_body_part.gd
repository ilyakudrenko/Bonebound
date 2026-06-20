extends Area2D

const THROW_HORIZONTAL_SPEED := 520.0
const THROW_UPWARD_SPEED := 180.0
const THROW_GRAVITY := 700.0
const LIFETIME := 1.5
const FALL_GRAVITY := 900.0
const MAX_FALL_SPEED := 600.0
const PICKUP_DELAY := 0.35
const THROWN_ARM_STUN_DURATION := 1.1
const TERRAIN_COLLISION_MASK := 1
const FLYING_STATE := "flying"
const DROPPED_STATE := "dropped"

var direction := Vector2.RIGHT
var flight_velocity := Vector2.ZERO
var damage := 1
var lifetime_left := LIFETIME
var part_color := Color(1, 0.05, 0.05, 1)
var body_part_type := ""
var body_part_id := ""
var carried_item_type := ""
var is_recoverable := true
var state := FLYING_STATE
var fall_speed := 0.0
var drift_velocity := Vector2.ZERO
var is_on_ground := false
var pickup_delay_left := 0.0
var last_terrain_hit_normal := Vector2.ZERO

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	set_meta("body_part_type", body_part_type)
	set_meta("body_part_id", body_part_id)
	set_meta("carried_item_type", carried_item_type)
	if state == DROPPED_STATE:
		visual.color = part_color.darkened(0.25)
	else:
		visual.color = part_color
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if pickup_delay_left > 0.0:
		pickup_delay_left -= delta

	if state == FLYING_STATE:
		flight_velocity.y += THROW_GRAVITY * delta
		var next_position := global_position + flight_velocity * delta

		if move_until_terrain_hit(next_position):
			var hit_normal := last_terrain_hit_normal
			drop_body_part()
			if hit_normal.y < -0.5:
				land_body_part()
			return

		rotation = flight_velocity.angle()
		lifetime_left -= delta

		if lifetime_left <= 0.0:
			drop_body_part()
	elif state == DROPPED_STATE and not is_on_ground:
		fall_speed = minf(fall_speed + FALL_GRAVITY * delta, MAX_FALL_SPEED)
		var next_position := global_position + Vector2(drift_velocity.x, fall_speed) * delta

		move_until_terrain_hit(next_position)


func setup(new_direction: Vector2, new_color: Color, new_damage: int, new_body_part_type: String, new_carried_item_type: String = "", new_body_part_id: String = "") -> void:
	direction = new_direction.normalized()
	flight_velocity = Vector2(direction.x * THROW_HORIZONTAL_SPEED, -THROW_UPWARD_SPEED)
	part_color = new_color
	damage = new_damage
	body_part_type = new_body_part_type
	carried_item_type = new_carried_item_type
	body_part_id = new_body_part_id


func setup_dropped(new_color: Color, new_body_part_type: String, new_carried_item_type: String = "", new_body_part_id: String = "") -> void:
	part_color = new_color
	body_part_type = new_body_part_type
	carried_item_type = new_carried_item_type
	body_part_id = new_body_part_id
	damage = 0
	is_recoverable = true
	drop_body_part()


func setup_death_piece(new_color: Color, new_size: Vector2, new_launch_velocity: Vector2) -> void:
	part_color = new_color
	damage = 0
	is_recoverable = false
	visual.offset_left = -new_size.x * 0.5
	visual.offset_top = -new_size.y * 0.5
	visual.offset_right = new_size.x * 0.5
	visual.offset_bottom = new_size.y * 0.5

	var collision_shape := $CollisionShape2D
	var rectangle_shape := collision_shape.shape as RectangleShape2D
	rectangle_shape.size = new_size
	drop_body_part()
	drift_velocity = new_launch_velocity
	fall_speed = new_launch_velocity.y


func _on_body_entered(body: Node) -> void:
	handle_collision(body)


func _on_area_entered(area: Area2D) -> void:
	handle_collision(area)


func handle_collision(other: Node) -> void:
	if state == FLYING_STATE:
		if other.has_method("recover_body_part"):
			return

		if other.has_method("take_damage"):
			other.call("take_damage", damage)
			if other.has_method("stun_for_duration"):
				other.call("stun_for_duration", THROWN_ARM_STUN_DURATION)
			elif other.has_method("stun"):
				other.call("stun")

			drop_body_part()
		elif is_solid_level_body(other):
			drop_body_part()
			land_body_part()
	elif state == DROPPED_STATE:
		if is_recoverable and pickup_delay_left <= 0.0 and other.has_method("recover_body_part") and other.call("recover_body_part", body_part_type, carried_item_type, body_part_id, part_color):
			queue_free()
		elif is_solid_level_body(other):
			land_body_part()


func drop_body_part() -> void:
	if state == DROPPED_STATE:
		return

	state = DROPPED_STATE
	drift_velocity = Vector2.ZERO
	fall_speed = 0.0
	is_on_ground = false
	pickup_delay_left = PICKUP_DELAY
	rotation = 0.0

	if visual != null:
		visual.color = part_color.darkened(0.25)


func land_body_part() -> void:
	fall_speed = 0.0
	is_on_ground = true


func move_until_terrain_hit(next_position: Vector2) -> bool:
	var hit := get_terrain_hit(global_position, next_position)

	if hit.is_empty():
		last_terrain_hit_normal = Vector2.ZERO
		global_position = next_position
		return false

	var hit_position := hit["position"] as Vector2
	var hit_normal := hit["normal"] as Vector2

	last_terrain_hit_normal = hit_normal
	global_position = hit_position + hit_normal * get_collision_half_extent(hit_normal)

	if hit_normal.y < -0.5:
		land_body_part()

	return true


func get_terrain_hit(from_position: Vector2, to_position: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(from_position, to_position)

	query.collision_mask = TERRAIN_COLLISION_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [self]

	return get_world_2d().direct_space_state.intersect_ray(query)


func get_collision_half_extent(hit_normal: Vector2) -> float:
	var collision_shape := $CollisionShape2D
	var rectangle_shape := collision_shape.shape as RectangleShape2D

	if rectangle_shape == null:
		return 1.0

	if absf(hit_normal.x) > absf(hit_normal.y):
		return rectangle_shape.size.x * 0.5

	return rectangle_shape.size.y * 0.5


func is_solid_level_body(other: Node) -> bool:
	return other is StaticBody2D or other is TileMap
