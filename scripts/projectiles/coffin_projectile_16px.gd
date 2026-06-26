extends Area2D

const GRAVITY := 560.0
const GROUND_CHECK_DISTANCE := 6.0
const LANDING_DELAY := 0.35
const EXPLOSION_DURATION := 0.18
const EXPLOSION_RADIUS := 34.0
const EXPLOSION_DAMAGE := 2
const REFLECTED_DAMAGE := 2
const LANDING_Y_TOLERANCE := 18.0
const REFLECTED_MIN_HORIZONTAL_SPEED := 135.0
const REFLECTED_UPWARD_VELOCITY := -130.0

var velocity := Vector2.ZERO
var owner_boss: Node = null
var reflected_owner: Node = null
var reflected_damage_multiplier := 1.0
var is_player_owned := false
var has_landed := false
var has_exploded := false
var landing_time_left := LANDING_DELAY
var explosion_time_left := EXPLOSION_DURATION
var has_target_landing_y := false
var target_landing_y := 0.0

@onready var coffin_visual: ColorRect = $CoffinVisual
@onready var warning_visual: ColorRect = $WarningVisual
@onready var explosion_visual: ColorRect = $ExplosionVisual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func setup(start_velocity: Vector2, source_boss: Node = null, target_y: Variant = null) -> void:
	velocity = start_velocity
	owner_boss = source_boss

	if target_y != null:
		has_target_landing_y = true
		target_landing_y = float(target_y)


func _ready() -> void:
	warning_visual.hide()
	explosion_visual.hide()


func _physics_process(delta: float) -> void:
	if has_exploded:
		update_explosion(delta)
		return

	if has_landed:
		update_landed(delta)
		return

	update_flight(delta)


func update_flight(delta: float) -> void:
	var previous_position := global_position
	velocity.y += GRAVITY * delta
	global_position += velocity * delta

	var landing_position: Variant = get_valid_landing_position(previous_position, global_position)
	if landing_position != null:
		global_position = landing_position as Vector2
		land()


func update_landed(delta: float) -> void:
	landing_time_left -= delta
	warning_visual.modulate.a = 0.35 + (sin(Time.get_ticks_msec() * 0.025) + 1.0) * 0.25

	if landing_time_left <= 0.0:
		explode()


func update_explosion(delta: float) -> void:
	explosion_time_left -= delta
	var progress := 1.0 - maxf(explosion_time_left, 0.0) / EXPLOSION_DURATION
	var visual_size := lerpf(16.0, EXPLOSION_RADIUS * 2.0, progress)

	explosion_visual.size = Vector2(visual_size, visual_size)
	explosion_visual.position = Vector2(-visual_size * 0.5, -visual_size * 0.5)
	explosion_visual.modulate.a = 1.0 - progress

	if explosion_time_left <= 0.0:
		queue_free()


func land() -> void:
	has_landed = true
	velocity = Vector2.ZERO
	coffin_visual.color = Color(0.35, 0.2, 0.12, 1) if not is_player_owned else Color(0.25, 0.78, 1.0, 1)
	warning_visual.show()


func explode() -> void:
	if has_exploded:
		return

	has_exploded = true
	coffin_visual.hide()
	warning_visual.hide()
	collision_shape.set_deferred("disabled", true)
	explosion_visual.show()
	damage_targets_if_in_range()


func damage_targets_if_in_range() -> void:
	if is_player_owned:
		damage_enemies_if_in_range()
	else:
		damage_player_if_in_range()


func damage_player_if_in_range() -> void:
	var player := get_tree().current_scene.get_node_or_null("Player") as Node2D
	if player == null:
		return

	if global_position.distance_to(player.global_position + Vector2(0, -20)) > EXPLOSION_RADIUS:
		return

	if player.has_method("take_player_damage"):
		var damage_source: Node = null
		if is_instance_valid(owner_boss):
			damage_source = owner_boss
		player.call("take_player_damage", EXPLOSION_DAMAGE, damage_source)
	if player.has_method("stun_player"):
		player.call("stun_player", 0.35)


func damage_enemies_if_in_range() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy as Node2D
		if enemy_node == null or not enemy_node.has_method("take_damage"):
			continue
		if global_position.distance_to(enemy_node.global_position + Vector2(0, -20)) > EXPLOSION_RADIUS:
			continue

		var health_before := get_target_health(enemy_node)
		enemy_node.call("take_damage", get_reflected_damage())
		if health_before > 0 and get_target_health(enemy_node) <= 0:
			notify_reflected_kill()


func reflect_by_player(player: Node, reflect_direction: int, damage_multiplier: float = 1.0) -> bool:
	if is_player_owned or has_landed or has_exploded:
		return false

	is_player_owned = true
	reflected_owner = player
	reflected_damage_multiplier = damage_multiplier
	owner_boss = null
	has_target_landing_y = false

	var horizontal_speed := maxf(absf(velocity.x), REFLECTED_MIN_HORIZONTAL_SPEED)
	velocity.x = horizontal_speed * float(reflect_direction)
	velocity.y = minf(velocity.y, REFLECTED_UPWARD_VELOCITY)
	coffin_visual.color = Color(0.25, 0.78, 1.0, 1)
	warning_visual.color = Color(0.25, 0.78, 1.0, 0.65)
	explosion_visual.color = Color(0.25, 0.78, 1.0, 0.85)
	return true


func get_reflected_damage() -> int:
	return maxi(1, int(round(float(REFLECTED_DAMAGE) * reflected_damage_multiplier)))


func get_target_health(target: Node) -> int:
	if target == null:
		return 0

	var health_value: Variant = target.get("health")
	if health_value == null:
		return 0

	return int(health_value)


func notify_reflected_kill() -> void:
	if reflected_owner == null or not is_instance_valid(reflected_owner):
		return
	if reflected_owner.has_method("notify_reflected_projectile_kill"):
		reflected_owner.call("notify_reflected_projectile_kill")


func get_valid_landing_position(previous_position: Vector2, current_position: Vector2) -> Variant:
	if velocity.y < 0.0:
		return null

	var query := PhysicsRayQueryParameters2D.new()
	query.from = previous_position
	query.to = current_position + Vector2(0, GROUND_CHECK_DISTANCE)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	var hit_position := result["position"] as Vector2
	if not can_land_on_y(hit_position.y):
		return null

	return hit_position


func can_land_on_y(ground_y: float) -> bool:
	if not has_target_landing_y:
		return true

	return absf(ground_y - target_landing_y) <= LANDING_Y_TOLERANCE
