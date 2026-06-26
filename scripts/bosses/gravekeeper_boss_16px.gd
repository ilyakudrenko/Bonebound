extends Area2D

signal health_changed(current_health: int, max_health: int)
signal defeated

const BOSS_DISPLAY_NAME := "The Graveyard Keeper"
const ENEMY_GROUP := "enemies"
const FLOATING_DAMAGE_NUMBER_SCENE := preload("res://scenes/ui/FloatingDamageNumber.tscn")
const COFFIN_PROJECTILE_SCENE := preload("res://scenes/scaled/projectiles/CoffinProjectile_16px.tscn")
const BASIC_SKELETON_SCENE := preload("res://scenes/scaled/enemies/DummyEnemy_16px.tscn")

const INACTIVE_STATE := "inactive"
const IDLE_STATE := "idle"
const SLAM_TELEGRAPH_STATE := "slam_telegraph"
const SLAM_RECOVERY_STATE := "slam_recovery"
const DASH_TELEGRAPH_STATE := "dash_telegraph"
const DASH_STATE := "dash"
const COFFIN_TELEGRAPH_STATE := "coffin_telegraph"
const SUMMON_TELEGRAPH_STATE := "summon_telegraph"
const RECOVERY_STATE := "recovery"
const TELEPORT_STATE := "teleport"
const STAGGER_STATE := "stagger"
const DEAD_STATE := "dead"

const NORMAL_COLOR := Color(0.36, 0.31, 0.28, 1)
const WARNING_COLOR := Color(0.95, 0.45, 0.08, 1)
const ATTACK_COLOR := Color(0.82, 0.08, 0.04, 1)
const HIT_COLOR := Color(1.0, 0.8, 0.25, 1)
const STAGGER_COLOR := Color(0.25, 0.45, 1.0, 1)
const DEAD_COLOR := Color(0.12, 0.1, 0.1, 1)
const TELEPORT_TRAIL_COLOR := Color(0.35, 0.9, 1.0, 0.32)
const DASH_TRAIL_COLOR := Color(1.0, 0.28, 0.12, 0.24)

@export var max_health := 140
@export var fall_gravity := 720.0
@export var floor_check_distance := 8.0
@export var boss_floor_half_width := 14.0
@export var contact_damage := 1
@export var ground_slam_damage := 2
@export var ground_slam_same_floor_tolerance := 10.0
@export var dash_damage := 2
@export var dash_speed := 620.0
@export var dash_duration := 0.46
@export var dash_trail_spawn_interval := 0.055
@export var dash_trail_lifetime := 0.2
@export var boss_attack_stun_duration := 0.35
@export var teleport_to_player_floor := true
@export var teleport_floor_check_distance := 120.0
@export var teleport_horizontal_offsets: Array[float] = [72.0, -72.0, 44.0, -44.0, 0.0]
@export var teleport_pause_duration := 0.35
@export var teleport_trail_count := 5
@export var teleport_trail_lifetime := 0.28
@export var phase_three_speed_multiplier := 1.15
@export var phase_four_speed_multiplier := 1.28
@export var player_path: NodePath = NodePath("../Player")
@export var boss_ui_path: NodePath = NodePath("../BossHealthBar")
@export var summoned_parent_path: NodePath = NodePath("../SummonedEnemies")

var health := max_health
var state := INACTIVE_STATE
var state_time_left := 0.0
var phase := 1
var attack_cycle_index := 0
var dash_direction := 1
var has_damaged_player_during_dash := false
var has_completed_phase_two_summon := false
var is_active := false
var ground_slam_cooldown_left := 0.0
var grave_dash_cooldown_left := 0.0
var coffin_throw_cooldown_left := 0.0
var summon_cooldown_left := 0.0
var contact_damage_cooldown_left := 0.0
var vertical_velocity := 0.0
var is_on_ground := false
var last_player_ground_y := 0.0
var has_player_ground_memory := false
var dash_trail_time_left := 0.0
var summoned_skeletons: Array[Node] = []
var player: Node2D = null
var boss_ui: Node = null
var summoned_parent: Node = null

@onready var body_visual: ColorRect = $Visual/Body
@onready var head_visual: ColorRect = $Visual/Head
@onready var shovel_visual: ColorRect = $Visual/Shovel
@onready var warning_visual: ColorRect = $Visual/Warning
@onready var shockwave_visual: ColorRect = $Visual/Shockwave
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group(ENEMY_GROUP)
	health = max_health
	player = get_node_or_null(player_path) as Node2D
	boss_ui = get_node_or_null(boss_ui_path)
	summoned_parent = get_node_or_null(summoned_parent_path)
	warning_visual.hide()
	shockwave_visual.hide()
	emit_signal("health_changed", health, max_health)


