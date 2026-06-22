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
const BOOMERANG_RETURN_SPEED := 430.0
const BOOMERANG_RETURN_DISTANCE := 12.0
const HARPOON_PULL_SPEED := 330.0
const HARPOON_PULL_DISTANCE := 28.0
const HARPOON_PULL_STUN_DURATION := 2.0
const HARPOON_FINISH_STUN_DURATION := 0.8
const FLYING_STATE := "flying"
const DROPPED_STATE := "dropped"
const RETURNING_STATE := "returning"
const HARPOON_PULLING_STATE := "harpoon_pulling"

var direction := Vector2.RIGHT
var flight_velocity := Vector2.ZERO
var damage := 1
var lifetime_left := LIFETIME
var part_color := Color(1, 0.05, 0.05, 1)
var body_part_type := ""
var body_part_id := ""
var carried_item_type := ""
var carried_item_rarity := ItemDatabase.RARITY_COMMON
var is_recoverable := true
var state := FLYING_STATE
var fall_speed := 0.0
var drift_velocity := Vector2.ZERO
var is_on_ground := false
var pickup_delay_left := 0.0
var last_terrain_hit_normal := Vector2.ZERO
var throw_owner: Node2D = null
var harpooned_enemy: Node2D = null
var harpoon_chain: Line2D = null
var hit_targets: Array = []

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	set_meta("body_part_type", body_part_type)
	set_meta("body_part_id", body_part_id)
	set_meta("carried_item_type", carried_item_type)
	set_meta("carried_item_rarity", carried_item_rarity)
	if state == DROPPED_STATE:
		visual.color = part_color.darkened(0.25)
	else:
		visual.color = part_color
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	update_harpoon_chain()

	if pickup_delay_left > 0.0:
		pickup_delay_left -= delta

	if state == FLYING_STATE:
		flight_velocity.y += THROW_GRAVITY * delta
		var next_position := global_position + flight_velocity * delta

		if move_until_terrain_hit(next_position):
			if is_returning_arm():
				start_returning()
				return

			var hit_normal := last_terrain_hit_normal
			drop_body_part()
			if hit_normal.y < -0.5:
				land_body_part()
			return

		rotation = flight_velocity.angle()
		lifetime_left -= delta

		if lifetime_left <= 0.0:
			if is_returning_arm():
				start_returning()
				return

			drop_body_part()
	elif state == RETURNING_STATE:
		update_boomerang_return(delta)
	elif state == HARPOON_PULLING_STATE:
		update_harpoon_pull(delta)
	elif state == DROPPED_STATE and not is_on_ground:
		fall_speed = minf(fall_speed + FALL_GRAVITY * delta, MAX_FALL_SPEED)
		var next_position := global_position + Vector2(drift_velocity.x, fall_speed) * delta

		move_until_terrain_hit(next_position)


func setup(new_direction: Vector2, new_color: Color, new_damage: int, new_body_part_type: String, new_carried_item_type: String = "", new_body_part_id: String = "", new_throw_owner: Node2D = null, new_carried_item_rarity: String = ItemDatabase.RARITY_COMMON) -> void:
	direction = new_direction.normalized()
	flight_velocity = Vector2(direction.x * THROW_HORIZONTAL_SPEED, -THROW_UPWARD_SPEED)
	part_color = new_color
	damage = new_damage
	body_part_type = new_body_part_type
	carried_item_type = new_carried_item_type
	carried_item_rarity = new_carried_item_rarity
	body_part_id = new_body_part_id
	throw_owner = new_throw_owner

	if is_harpoon_arm():
		ensure_harpoon_chain()


func _exit_tree() -> void:
	if harpoon_chain != null and is_instance_valid(harpoon_chain):
		harpoon_chain.queue_free()


func setup_dropped(new_color: Color, new_body_part_type: String, new_carried_item_type: String = "", new_body_part_id: String = "", new_carried_item_rarity: String = ItemDatabase.RARITY_COMMON) -> void:
	part_color = new_color
	body_part_type = new_body_part_type
	carried_item_type = new_carried_item_type
	carried_item_rarity = new_carried_item_rarity
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

		if other.has_method("take_damage") and not hit_targets.has(other):
			hit_targets.append(other)
			var target_health_before := get_target_health(other)
			other.call("take_damage", damage)
			if target_health_before > 0 and get_target_health(other) <= 0:
				notify_owner_body_part_kill()
			if other.has_method("stun_for_duration"):
				other.call("stun_for_duration", THROWN_ARM_STUN_DURATION)
			elif other.has_method("stun"):
				other.call("stun")

			if can_harpoon_target(other):
				start_harpoon_pull(other as Node2D)
			elif is_returning_arm():
				start_returning()
			else:
				drop_body_part()
		elif is_solid_level_body(other):
			if is_returning_arm():
				start_returning()
			else:
				drop_body_part()
				land_body_part()
	elif state == RETURNING_STATE:
		if other == throw_owner:
			return_to_owner()
	elif state == HARPOON_PULLING_STATE:
		if other == throw_owner:
			finish_harpoon_pull()
	elif state == DROPPED_STATE:
		if is_recoverable and pickup_delay_left <= 0.0 and other.has_method("recover_body_part") and other.call("recover_body_part", body_part_type, carried_item_type, body_part_id, part_color, carried_item_rarity):
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

	if harpoon_chain != null and is_instance_valid(harpoon_chain):
		harpoon_chain.queue_free()
		harpoon_chain = null


