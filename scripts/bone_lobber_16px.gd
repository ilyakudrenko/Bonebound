extends Area2D

const STARTING_HEALTH := 8
const NORMAL_COLOR := Color(0.48, 0.22, 0.34, 1)
const HIT_COLOR := Color(1, 0.85, 0.35, 1)
const WINDUP_COLOR := Color(1, 0.35, 0.12, 1)
const THROW_COLOR := Color(0.95, 0.72, 0.2, 1)
const STUN_COLOR := Color(0.25, 0.45, 1, 1)
const DETECTION_RANGE := 180.0
const VERTICAL_DETECTION_RANGE := 120.0
const ATTACK_WINDUP := 0.65
const THROW_DURATION := 0.12
const ATTACK_COOLDOWN := 1.3
const STUN_DURATION := 1.0
const PATROL_SPEED := 22.0
const MIN_PATROL_SPEED_MULTIPLIER := 0.9
const MAX_PATROL_SPEED_MULTIPLIER := 1.1
const DEFAULT_PATROL_DISTANCE := 88.0
const GRAVITY := 800.0
const MAX_FALL_SPEED := 600.0
const GROUND_RAY_START_OFFSET := 2.0
const GROUND_CHECK_DISTANCE := 8.0
const OBSTACLE_CHECK_DISTANCE := 14.0
const LEDGE_CHECK_DISTANCE := 12.0
const LEDGE_CHECK_DEPTH := 18.0
const BODY_COLLISION_MARGIN := 1.0
const BODY_CENTER_OFFSET := -22.0
const HORIZONTAL_BODY_CHECK_SHRINK := Vector2(2, 4)
const DAMAGE_NUMBER_OFFSET := Vector2(0, -50)
const THROW_SPAWN_OFFSET := Vector2(10, -34)
const PROJECTILE_GRAVITY := 520.0
const PROJECTILE_MIN_FLIGHT_TIME := 0.72
const PROJECTILE_MAX_FLIGHT_TIME := 1.18
const PROJECTILE_DISTANCE_TO_TIME := 135.0
const PLAYER_FLOOR_RAY_UP := 16.0
const PLAYER_FLOOR_RAY_DOWN := 72.0
const IDLE_STATE := "idle"
const WINDUP_STATE := "windup"
const THROW_STATE := "throw"
const COOLDOWN_STATE := "cooldown"
const STUNNED_STATE := "stunned"
const ENEMY_GROUP := "enemies"

const FLOATING_DAMAGE_NUMBER_SCENE := preload("res://scenes/ui/FloatingDamageNumber.tscn")
const ENEMY_CORPSE_SCENE := preload("res://scenes/ui/EnemyCorpse.tscn")
const BONE_BOMB_PROJECTILE_SCENE := preload("res://scenes/scaled/projectiles/BoneBombProjectile_16px.tscn")

@export var patrol_distance: float = DEFAULT_PATROL_DISTANCE
@export var use_patrol_limits := false
@export var vertical_detection_range: float = VERTICAL_DETECTION_RANGE

var health := STARTING_HEALTH
var state := IDLE_STATE
var state_time_left := 0.0
var patrol_direction := -1
var attack_direction := -1
var patrol_origin := Vector2.ZERO
var patrol_left_limit := 0.0
var patrol_right_limit := 0.0
var patrol_speed_multiplier := 1.0
var vertical_velocity := 0.0
var player: Node2D

@onready var body_visual: ColorRect = $Body
@onready var head_visual: ColorRect = $Head
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group(ENEMY_GROUP)
	setup_personal_patrol_limits()
	setup_spawn_variation()
	player = get_tree().current_scene.get_node_or_null("Player") as Node2D


func _physics_process(delta: float) -> void:
	if not update_ground_movement(delta):
		return

	if player == null:
		return

	state_time_left -= delta

	if state == IDLE_STATE:
		set_body_color(NORMAL_COLOR)
		if is_player_in_detection_range():
			start_windup()
		else:
			update_patrol(delta)
	elif state == WINDUP_STATE:
		if state_time_left <= 0.0:
			throw_projectile()
	elif state == THROW_STATE:
		if state_time_left <= 0.0:
			start_cooldown()
	elif state == COOLDOWN_STATE:
		if state_time_left <= 0.0:
			state = IDLE_STATE
	elif state == STUNNED_STATE:
		if state_time_left <= 0.0:
			state = IDLE_STATE


func take_damage(amount: int, is_critical: bool = false) -> void:
	health -= amount
	flash_hit()
	spawn_damage_number(amount, is_critical)

	if health <= 0:
		notify_player_enemy_killed()
		spawn_corpse()
		queue_free()
		return

	react_to_damage()


func react_to_damage() -> void:
	if player == null or state == STUNNED_STATE:
		return

	start_windup()