func _physics_process(delta: float) -> void:
	if state == DEAD_STATE:
		return

	apply_gravity(delta)

	if not is_active:
		return
	if not is_on_ground:
		return

	update_references()
	update_player_ground_memory()
	update_cooldowns(delta)
	clean_summoned_skeletons()
	update_phase()
	update_contact_damage()

	state_time_left -= delta

	if state == IDLE_STATE:
		if should_force_phase_two_summon():
			start_summon()
		elif state_time_left <= 0.0:
			choose_next_attack()
	elif state == SLAM_TELEGRAPH_STATE:
		update_slam_telegraph()
		if state_time_left <= 0.0:
			perform_ground_slam()
	elif state == SLAM_RECOVERY_STATE:
		if state_time_left <= 0.0:
			start_idle()
	elif state == DASH_TELEGRAPH_STATE:
		update_dash_telegraph()
		if state_time_left <= 0.0:
			start_dash()
	elif state == DASH_STATE:
		update_dash(delta)
	elif state == COFFIN_TELEGRAPH_STATE:
		update_coffin_telegraph()
		if state_time_left <= 0.0:
			throw_coffin()
	elif state == SUMMON_TELEGRAPH_STATE:
		update_summon_telegraph()
		if state_time_left <= 0.0:
			summon_skeletons()
	elif state == RECOVERY_STATE:
		if state_time_left <= 0.0:
			start_idle()
	elif state == TELEPORT_STATE:
		update_teleport_telegraph()
		if state_time_left <= 0.0:
			complete_floor_teleport()
	elif state == STAGGER_STATE:
		if state_time_left <= 0.0:
			start_idle()


func start_fight() -> void:
	if is_active or state == DEAD_STATE:
		return

	is_active = true
	if boss_ui != null and boss_ui.has_method("setup"):
		boss_ui.call("setup", self)
	start_idle()


func update_references() -> void:
	if player == null or not is_instance_valid(player):
		player = get_node_or_null(player_path) as Node2D
	if summoned_parent == null:
		summoned_parent = get_node_or_null(summoned_parent_path)


func update_player_ground_memory() -> void:
	if player == null or not player.has_method("is_on_floor"):
		return
	if not bool(player.call("is_on_floor")):
		return

	var player_floor_y: Variant = get_floor_y_at_x(player.global_position.x, player.global_position.y - 8.0)
	if player_floor_y == null:
		return

	last_player_ground_y = float(player_floor_y)
	has_player_ground_memory = true


func update_cooldowns(delta: float) -> void:
	ground_slam_cooldown_left = maxf(ground_slam_cooldown_left - delta, 0.0)
	grave_dash_cooldown_left = maxf(grave_dash_cooldown_left - delta, 0.0)
	coffin_throw_cooldown_left = maxf(coffin_throw_cooldown_left - delta, 0.0)
	summon_cooldown_left = maxf(summon_cooldown_left - delta, 0.0)
	contact_damage_cooldown_left = maxf(contact_damage_cooldown_left - delta, 0.0)


func apply_gravity(delta: float) -> void:
	var previous_foot_position := global_position
	vertical_velocity += fall_gravity * delta
	global_position.y += vertical_velocity * delta

	var floor_position: Variant = get_floor_position(previous_foot_position, global_position)
	if floor_position == null:
		is_on_ground = false
		return

	global_position.y = (floor_position as Vector2).y
	vertical_velocity = 0.0
	is_on_ground = true


func get_floor_position(previous_foot_position: Vector2, current_foot_position: Vector2) -> Variant:
	if vertical_velocity < 0.0:
		return null

	var query := PhysicsRayQueryParameters2D.new()
	query.from = previous_foot_position + Vector2(0, -2)
	query.to = current_foot_position + Vector2(0, floor_check_distance)
	query.exclude = get_floor_query_exclusions()
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	return result["position"] as Vector2


func update_phase() -> void:
	var health_ratio := float(health) / float(max_health)
	if health_ratio <= 0.25:
		phase = 4
	elif health_ratio <= 0.5:
		phase = 3
	elif health_ratio <= 0.75:
		phase = 2
	else:
		phase = 1