func start_returning() -> void:
	if state == RETURNING_STATE:
		return

	if throw_owner == null or not is_instance_valid(throw_owner):
		drop_body_part()
		return

	state = RETURNING_STATE
	flight_velocity = Vector2.ZERO
	fall_speed = 0.0
	drift_velocity = Vector2.ZERO
	rotation = 0.0

	if visual != null:
		visual.color = part_color


func start_harpoon_pull(enemy: Node2D) -> void:
	if throw_owner == null or not is_instance_valid(throw_owner):
		drop_body_part()
		return

	harpooned_enemy = enemy
	state = HARPOON_PULLING_STATE
	flight_velocity = Vector2.ZERO
	fall_speed = 0.0
	drift_velocity = Vector2.ZERO
	rotation = 0.0

	if harpooned_enemy.has_method("stun_for_duration"):
		harpooned_enemy.call("stun_for_duration", HARPOON_PULL_STUN_DURATION)
	elif harpooned_enemy.has_method("stun"):
		harpooned_enemy.call("stun")

	if visual != null:
		visual.color = part_color


func update_harpoon_pull(delta: float) -> void:
	if throw_owner == null or not is_instance_valid(throw_owner):
		drop_body_part()
		return

	if harpooned_enemy == null or not is_instance_valid(harpooned_enemy):
		start_returning()
		return

	var pull_target := throw_owner.global_position + Vector2(0, -24)
	var to_owner := pull_target - harpooned_enemy.global_position

	if to_owner.length() <= HARPOON_PULL_DISTANCE:
		finish_harpoon_pull()
		return

	var pull_step := to_owner.normalized() * HARPOON_PULL_SPEED * delta
	harpooned_enemy.global_position += pull_step
	global_position = harpooned_enemy.global_position
	rotation = to_owner.angle()


func finish_harpoon_pull() -> void:
	if harpooned_enemy != null and is_instance_valid(harpooned_enemy):
		if harpooned_enemy.has_method("stun_for_duration"):
			harpooned_enemy.call("stun_for_duration", HARPOON_FINISH_STUN_DURATION)
		elif harpooned_enemy.has_method("stun"):
			harpooned_enemy.call("stun")

	if throw_owner != null and is_instance_valid(throw_owner) and throw_owner.has_method("notify_hook_pull_success"):
		throw_owner.call("notify_hook_pull_success")

	harpooned_enemy = null
	return_to_owner()


func get_target_health(target: Node) -> int:
	if not target.is_in_group("enemies"):
		return 0

	var health_value: Variant = target.get("health")
	if health_value == null:
		return 0

	return int(health_value)


func notify_owner_body_part_kill() -> void:
	if throw_owner == null or not is_instance_valid(throw_owner):
		return
	if throw_owner.has_method("notify_challenge_body_part_enemy_killed"):
		throw_owner.call("notify_challenge_body_part_enemy_killed")


func update_boomerang_return(delta: float) -> void:
	if throw_owner == null or not is_instance_valid(throw_owner):
		drop_body_part()
		return

	var return_target := throw_owner.global_position + Vector2(0, -24)
	var to_owner := return_target - global_position

	if to_owner.length() <= BOOMERANG_RETURN_DISTANCE:
		return_to_owner()
		return

	global_position += to_owner.normalized() * BOOMERANG_RETURN_SPEED * delta
	rotation += 14.0 * delta


func return_to_owner() -> void:
	if throw_owner == null or not is_instance_valid(throw_owner):
		drop_body_part()
		return

	if throw_owner.has_method("recover_body_part") and throw_owner.call("recover_body_part", body_part_type, carried_item_type, body_part_id, part_color, carried_item_rarity):
		queue_free()
	else:
		drop_body_part()


func is_boomerang_arm() -> bool:
	return body_part_type.ends_with("_arm") and body_part_id.begins_with("boomerang_")


func is_harpoon_arm() -> bool:
	return body_part_type.ends_with("_arm") and body_part_id.begins_with("harpoon_")


func can_harpoon_target(other: Node) -> bool:
	return is_harpoon_arm() and (other is Node2D) and other.is_in_group("enemies")


func is_returning_arm() -> bool:
	return is_boomerang_arm() or is_harpoon_arm()


func ensure_harpoon_chain() -> void:
	if harpoon_chain != null and is_instance_valid(harpoon_chain):
		return

	harpoon_chain = Line2D.new()
	harpoon_chain.width = 2.0
	harpoon_chain.default_color = Color(0.55, 0.55, 0.62, 1)
	harpoon_chain.z_index = z_index - 1
	get_tree().current_scene.add_child(harpoon_chain)
	update_harpoon_chain()


func update_harpoon_chain() -> void:
	if not is_harpoon_arm():
		return
	if throw_owner == null or not is_instance_valid(throw_owner):
		return

	ensure_harpoon_chain()
	harpoon_chain.points = PackedVector2Array([
		throw_owner.global_position + Vector2(0, -24),
		global_position
	])


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