func flash_hit() -> void:
	set_body_color(HIT_COLOR)

	var tween := create_tween()
	tween.tween_method(Callable(self, "set_body_color"), HIT_COLOR, NORMAL_COLOR, 0.15)


func spawn_damage_number(amount: int, is_critical: bool = false) -> void:
	var damage_number := FLOATING_DAMAGE_NUMBER_SCENE.instantiate()

	damage_number.setup(amount, is_critical)
	get_tree().current_scene.add_child(damage_number)
	damage_number.global_position = global_position + DAMAGE_NUMBER_OFFSET


func spawn_corpse() -> void:
	var corpse := ENEMY_CORPSE_SCENE.instantiate()

	if corpse.has_method("setup_rewards"):
		corpse.call("setup_rewards", get_arm_reward_pool(), get_leg_reward_pool())

	corpse.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", corpse)


func notify_player_enemy_killed() -> void:
	if player != null and is_instance_valid(player) and player.has_method("notify_enemy_killed"):
		player.call("notify_enemy_killed")


func get_arm_reward_pool() -> Array:
	return BodyPartDatabase.BONE_LOBBER_ARM_REWARDS


func get_leg_reward_pool() -> Array:
	return BodyPartDatabase.BONE_LOBBER_LEG_REWARDS


func start_windup() -> void:
	state = WINDUP_STATE
	state_time_left = ATTACK_WINDUP
	attack_direction = get_direction_to_player()
	patrol_direction = attack_direction
	set_body_color(WINDUP_COLOR)


func throw_projectile() -> void:
	state = THROW_STATE
	state_time_left = THROW_DURATION
	set_body_color(THROW_COLOR)

	var projectile := BONE_BOMB_PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	var spawn_position := global_position + Vector2(THROW_SPAWN_OFFSET.x * attack_direction, THROW_SPAWN_OFFSET.y)
	var target_position := get_projectile_target_position()
	projectile.global_position = spawn_position

	if projectile.has_method("setup"):
		projectile.call("setup", get_projectile_velocity(spawn_position, target_position), self, target_position.y)


func start_cooldown() -> void:
	state = COOLDOWN_STATE
	state_time_left = ATTACK_COOLDOWN
	set_body_color(NORMAL_COLOR)


func stun() -> void:
	stun_for_duration(STUN_DURATION)


func stun_for_duration(duration: float) -> void:
	state = STUNNED_STATE
	state_time_left = duration
	set_body_color(STUN_COLOR)


func is_crowd_controlled() -> bool:
	return state == STUNNED_STATE


func update_patrol(delta: float) -> void:
	if should_turn_around():
		turn_around()

	var movement := patrol_direction * get_current_patrol_speed() * delta
	if can_move_horizontally(movement):
		global_position.x += movement
	else:
		turn_around()


func update_ground_movement(delta: float) -> bool:
	if is_ground_below():
		vertical_velocity = 0.0
		return true

	vertical_velocity = minf(vertical_velocity + GRAVITY * delta, MAX_FALL_SPEED)
	var fall_distance := vertical_velocity * delta
	var ground_position = get_ground_position_during_fall(fall_distance)

	if ground_position != null:
		var landing_position: Vector2 = ground_position as Vector2
		global_position.y = landing_position.y
		vertical_velocity = 0.0
		setup_personal_patrol_limits()
		return true

	global_position.y += fall_distance
	return false


func is_player_in_detection_range() -> bool:
	var horizontal_distance := absf(player.global_position.x - global_position.x)
	var vertical_distance := absf(player.global_position.y - global_position.y)
	var player_is_in_front := signf(player.global_position.x - global_position.x) == patrol_direction

	return horizontal_distance <= DETECTION_RANGE and vertical_distance <= vertical_detection_range and player_is_in_front


func has_clear_line_to_player() -> bool:
	var ray_start := global_position + Vector2(0, BODY_CENTER_OFFSET)
	var ray_end := player.global_position + Vector2(0, BODY_CENTER_OFFSET)
	var query := PhysicsRayQueryParameters2D.new()
	query.from = ray_start
	query.to = ray_end
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true

	var collider := result["collider"] as Node
	return collider == player


func is_ground_below() -> bool:
	var query := PhysicsRayQueryParameters2D.new()
	query.from = global_position + Vector2(0, -GROUND_RAY_START_OFFSET)
	query.to = global_position + Vector2(0, GROUND_CHECK_DISTANCE)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	return not result.is_empty()


func get_ground_position_during_fall(fall_distance: float) -> Variant:
	var query := PhysicsRayQueryParameters2D.new()
	query.from = global_position + Vector2(0, -GROUND_RAY_START_OFFSET)
	query.to = global_position + Vector2(0, fall_distance + GROUND_CHECK_DISTANCE)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	return result["position"]