func start_idle() -> void:
	if should_teleport_to_player_floor():
		start_floor_teleport()
		return

	state = IDLE_STATE
	state_time_left = get_idle_duration()
	body_visual.color = NORMAL_COLOR
	head_visual.color = Color(0.44, 0.38, 0.34, 1)
	shovel_visual.color = Color(0.62, 0.62, 0.58, 1)
	warning_visual.hide()
	shockwave_visual.hide()


func should_teleport_to_player_floor() -> bool:
	if not teleport_to_player_floor or not is_active:
		return false
	if player == null or not has_player_ground_memory:
		return false
	if not is_on_ground:
		return false

	return absf(last_player_ground_y - global_position.y) > ground_slam_same_floor_tolerance


func start_floor_teleport() -> void:
	state = TELEPORT_STATE
	state_time_left = teleport_pause_duration
	body_visual.color = Color(0.25, 0.85, 1.0, 1)
	head_visual.color = Color(0.45, 1.0, 1.0, 1)
	shovel_visual.color = Color(0.65, 1.0, 1.0, 1)
	warning_visual.show()
	warning_visual.color = Color(0.2, 0.8, 1.0, 0.35)


func update_teleport_telegraph() -> void:
	warning_visual.color = Color(0.2, 0.8, 1.0, 0.25 + (sin(Time.get_ticks_msec() * 0.025) + 1.0) * 0.2)


func complete_floor_teleport() -> void:
	var teleport_position: Variant = get_teleport_position_near_player()
	if teleport_position != null:
		spawn_teleport_trail(global_position, teleport_position as Vector2)
		global_position = teleport_position as Vector2
		vertical_velocity = 0.0
		is_on_ground = true

	state = IDLE_STATE
	state_time_left = 0.15
	body_visual.color = NORMAL_COLOR
	head_visual.color = Color(0.44, 0.38, 0.34, 1)
	shovel_visual.color = Color(0.62, 0.62, 0.58, 1)
	warning_visual.hide()


func get_teleport_position_near_player() -> Variant:
	if player == null:
		return null

	for offset_x in teleport_horizontal_offsets:
		var candidate_x := player.global_position.x + offset_x
		var floor_y: Variant = get_floor_y_at_x(candidate_x, last_player_ground_y - 24.0)
		if floor_y == null:
			continue
		if absf(float(floor_y) - last_player_ground_y) > ground_slam_same_floor_tolerance:
			continue

		var candidate_position := Vector2(candidate_x, float(floor_y))
		if not is_safe_standing_position(candidate_position):
			continue

		return candidate_position

	return null


func is_safe_standing_position(standing_position: Vector2) -> bool:
	var center_floor_y: Variant = get_floor_y_at_x(standing_position.x, standing_position.y - 24.0)
	var left_floor_y: Variant = get_floor_y_at_x(standing_position.x - boss_floor_half_width, standing_position.y - 24.0)
	var right_floor_y: Variant = get_floor_y_at_x(standing_position.x + boss_floor_half_width, standing_position.y - 24.0)

	if center_floor_y == null or left_floor_y == null or right_floor_y == null:
		return false

	return (
		absf(float(center_floor_y) - standing_position.y) <= ground_slam_same_floor_tolerance
		and absf(float(left_floor_y) - standing_position.y) <= ground_slam_same_floor_tolerance
		and absf(float(right_floor_y) - standing_position.y) <= ground_slam_same_floor_tolerance
	)


func get_floor_y_at_x(check_x: float, start_y: float) -> Variant:
	var query := PhysicsRayQueryParameters2D.new()
	query.from = Vector2(check_x, start_y)
	query.to = Vector2(check_x, start_y + teleport_floor_check_distance)
	query.exclude = get_floor_query_exclusions()
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	var hit_position := result["position"] as Vector2
	return hit_position.y


func get_floor_query_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = [get_rid()]

	if player != null and is_instance_valid(player) and player is CollisionObject2D:
		exclusions.append((player as CollisionObject2D).get_rid())

	for enemy in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if enemy == self or not (enemy is CollisionObject2D):
			continue
		exclusions.append((enemy as CollisionObject2D).get_rid())

	return exclusions


func spawn_teleport_trail(from_position: Vector2, to_position: Vector2) -> void:
	var trail_parent := get_tree().current_scene
	if trail_parent == null:
		return

	var trail_steps := maxi(teleport_trail_count, 1)
	for step in range(trail_steps):
		var progress := float(step + 1) / float(trail_steps + 1)
		var trail_alpha := TELEPORT_TRAIL_COLOR.a * (1.0 - progress * 0.55)
		spawn_movement_afterimage(
			from_position.lerp(to_position, progress),
			Color(TELEPORT_TRAIL_COLOR.r, TELEPORT_TRAIL_COLOR.g, TELEPORT_TRAIL_COLOR.b, trail_alpha),
			teleport_trail_lifetime,
			z_index - 1
		)


