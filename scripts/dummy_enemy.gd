extends Area2D

const STARTING_HEALTH := 10
const NORMAL_COLOR := Color(0.65, 0.62, 0.55, 1)
const HIT_COLOR := Color(1, 0.85, 0.35, 1)
const WARNING_COLOR := Color(1, 0.35, 0.12, 1)
const LUNGE_COLOR := Color(1, 0.18, 0.08, 1)
const ATTACK_COLOR := Color(1, 0.05, 0.05, 1)
const STUN_COLOR := Color(0.25, 0.45, 1, 1)
const DETECTION_RANGE := 130.0
const ATTACK_RANGE := 78.0
const ATTACK_WINDUP := 0.55
const LUNGE_DURATION := 0.24
const LUNGE_SPEED := 360.0
const ATTACK_DURATION := 0.12
const ATTACK_COOLDOWN := 0.9
const STUN_DURATION := 1.0
const ATTACK_DAMAGE := 1
const PATROL_SPEED := 55.0
const PATROL_DISTANCE := 180.0
const OBSTACLE_CHECK_DISTANCE := 28.0
const IDLE_STATE := "idle"
const WINDUP_STATE := "windup"
const LUNGE_STATE := "lunge"
const ATTACK_STATE := "attack"
const COOLDOWN_STATE := "cooldown"
const STUNNED_STATE := "stunned"

const FLOATING_DAMAGE_NUMBER_SCENE := preload("res://scenes/FloatingDamageNumber.tscn")
const ENEMY_CORPSE_SCENE := preload("res://scenes/EnemyCorpse.tscn")

var health := STARTING_HEALTH
var state := IDLE_STATE
var state_time_left := 0.0
var has_hit_during_attack := false
var was_parried_during_prepare := false
var patrol_direction := -1
var attack_direction := -1
var spawn_position := Vector2.ZERO
var player: Node2D

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	spawn_position = global_position
	player = get_tree().current_scene.get_node_or_null("Player") as Node2D


func _physics_process(delta: float) -> void:
	if player == null:
		return

	state_time_left -= delta

	if state == IDLE_STATE:
		visual.color = NORMAL_COLOR
		if is_player_in_detection_range():
			start_windup()
		else:
			update_patrol(delta)
	elif state == WINDUP_STATE:
		check_prepare_parry()

		if state_time_left <= 0.0:
			start_lunge()
	elif state == LUNGE_STATE:
		check_prepare_parry()
		update_lunge(delta)

		if state_time_left <= 0.0:
			start_attack()
	elif state == ATTACK_STATE:
		try_hit_player()
		if state_time_left <= 0.0:
			start_cooldown()
	elif state == COOLDOWN_STATE:
		if state_time_left <= 0.0:
			state = IDLE_STATE
	elif state == STUNNED_STATE:
		if state_time_left <= 0.0:
			state = IDLE_STATE


func take_damage(amount: int) -> void:
	health -= amount
	flash_hit()
	spawn_damage_number(amount)

	if health <= 0:
		spawn_corpse()
		queue_free()
		return

	react_to_damage()


func react_to_damage() -> void:
	if player == null or state == STUNNED_STATE:
		return

	start_windup()


func flash_hit() -> void:
	visual.color = HIT_COLOR

	var tween := create_tween()
	tween.tween_property(visual, "color", NORMAL_COLOR, 0.15)


func spawn_damage_number(amount: int) -> void:
	var damage_number := FLOATING_DAMAGE_NUMBER_SCENE.instantiate()

	damage_number.setup(amount)
	get_tree().current_scene.add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -108)


func spawn_corpse() -> void:
	var corpse := ENEMY_CORPSE_SCENE.instantiate()

	get_tree().current_scene.add_child(corpse)
	corpse.global_position = global_position


func start_windup() -> void:
	state = WINDUP_STATE
	state_time_left = ATTACK_WINDUP
	attack_direction = get_direction_to_player()
	patrol_direction = attack_direction
	was_parried_during_prepare = false
	visual.color = WARNING_COLOR


func start_lunge() -> void:
	state = LUNGE_STATE
	state_time_left = LUNGE_DURATION
	visual.color = LUNGE_COLOR


func start_attack() -> void:
	if was_parried_during_prepare:
		stun()
		return

	state = ATTACK_STATE
	state_time_left = ATTACK_DURATION
	has_hit_during_attack = false
	visual.color = ATTACK_COLOR


func start_cooldown() -> void:
	state = COOLDOWN_STATE
	state_time_left = ATTACK_COOLDOWN
	visual.color = NORMAL_COLOR


func stun() -> void:
	stun_for_duration(STUN_DURATION)


func stun_for_duration(duration: float) -> void:
	state = STUNNED_STATE
	state_time_left = duration
	has_hit_during_attack = true
	visual.color = STUN_COLOR


func is_player_in_detection_range() -> bool:
	var horizontal_distance := absf(player.global_position.x - global_position.x)
	var player_is_in_front := signf(player.global_position.x - global_position.x) == patrol_direction

	return horizontal_distance <= DETECTION_RANGE and player_is_in_front


func is_player_in_attack_range() -> bool:
	var horizontal_distance := absf(player.global_position.x - global_position.x)
	var vertical_distance := absf((player.global_position.y - 48.0) - (global_position.y - 48.0))

	return is_player_in_detection_range() and horizontal_distance <= ATTACK_RANGE and vertical_distance <= 70.0


func try_hit_player() -> void:
	if has_hit_during_attack or not is_player_in_attack_range():
		return

	has_hit_during_attack = true

	if player.has_method("is_shield_parrying") and player.call("is_shield_parrying"):
		stun()
		return

	if player.has_method("take_player_damage"):
		player.call("take_player_damage", ATTACK_DAMAGE, self)


func check_prepare_parry() -> void:
	if was_parried_during_prepare:
		return

	if not is_player_in_detection_range():
		return

	if player.has_method("is_shield_parrying") and player.call("is_shield_parrying"):
		was_parried_during_prepare = true
		visual.color = STUN_COLOR


func update_patrol(delta: float) -> void:
	if should_turn_around():
		turn_around()

	global_position.x += patrol_direction * PATROL_SPEED * delta


func update_lunge(delta: float) -> void:
	if is_obstacle_ahead(attack_direction):
		state_time_left = 0.0
		return

	global_position.x += attack_direction * LUNGE_SPEED * delta


func should_turn_around() -> bool:
	if patrol_direction < 0 and global_position.x <= spawn_position.x - PATROL_DISTANCE:
		return true

	if patrol_direction > 0 and global_position.x >= spawn_position.x + PATROL_DISTANCE:
		return true

	return is_obstacle_ahead(patrol_direction)


func turn_around() -> void:
	patrol_direction *= -1


func get_direction_to_player() -> int:
	if player.global_position.x < global_position.x:
		return -1

	return 1


func is_obstacle_ahead(direction: int) -> bool:
	var ray_start := global_position + Vector2(0, -48)
	var ray_end := ray_start + Vector2(direction * OBSTACLE_CHECK_DISTANCE, 0)
	var query := PhysicsRayQueryParameters2D.new()
	query.from = ray_start
	query.to = ray_end
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	return not result.is_empty()