func should_turn_around() -> bool:
	if use_patrol_limits:
		if patrol_direction < 0 and global_position.x <= patrol_left_limit:
			return true
		if patrol_direction > 0 and global_position.x >= patrol_right_limit:
			return true

	return is_obstacle_ahead(patrol_direction) or not is_ground_ahead(patrol_direction)


func is_obstacle_ahead(direction: int) -> bool:
	var ray_start := global_position + Vector2(0, BODY_CENTER_OFFSET)
	var ray_end := ray_start + Vector2(direction * OBSTACLE_CHECK_DISTANCE, 0)
	var query := PhysicsRayQueryParameters2D.new()
	query.from = ray_start
	query.to = ray_end
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return false

	var collider := result["collider"] as Node
	return is_movement_blocker(collider)


func can_move_horizontally(movement: float) -> bool:
	if is_zero_approx(movement):
		return true

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = get_horizontal_body_check_shape()
	query.transform = collision_shape.global_transform.translated(Vector2(movement + signf(movement) * BODY_COLLISION_MARGIN, -HORIZONTAL_BODY_CHECK_SHRINK.y * 0.5))
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = true

	var results := get_world_2d().direct_space_state.intersect_shape(query, 16)
	for result in results:
		var collider := result["collider"] as Node
		if is_movement_blocker(collider):
			return false

	return true


func is_movement_blocker(collider: Node) -> bool:
	if collider == null:
		return false
	if collider.is_in_group(ENEMY_GROUP):
		return false
	if collider.has_method("blocks_enemy_movement"):
		return collider.call("blocks_enemy_movement") == true

	return collider is StaticBody2D or collider is TileMap or collider is CharacterBody2D


func get_horizontal_body_check_shape() -> Shape2D:
	var rectangle_shape := collision_shape.shape as RectangleShape2D
	if rectangle_shape == null:
		return collision_shape.shape

	var check_shape := RectangleShape2D.new()
	check_shape.size = rectangle_shape.size - HORIZONTAL_BODY_CHECK_SHRINK
	return check_shape


func is_ground_ahead(direction: int) -> bool:
	var ray_start := global_position + Vector2(direction * LEDGE_CHECK_DISTANCE, -GROUND_RAY_START_OFFSET)
	var ray_end := ray_start + Vector2(0, LEDGE_CHECK_DEPTH)
	var query := PhysicsRayQueryParameters2D.new()
	query.from = ray_start
	query.to = ray_end
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	return not result.is_empty()


func setup_personal_patrol_limits() -> void:
	patrol_origin = global_position
	patrol_left_limit = patrol_origin.x - patrol_distance
	patrol_right_limit = patrol_origin.x + patrol_distance


func setup_spawn_variation() -> void:
	patrol_direction = get_random_patrol_direction()
	patrol_speed_multiplier = randf_range(MIN_PATROL_SPEED_MULTIPLIER, MAX_PATROL_SPEED_MULTIPLIER)


func get_current_patrol_speed() -> float:
	return PATROL_SPEED * patrol_speed_multiplier


func get_random_patrol_direction() -> int:
	if randi() % 2 == 0:
		return -1

	return 1


func get_direction_to_player() -> int:
	if player.global_position.x < global_position.x:
		return -1

	return 1


func get_projectile_target_position() -> Vector2:
	return Vector2(player.global_position.x, get_player_floor_y())


func get_player_floor_y() -> float:
	var exclude_rids := [get_rid()]
	if player is CollisionObject2D:
		exclude_rids.append((player as CollisionObject2D).get_rid())

	var query := PhysicsRayQueryParameters2D.new()
	query.from = player.global_position + Vector2(0, -PLAYER_FLOOR_RAY_UP)
	query.to = player.global_position + Vector2(0, PLAYER_FLOOR_RAY_DOWN)
	query.exclude = exclude_rids
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return player.global_position.y

	var floor_position := result["position"] as Vector2
	return floor_position.y


func get_projectile_velocity(start_position: Vector2, target_position: Vector2) -> Vector2:
	var horizontal_distance := absf(target_position.x - start_position.x)
	var flight_time := clampf(horizontal_distance / PROJECTILE_DISTANCE_TO_TIME, PROJECTILE_MIN_FLIGHT_TIME, PROJECTILE_MAX_FLIGHT_TIME)
	var displacement := target_position - start_position

	return Vector2(
		displacement.x / flight_time,
		(displacement.y - 0.5 * PROJECTILE_GRAVITY * flight_time * flight_time) / flight_time
	)


func turn_around() -> void:
	patrol_direction *= -1


func set_body_color(color: Color) -> void:
	body_visual.color = color