func spawn_movement_afterimage(afterimage_position: Vector2, afterimage_color: Color, lifetime: float, afterimage_z_index: int) -> void:
	var trail_parent := get_tree().current_scene
	if trail_parent == null:
		return

	var afterimage := Node2D.new()
	afterimage.z_index = afterimage_z_index
	afterimage.name = "GravekeeperMovementTrail"

	add_afterimage_part(afterimage, body_visual, afterimage_color)
	add_afterimage_part(afterimage, head_visual, afterimage_color)
	add_afterimage_part(afterimage, shovel_visual, afterimage_color)

	trail_parent.add_child(afterimage)
	afterimage.global_position = afterimage_position

	var tween := afterimage.create_tween()
	tween.tween_property(afterimage, "modulate:a", 0.0, lifetime)
	tween.tween_callback(Callable(afterimage, "queue_free"))


func add_afterimage_part(parent: Node2D, source_part: ColorRect, afterimage_color: Color) -> void:
	var part := ColorRect.new()
	part.position = source_part.position
	part.offset_left = source_part.offset_left
	part.offset_top = source_part.offset_top
	part.offset_right = source_part.offset_right
	part.offset_bottom = source_part.offset_bottom
	part.color = afterimage_color
	part.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(part)


func choose_next_attack() -> void:
	var cycle: Array[String] = get_attack_cycle()

	for offset in range(cycle.size()):
		var attack_name := cycle[(attack_cycle_index + offset) % cycle.size()]
		if can_use_attack(attack_name):
			attack_cycle_index = (attack_cycle_index + offset + 1) % cycle.size()
			start_attack(attack_name)
			return

	start_idle()


func get_attack_cycle() -> Array[String]:
	if phase == 1:
		return ["slam", "dash"]
	if phase == 2:
		return ["slam", "dash", "coffin"]
	if phase == 3:
		return ["coffin", "dash", "slam", "coffin"]

	return ["dash", "coffin", "slam", "summon"]


func can_use_attack(attack_name: String) -> bool:
	if attack_name == "slam":
		return ground_slam_cooldown_left <= 0.0
	if attack_name == "dash":
		return grave_dash_cooldown_left <= 0.0
	if attack_name == "coffin":
		return phase >= 2 and coffin_throw_cooldown_left <= 0.0
	if attack_name == "summon":
		return phase >= 2 and summon_cooldown_left <= 0.0 and not has_living_summons()

	return false


func start_attack(attack_name: String) -> void:
	if attack_name == "slam":
		start_ground_slam()
	elif attack_name == "dash":
		start_grave_dash()
	elif attack_name == "coffin":
		start_coffin_throw()
	elif attack_name == "summon":
		start_summon()


func start_ground_slam() -> void:
	state = SLAM_TELEGRAPH_STATE
	state_time_left = scaled_time(0.85)
	body_visual.color = WARNING_COLOR
	shovel_visual.color = Color(1.0, 0.75, 0.12, 1)
	warning_visual.show()
	ground_slam_cooldown_left = scaled_time(3.2)


func update_slam_telegraph() -> void:
	warning_visual.color = Color(1.0, 0.35, 0.08, 0.25 + (sin(Time.get_ticks_msec() * 0.018) + 1.0) * 0.2)
	shovel_visual.rotation_degrees = -22.0


func perform_ground_slam() -> void:
	state = SLAM_RECOVERY_STATE
	state_time_left = scaled_time(0.85)
	body_visual.color = ATTACK_COLOR
	shovel_visual.rotation_degrees = 18.0
	warning_visual.hide()
	show_shockwave()

	if is_player_vulnerable_to_ground_slam():
		damage_player(ground_slam_damage, true)


func is_player_vulnerable_to_ground_slam() -> bool:
	if player == null or not player.has_method("is_on_floor"):
		return false
	if not bool(player.call("is_on_floor")):
		return false

	return absf(player.global_position.y - global_position.y) <= ground_slam_same_floor_tolerance


func show_shockwave() -> void:
	shockwave_visual.show()
	shockwave_visual.modulate.a = 0.9
	var tween := create_tween()
	tween.tween_property(shockwave_visual, "modulate:a", 0.0, 0.25)
	tween.tween_callback(Callable(shockwave_visual, "hide"))


func start_grave_dash() -> void:
	state = DASH_TELEGRAPH_STATE
	state_time_left = scaled_time(0.65)
	dash_direction = get_direction_to_player()
	body_visual.color = WARNING_COLOR
	shovel_visual.color = Color(0.95, 0.95, 0.7, 1)
	grave_dash_cooldown_left = scaled_time(2.6)


func update_dash_telegraph() -> void:
	shovel_visual.rotation_degrees = -35.0 * float(dash_direction)
	warning_visual.show()
	warning_visual.color = Color(1.0, 0.12, 0.04, 0.28)


func start_dash() -> void:
	state = DASH_STATE
	state_time_left = scaled_time(dash_duration)
	has_damaged_player_during_dash = false
	dash_trail_time_left = 0.0
	body_visual.color = ATTACK_COLOR
	warning_visual.hide()


func update_dash(delta: float) -> void:
	spawn_dash_trail_if_ready(delta)
	var next_position := global_position
	next_position.x += float(dash_direction) * dash_speed * get_phase_speed_multiplier() * delta

	if not is_safe_standing_position(next_position):
		stop_dash()
		return

	global_position = next_position
	try_dash_damage_player()

	if state_time_left <= 0.0:
		stop_dash()


func stop_dash() -> void:
	state = RECOVERY_STATE
	state_time_left = scaled_time(0.75)
	body_visual.color = NORMAL_COLOR
	shovel_visual.rotation_degrees = 0.0


func spawn_dash_trail_if_ready(delta: float) -> void:
	dash_trail_time_left -= delta
	if dash_trail_time_left > 0.0:
		return

	dash_trail_time_left = dash_trail_spawn_interval
	spawn_movement_afterimage(global_position, DASH_TRAIL_COLOR, dash_trail_lifetime, z_index - 1)


func try_dash_damage_player() -> void:
	if has_damaged_player_during_dash or player == null:
		return

	var player_center := player.global_position + Vector2(0, -24)
	var boss_center := global_position + Vector2(0, -28)
	if absf(player_center.x - boss_center.x) > 24.0:
		return
	if absf(player_center.y - boss_center.y) > 42.0:
		return

	has_damaged_player_during_dash = true
	damage_player(dash_damage, true)


func start_coffin_throw() -> void:
	state = COFFIN_TELEGRAPH_STATE
	state_time_left = scaled_time(0.75)
	body_visual.color = WARNING_COLOR
	shovel_visual.color = Color(0.56, 0.34, 0.2, 1)
	coffin_throw_cooldown_left = scaled_time(3.0 if phase < 3 else 2.2)


func update_coffin_telegraph() -> void:
	warning_visual.show()
	warning_visual.color = Color(0.45, 0.25, 0.12, 0.4)


func throw_coffin() -> void:
	state = RECOVERY_STATE
	state_time_left = scaled_time(0.9)
	body_visual.color = NORMAL_COLOR
	warning_visual.hide()

	if player == null:
		return

	var coffin := COFFIN_PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(coffin)
	coffin.global_position = global_position + Vector2(18.0 * float(get_direction_to_player()), -56.0)

	var target_position := player.global_position + Vector2(0, -8)
	var travel_time := clampf(absf(target_position.x - coffin.global_position.x) / 125.0, 0.75, 1.25)
	var start_velocity := get_arc_velocity(coffin.global_position, target_position, travel_time, 560.0)
	coffin.call("setup", start_velocity, self, target_position.y)


func start_summon() -> void:
	state = SUMMON_TELEGRAPH_STATE
	state_time_left = scaled_time(1.0)
	body_visual.color = WARNING_COLOR
	shovel_visual.color = Color(0.48, 0.85, 0.55, 1)
	summon_cooldown_left = scaled_time(7.0)


func update_summon_telegraph() -> void:
	warning_visual.show()
	warning_visual.color = Color(0.35, 0.85, 0.45, 0.35 + (sin(Time.get_ticks_msec() * 0.018) + 1.0) * 0.15)


func summon_skeletons() -> void:
	state = RECOVERY_STATE
	state_time_left = scaled_time(1.0)
	has_completed_phase_two_summon = true
	body_visual.color = NORMAL_COLOR
	warning_visual.hide()

	if has_living_summons():
		return

	var parent := get_summoned_parent()
	for offset in [Vector2(-72, 0), Vector2(72, 0)]:
		var skeleton := BASIC_SKELETON_SCENE.instantiate()
		parent.add_child(skeleton)
		skeleton.global_position = global_position + offset
		summoned_skeletons.append(skeleton)


func should_force_phase_two_summon() -> bool:
	return phase >= 2 and not has_completed_phase_two_summon and not has_living_summons()


func has_living_summons() -> bool:
	clean_summoned_skeletons()
	return not summoned_skeletons.is_empty()


func clean_summoned_skeletons() -> void:
	var living_skeletons: Array[Node] = []
	for skeleton in summoned_skeletons:
		if skeleton != null and is_instance_valid(skeleton) and not skeleton.is_queued_for_deletion():
			living_skeletons.append(skeleton)
	summoned_skeletons = living_skeletons


func get_summoned_parent() -> Node:
	if summoned_parent != null:
		return summoned_parent

	var current_scene := get_tree().current_scene
	var parent := current_scene.get_node_or_null("SummonedEnemies")
	if parent == null:
		parent = Node2D.new()
		parent.name = "SummonedEnemies"
		current_scene.add_child(parent)
	summoned_parent = parent
	return summoned_parent


func update_contact_damage() -> void:
	if contact_damage_cooldown_left > 0.0:
		return
	if player == null:
		return

	var player_center := player.global_position + Vector2(0, -24)
	var boss_center := global_position + Vector2(0, -28)
	if player_center.distance_to(boss_center) > 28.0:
		return

	contact_damage_cooldown_left = 0.8
	damage_player(contact_damage, false)


func damage_player(amount: int, should_stun: bool) -> void:
	if player == null:
		return

	if player.has_method("take_player_damage"):
		player.call("take_player_damage", amount, self)
	if should_stun and player.has_method("stun_player"):
		player.call("stun_player", boss_attack_stun_duration)


func take_damage(amount: int, is_critical: bool = false) -> void:
	if state == DEAD_STATE:
		return

	health = maxi(health - amount, 0)
	spawn_damage_number(amount, is_critical)
	flash_hit()
	emit_signal("health_changed", health, max_health)

	if health <= 0:
		die()


func take_parry_counter_damage(amount: int) -> void:
	take_damage(amount)


func stun() -> void:
	stun_for_duration(0.35)


func stun_for_duration(duration: float) -> void:
	if not is_active or state == DEAD_STATE:
		return
	if state == DASH_STATE or state == SLAM_TELEGRAPH_STATE:
		return

	state = STAGGER_STATE
	state_time_left = minf(duration, 0.45)
	body_visual.color = STAGGER_COLOR


func is_crowd_controlled() -> bool:
	return state == STAGGER_STATE


func die() -> void:
	state = DEAD_STATE
	is_active = false
	collision_shape.set_deferred("disabled", true)
	warning_visual.hide()
	shockwave_visual.hide()
	body_visual.color = DEAD_COLOR
	head_visual.color = DEAD_COLOR
	shovel_visual.color = DEAD_COLOR
	despawn_summons()
	emit_signal("defeated")


func despawn_summons() -> void:
	for skeleton in summoned_skeletons:
		if skeleton != null and is_instance_valid(skeleton):
			skeleton.queue_free()
	summoned_skeletons.clear()


func flash_hit() -> void:
	var previous_body_color := body_visual.color
	body_visual.color = HIT_COLOR
	var tween := create_tween()
	tween.tween_property(body_visual, "color", previous_body_color, 0.15)


func spawn_damage_number(amount: int, is_critical: bool = false) -> void:
	var damage_number := FLOATING_DAMAGE_NUMBER_SCENE.instantiate()
	damage_number.setup(amount, is_critical)
	get_tree().current_scene.add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -78)


func get_arc_velocity(start_position: Vector2, target_position: Vector2, travel_time: float, gravity: float) -> Vector2:
	var displacement := target_position - start_position
	return Vector2(
		displacement.x / travel_time,
		(displacement.y - (0.5 * gravity * travel_time * travel_time)) / travel_time
	)


func get_direction_to_player() -> int:
	if player == null:
		return -1
	return 1 if player.global_position.x > global_position.x else -1


func scaled_time(base_time: float) -> float:
	return base_time / get_phase_speed_multiplier()


func get_idle_duration() -> float:
	if phase == 4:
		return 0.35
	if phase == 3:
		return 0.5
	return 0.7


func get_phase_speed_multiplier() -> float:
	if phase == 4:
		return phase_four_speed_multiplier
	if phase == 3:
		return phase_three_speed_multiplier
	return 1.0


func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_boss_display_name() -> String:
	return BOSS_DISPLAY_NAME
