extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -460.0
const DOUBLE_JUMP_VELOCITY := -420.0
const GRAVITY := 1200.0
const ONE_LEG_SPEED_MULTIPLIER := 0.65
const NO_LEGS_SPEED_MULTIPLIER := 0.25
const ONE_LEG_JUMP_MULTIPLIER := 0.75
const CRAWLER_JUMP_VELOCITY := -180.0
const FIRST_LEG_SACRIFICE_JUMP := -660.0
const LAST_LEG_SACRIFICE_JUMP := -460.0
const ARM_THROW_DAMAGE := 1
const ARM_THROW_OFFSET := Vector2(36, -52)
const LEG_DROP_OFFSET := Vector2(0, -12)
const NORMAL_BODY_PARTS_POSITION := Vector2.ZERO
const CRAWLER_BODY_PARTS_POSITION := Vector2(0, 32)
const NORMAL_COLLISION_POSITION := Vector2(0, -48)
const CRAWLER_COLLISION_POSITION := Vector2(0, -32)
const ROLL_COLLISION_POSITION := Vector2(0, -20)
const NORMAL_COLLISION_SIZE := Vector2(40, 96)
const CRAWLER_COLLISION_SIZE := Vector2(40, 64)
const ROLL_COLLISION_SIZE := Vector2(48, 40)
const ROLL_BODY_PARTS_POSITION := Vector2.ZERO
const NORMAL_BODY_PARTS_SCALE_Y := 1.0
const ROLL_BODY_PARTS_SCALE_Y := 0.42
const ROLL_SPEED := 430.0
const FORCED_TUNNEL_ROLL_SPEED := 300.0
const ONE_LEG_ROLL_SPEED_MULTIPLIER := 0.65
const ROLL_DURATION := 0.32
const AIR_ROLL_DURATION := 0.42
const ROLL_COOLDOWN := 0.45
const SWORD_ATTACK_DAMAGE := 1
const SWORD_STARTUP_DURATION := 0.08
const SWORD_ACTIVE_DURATION := 0.08
const SWORD_RECOVERY_DURATION := 0.22
const SWORD_ATTACK_MOVE_MULTIPLIER := 0.45
const SWORD_HITBOX_SIZE := Vector2(72, 48)
const SWORD_HITBOX_OFFSET := Vector2(52, -54)
const AXE_ATTACK_DAMAGE := 3
const AXE_STARTUP_DURATION := 0.18
const AXE_ACTIVE_DURATION := 0.12
const AXE_RECOVERY_DURATION := 0.75
const AXE_ATTACK_MOVE_MULTIPLIER := 0.22
const AXE_HITBOX_SIZE := Vector2(82, 58)
const AXE_HITBOX_OFFSET := Vector2(58, -54)
const SHIELD_THROW_DAMAGE_BONUS := 1
const SHIELD_USE_DURATION := 0.35
const SHIELD_PARRY_DURATION := 0.14
const SHIELD_BLOCK_COLOR := Color(0.14, 0.62, 0.78, 1)
const SHIELD_PARRY_COLOR := Color(0.75, 0.95, 1, 1)
const STARTING_HEALTH := 5
const HEAD_DEATH_PIECE_SIZE := Vector2(24, 24)
const TORSO_DEATH_PIECE_SIZE := Vector2(28, 40)
const ARM_DEATH_PIECE_SIZE := Vector2(12, 36)
const LEG_DEATH_PIECE_SIZE := Vector2(12, 32)
const SKELETON_ARM_COLOR := Color(1, 0.05, 0.05, 1)
const SKELETON_LEG_COLOR := Color(0.05, 0.85, 0.15, 1)
const ENEMY_ARM_COLOR := Color(1, 0.35, 0.75, 1)
const ENEMY_LEG_COLOR := Color(0.45, 0.85, 1, 1)
const ENEMY_LEG_DOUBLE_JUMPS := 1

const THROWN_BODY_PART_SCENE := preload("res://scenes/legacy/body_parts/ThrownBodyPart.tscn")
const FLOATING_FEEDBACK_MESSAGE_SCENE := preload("res://scenes/ui/FloatingFeedbackMessage.tscn")

var facing_direction := 1
var is_rolling := false
var is_forced_tunnel_roll := false
var roll_time_left := 0.0
var roll_cooldown_left := 0.0
var has_sword := false
var has_axe := false
var is_sword_attacking := false
var sword_attack_phase := ""
var sword_attack_phase_time_left := 0.0
var sword_hit_targets := []
var has_shield := false
var is_using_shield := false
var shield_use_time_left := 0.0
var shield_parry_time_left := 0.0
var health := STARTING_HEALTH
var double_jumps_left := 0
var is_dead := false

var has_head := true
var has_left_arm := true
var has_right_arm := true
var has_left_leg := true
var has_right_leg := true

var head_part_id := "skeleton_head"
var left_arm_part_id := "skeleton_left_arm"
var right_arm_part_id := "skeleton_right_arm"
var left_leg_part_id := "skeleton_left_leg"
var right_leg_part_id := "skeleton_right_leg"
var left_arm_part_color := SKELETON_ARM_COLOR
var right_arm_part_color := SKELETON_ARM_COLOR
var left_leg_part_color := SKELETON_LEG_COLOR
var right_leg_part_color := SKELETON_LEG_COLOR

var previous_key_states := {}

@onready var body_parts: Node2D = $BodyParts
@onready var head: ColorRect = $BodyParts/Head
@onready var torso: ColorRect = $BodyParts/Torso
@onready var left_arm: ColorRect = $BodyParts/LeftArm
@onready var right_arm: ColorRect = $BodyParts/RightArm
@onready var left_leg: ColorRect = $BodyParts/LeftLeg
@onready var right_leg: ColorRect = $BodyParts/RightLeg
@onready var sword_visual: ColorRect = $BodyParts/SwordVisual
@onready var shield_visual: ColorRect = $BodyParts/ShieldVisual
@onready var sword_icon: ColorRect = $HUD/SwordIcon
@onready var axe_icon: ColorRect = $HUD/AxeIcon
@onready var shield_icon: ColorRect = $HUD/ShieldIcon
@onready var health_bar: ColorRect = $HUD/HealthBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	handle_detach_input()
	update_sword_attack(delta)
	update_shield_use(delta)
	update_roll_state(delta)

	if is_on_floor():
		double_jumps_left = get_max_double_jumps()

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction := get_move_direction()

	if not is_rolling:
		if direction != 0.0:
			facing_direction = int(signf(direction))
			update_body_parts_scale()

	if is_key_just_pressed(KEY_SPACE):
		try_jump()

	update_body_pose()

	if is_rolling:
		velocity.x = facing_direction * get_current_roll_speed()
	else:
		velocity.x = direction * get_current_speed()
		if is_sword_attacking:
			velocity.x *= get_weapon_attack_move_multiplier()

	move_and_slide()


func handle_detach_input() -> void:
	if is_key_just_pressed(KEY_1):
		detach_left_arm()
	if is_key_just_pressed(KEY_2):
		detach_right_arm()
	if is_key_just_pressed(KEY_3):
		sacrifice_leg()
	if is_key_just_pressed(KEY_5):
		detach_head()
	if is_key_just_pressed(KEY_J):
		attack_with_sword()
	if is_key_just_pressed(KEY_K):
		use_shield()


func is_key_just_pressed(key: Key) -> bool:
	var is_pressed := Input.is_key_pressed(key)
	var was_pressed: bool = previous_key_states.get(key, false)

	previous_key_states[key] = is_pressed

	return is_pressed and not was_pressed


func get_move_direction() -> float:
	var direction := 0.0

	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction += 1.0

	return direction


func update_roll_state(delta: float) -> void:
	if roll_cooldown_left > 0.0:
		roll_cooldown_left -= delta

	if is_rolling:
		roll_time_left -= delta

		if roll_time_left <= 0.0:
			if can_stop_roll():
				stop_roll()
			else:
				is_forced_tunnel_roll = true

		return

	if is_key_just_pressed(KEY_SHIFT) and can_roll():
		start_roll()


func can_roll() -> bool:
	return get_leg_count() > 0 and roll_cooldown_left <= 0.0


func is_door_smashing_roll() -> bool:
	return is_rolling and not is_dead


func start_roll() -> void:
	var direction := get_move_direction()

	if direction != 0.0:
		facing_direction = int(signf(direction))
		update_body_parts_scale()

	is_rolling = true
	is_forced_tunnel_roll = false
	if is_on_floor():
		roll_time_left = ROLL_DURATION
	else:
		roll_time_left = AIR_ROLL_DURATION
	roll_cooldown_left = ROLL_COOLDOWN


func stop_roll() -> void:
	is_rolling = false
	is_forced_tunnel_roll = false
	roll_time_left = 0.0


func get_current_roll_speed() -> float:
	if is_forced_tunnel_roll:
		return FORCED_TUNNEL_ROLL_SPEED

	if get_leg_count() == 1:
		return ROLL_SPEED * ONE_LEG_ROLL_SPEED_MULTIPLIER

	return ROLL_SPEED


func can_stop_roll() -> bool:
	if not is_rolling:
		return true

	return can_fit_collision_shape(NORMAL_COLLISION_SIZE, NORMAL_COLLISION_POSITION)


func can_fit_collision_shape(shape_size: Vector2, shape_position: Vector2) -> bool:
	var test_shape := RectangleShape2D.new()
	test_shape.size = shape_size

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = test_shape
	query.transform = Transform2D(0.0, global_position + shape_position)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask

	var results := get_world_2d().direct_space_state.intersect_shape(query, 1)
	return results.is_empty()


func get_current_speed() -> float:
	var leg_count := get_leg_count()

	if leg_count == 1:
		return SPEED * ONE_LEG_SPEED_MULTIPLIER
	if leg_count == 0:
		return SPEED * NO_LEGS_SPEED_MULTIPLIER

	return SPEED


func get_current_jump_velocity() -> float:
	var leg_count := get_leg_count()

	if leg_count == 1:
		return JUMP_VELOCITY * ONE_LEG_JUMP_MULTIPLIER
	if leg_count == 0:
		return CRAWLER_JUMP_VELOCITY

	return JUMP_VELOCITY


func try_jump() -> void:
	if not can_stop_roll():
		return

	if is_on_floor():
		velocity.y = get_current_jump_velocity()
		stop_roll()
		return

	if can_double_jump():
		velocity.y = DOUBLE_JUMP_VELOCITY
		double_jumps_left -= 1
		stop_roll()


func can_double_jump() -> bool:
	return has_enemy_legs() and get_leg_count() > 0 and double_jumps_left > 0


func get_max_double_jumps() -> int:
	if has_enemy_legs():
		return ENEMY_LEG_DOUBLE_JUMPS

	return 0


func has_enemy_legs() -> bool:
	return has_left_leg and has_right_leg and left_leg_part_id.begins_with("enemy_") and right_leg_part_id.begins_with("enemy_")


func get_leg_count() -> int:
	var count := 0

	if has_left_leg:
		count += 1
	if has_right_leg:
		count += 1

	return count


func update_body_pose() -> void:
	var collision_rectangle := collision_shape.shape as RectangleShape2D

	if is_rolling:
		body_parts.position = ROLL_BODY_PARTS_POSITION
		update_body_parts_scale()
		collision_shape.position = ROLL_COLLISION_POSITION
		collision_rectangle.size = ROLL_COLLISION_SIZE
	elif get_leg_count() == 0:
		body_parts.position = CRAWLER_BODY_PARTS_POSITION
		update_body_parts_scale()
		collision_shape.position = CRAWLER_COLLISION_POSITION
		collision_rectangle.size = CRAWLER_COLLISION_SIZE
	else:
		body_parts.position = NORMAL_BODY_PARTS_POSITION
		update_body_parts_scale()
		collision_shape.position = NORMAL_COLLISION_POSITION
		collision_rectangle.size = NORMAL_COLLISION_SIZE


func update_body_parts_scale() -> void:
	if is_rolling:
		body_parts.scale = Vector2(facing_direction, ROLL_BODY_PARTS_SCALE_Y)
	else:
		body_parts.scale = Vector2(facing_direction, NORMAL_BODY_PARTS_SCALE_Y)


func pickup_sword() -> bool:
	return exchange_main_weapon("sword") != "blocked"


func pickup_axe() -> bool:
	return exchange_main_weapon("axe") != "blocked"


func exchange_main_weapon(new_weapon_type: String) -> String:
	if not has_right_arm:
		show_feedback_message("Need right arm")
		return "blocked"
	if not can_use_main_weapon(new_weapon_type):
		show_feedback_message("Need enemy arm")
		return "blocked"

	var old_weapon_type := get_main_weapon_type()
	equip_main_weapon(new_weapon_type)
	return old_weapon_type


func equip_main_weapon(weapon_type: String) -> void:
	has_sword = weapon_type == "sword"
	has_axe = weapon_type == "axe"
	sword_icon.visible = has_sword
	axe_icon.visible = has_axe


func can_use_main_weapon(weapon_type: String) -> bool:
	var weapon_weight := get_weapon_weight(weapon_type)

	if weapon_weight == "heavy":
		return has_strong_right_arm()

	return true


func get_weapon_weight(weapon_type: String) -> String:
	if weapon_type == "axe":
		return "heavy"

	return "light"


func has_strong_right_arm() -> bool:
	return has_right_arm and right_arm_part_id.begins_with("enemy_")


func can_attack_with_sword() -> bool:
	return has_main_weapon() and has_right_arm and can_use_main_weapon(get_main_weapon_type()) and not is_sword_attacking


func attack_with_sword() -> void:
	if not can_attack_with_sword():
		return

	is_sword_attacking = true
	sword_attack_phase = "startup"
	sword_attack_phase_time_left = get_weapon_startup_duration()
	sword_hit_targets.clear()
	update_weapon_visual_shape()
	sword_visual.color = get_weapon_startup_color()
	sword_visual.show()


func update_sword_attack(delta: float) -> void:
	if not is_sword_attacking:
		return

	if not has_main_weapon() or not has_right_arm or not can_use_main_weapon(get_main_weapon_type()):
		stop_sword_attack()
		return

	sword_attack_phase_time_left -= delta

	if sword_attack_phase == "startup" and sword_attack_phase_time_left <= 0.0:
		start_sword_active_phase()
	elif sword_attack_phase == "active":
		apply_sword_damage()

		if sword_attack_phase_time_left <= 0.0:
			start_sword_recovery_phase()
	elif sword_attack_phase == "recovery" and sword_attack_phase_time_left <= 0.0:
		stop_sword_attack()


func start_sword_active_phase() -> void:
	sword_attack_phase = "active"
	sword_attack_phase_time_left = get_weapon_active_duration()
	sword_visual.color = get_weapon_active_color()


func start_sword_recovery_phase() -> void:
	sword_attack_phase = "recovery"
	sword_attack_phase_time_left = get_weapon_recovery_duration()
	sword_visual.color = get_weapon_recovery_color()


func stop_sword_attack() -> void:
	is_sword_attacking = false
	sword_attack_phase = ""
	sword_attack_phase_time_left = 0.0
	sword_hit_targets.clear()
	sword_visual.hide()


func apply_sword_damage() -> void:
	var hitbox_shape := RectangleShape2D.new()
	hitbox_shape.size = get_weapon_hitbox_size()

	var weapon_hitbox_offset := get_weapon_hitbox_offset()
	var hitbox_center := global_position + Vector2(weapon_hitbox_offset.x * facing_direction, weapon_hitbox_offset.y)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = hitbox_shape
	query.transform = Transform2D(0.0, hitbox_center)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results := get_world_2d().direct_space_state.intersect_shape(query, 8)

	for result in results:
		var body := result["collider"] as Node

		if body != null and body.has_method("take_damage") and not sword_hit_targets.has(body):
			sword_hit_targets.append(body)
			body.call("take_damage", get_weapon_attack_damage())
			apply_weapon_hit_effect(body)


func has_main_weapon() -> bool:
	return has_sword or has_axe


func apply_weapon_hit_effect(target: Node) -> void:
	if has_axe and target.has_method("stun"):
		target.call("stun")


func get_main_weapon_type() -> String:
	if has_axe:
		return "axe"
	if has_sword:
		return "sword"

	return ""


func clear_main_weapon() -> void:
	has_sword = false
	has_axe = false
	sword_icon.hide()
	axe_icon.hide()


func get_weapon_attack_damage() -> int:
	if has_axe:
		return AXE_ATTACK_DAMAGE

	return SWORD_ATTACK_DAMAGE


func get_weapon_startup_duration() -> float:
	if has_axe:
		return AXE_STARTUP_DURATION

	return SWORD_STARTUP_DURATION


func get_weapon_active_duration() -> float:
	if has_axe:
		return AXE_ACTIVE_DURATION

	return SWORD_ACTIVE_DURATION


func get_weapon_recovery_duration() -> float:
	if has_axe:
		return AXE_RECOVERY_DURATION

	return SWORD_RECOVERY_DURATION


func get_weapon_attack_move_multiplier() -> float:
	if has_axe:
		return AXE_ATTACK_MOVE_MULTIPLIER

	return SWORD_ATTACK_MOVE_MULTIPLIER


func get_weapon_hitbox_size() -> Vector2:
	if has_axe:
		return AXE_HITBOX_SIZE

	return SWORD_HITBOX_SIZE


func get_weapon_hitbox_offset() -> Vector2:
	if has_axe:
		return AXE_HITBOX_OFFSET

	return SWORD_HITBOX_OFFSET


func get_weapon_startup_color() -> Color:
	if has_axe:
		return Color(0.62, 0.45, 0.25, 1)

	return Color(0.85, 0.87, 0.92, 1)


func get_weapon_active_color() -> Color:
	if has_axe:
		return Color(0.95, 0.75, 0.38, 1)

	return Color(1, 1, 1, 1)


func get_weapon_recovery_color() -> Color:
	if has_axe:
		return Color(0.35, 0.25, 0.16, 1)

	return Color(0.55, 0.58, 0.64, 1)


func update_weapon_visual_shape() -> void:
	if has_axe:
		sword_visual.offset_left = 22.0
		sword_visual.offset_top = -72.0
		sword_visual.offset_right = 82.0
		sword_visual.offset_bottom = -40.0
		return

	sword_visual.offset_left = 24.0
	sword_visual.offset_top = -60.0
	sword_visual.offset_right = 76.0
	sword_visual.offset_bottom = -52.0


func pickup_shield() -> bool:
	if not has_left_arm:
		show_feedback_message("Need left arm")
		return false

	has_shield = true
	shield_icon.show()
	return true


func can_use_shield() -> bool:
	return has_shield and has_left_arm


func use_shield() -> void:
	if not can_use_shield():
		return

	is_using_shield = true
	shield_use_time_left = SHIELD_USE_DURATION
	shield_parry_time_left = SHIELD_PARRY_DURATION
	shield_visual.color = SHIELD_PARRY_COLOR
	shield_visual.show()


func update_shield_use(delta: float) -> void:
	if not is_using_shield:
		return

	if not can_use_shield():
		stop_shield_use()
		return

	shield_use_time_left -= delta
	shield_parry_time_left -= delta

	if shield_parry_time_left <= 0.0:
		shield_visual.color = SHIELD_BLOCK_COLOR

	if shield_use_time_left <= 0.0:
		stop_shield_use()


func stop_shield_use() -> void:
	is_using_shield = false
	shield_use_time_left = 0.0
	shield_parry_time_left = 0.0
	shield_visual.hide()


func is_shield_blocking() -> bool:
	return is_using_shield and can_use_shield()


func is_shield_parrying() -> bool:
	return is_shield_blocking() and shield_parry_time_left > 0.0


func take_player_damage(amount: int, attacker: Variant = null) -> void:
	if is_dead:
		return

	if is_shield_parrying():
		if is_instance_valid(attacker) and attacker.has_method("take_damage"):
			attacker.call("take_damage", 1)
		return

	if is_shield_blocking():
		return

	health = maxi(health - amount, 0)
	update_health_bar()

	if health <= 0:
		die()


func update_health_bar() -> void:
	var health_ratio := float(health) / float(STARTING_HEALTH)
	health_bar.size.x = 80.0 * health_ratio


func show_feedback_message(message: String) -> void:
	var feedback_message := FLOATING_FEEDBACK_MESSAGE_SCENE.instantiate()

	feedback_message.setup(message)
	get_tree().current_scene.add_child(feedback_message)
	feedback_message.global_position = global_position + Vector2(0, -118)


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	stop_sword_attack()
	stop_shield_use()
	stop_roll()
	clear_main_weapon()
	has_shield = false
	shield_icon.hide()
	spawn_death_pieces()
	body_parts.hide()
	collision_shape.set_deferred("disabled", true)
	show_feedback_message("You died")


func spawn_death_pieces() -> void:
	if has_head:
		spawn_death_piece(head.global_position, head.color, HEAD_DEATH_PIECE_SIZE, Vector2(20, -180))

	spawn_death_piece(torso.global_position, torso.color, TORSO_DEATH_PIECE_SIZE, Vector2(0, -80))

	if has_left_arm:
		spawn_death_piece(left_arm.global_position, left_arm_part_color, ARM_DEATH_PIECE_SIZE, Vector2(-180, -130))
	if has_right_arm:
		spawn_death_piece(right_arm.global_position, right_arm_part_color, ARM_DEATH_PIECE_SIZE, Vector2(180, -130))
	if has_left_leg:
		spawn_death_piece(left_leg.global_position, left_leg_part_color, LEG_DEATH_PIECE_SIZE, Vector2(-90, -70))
	if has_right_leg:
		spawn_death_piece(right_leg.global_position, right_leg_part_color, LEG_DEATH_PIECE_SIZE, Vector2(90, -70))


func spawn_death_piece(piece_position: Vector2, piece_color: Color, piece_size: Vector2, launch_velocity: Vector2) -> void:
	var death_piece := THROWN_BODY_PART_SCENE.instantiate()

	get_tree().current_scene.add_child(death_piece)
	death_piece.global_position = piece_position
	death_piece.setup_death_piece(piece_color, piece_size, launch_velocity)


func detach_left_arm() -> void:
	if not has_left_arm:
		return

	var carried_item_type := ""
	if has_shield:
		carried_item_type = "shield"
		has_shield = false
		shield_icon.hide()

	has_left_arm = false
	left_arm.hide()
	stop_shield_use()
	throw_body_part("left_arm", left_arm_part_id, left_arm_part_color, carried_item_type)


func detach_right_arm() -> void:
	if not has_right_arm:
		return

	var carried_item_type := get_main_weapon_type()
	if carried_item_type != "":
		clear_main_weapon()

	has_right_arm = false
	right_arm.hide()
	stop_sword_attack()
	throw_body_part("right_arm", right_arm_part_id, right_arm_part_color, carried_item_type)


func sacrifice_leg() -> void:
	if has_enemy_legs():
		show_feedback_message("Enemy legs cannot detach")
		return

	var leg_count := get_leg_count()

	if leg_count == 0:
		return

	if has_left_leg:
		detach_left_leg()
		drop_body_part("left_leg", left_leg_part_id, left_leg_part_color)
	else:
		detach_right_leg()
		drop_body_part("right_leg", right_leg_part_id, right_leg_part_color)

	if leg_count == 2:
		velocity.y = FIRST_LEG_SACRIFICE_JUMP
	else:
		velocity.y = LAST_LEG_SACRIFICE_JUMP


func detach_left_leg() -> void:
	if not has_left_leg:
		return

	has_left_leg = false
	double_jumps_left = 0
	left_leg.hide()


func detach_right_leg() -> void:
	if not has_right_leg:
		return

	has_right_leg = false
	double_jumps_left = 0
	right_leg.hide()


func detach_head() -> void:
	if not has_head:
		return

	has_head = false
	head.hide()


func obtain_enemy_arm() -> void:
	has_right_arm = true
	right_arm_part_id = "enemy_right_arm"
	right_arm_part_color = ENEMY_ARM_COLOR
	right_arm.color = right_arm_part_color
	right_arm.show()
	print("Obtained enemy arm")


func obtain_enemy_leg() -> void:
	has_left_leg = true
	has_right_leg = true
	left_leg_part_id = "enemy_left_leg"
	right_leg_part_id = "enemy_right_leg"
	left_leg_part_color = ENEMY_LEG_COLOR
	right_leg_part_color = ENEMY_LEG_COLOR
	left_leg.color = left_leg_part_color
	right_leg.color = right_leg_part_color
	left_leg.show()
	right_leg.show()
	double_jumps_left = get_max_double_jumps()
	print("Obtained enemy legs")


func recover_body_part(body_part_type: String, carried_item_type: String = "", body_part_id: String = "", body_part_color: Color = Color(-1, -1, -1, -1)) -> bool:
	if body_part_type == "left_arm" and not has_left_arm:
		has_left_arm = true
		if body_part_id != "":
			left_arm_part_id = body_part_id
		if body_part_color.a >= 0.0:
			left_arm_part_color = body_part_color
			left_arm.color = left_arm_part_color
		left_arm.show()
		recover_carried_item(carried_item_type)
		print("Recovered ", left_arm_part_id)
		return true

	if body_part_type == "right_arm" and not has_right_arm:
		has_right_arm = true
		if body_part_id != "":
			right_arm_part_id = body_part_id
		if body_part_color.a >= 0.0:
			right_arm_part_color = body_part_color
			right_arm.color = right_arm_part_color
		right_arm.show()
		recover_carried_item(carried_item_type)
		print("Recovered ", right_arm_part_id)
		return true

	if body_part_type == "left_leg" and not has_left_leg:
		has_left_leg = true
		if body_part_id != "":
			left_leg_part_id = body_part_id
		if body_part_color.a >= 0.0:
			left_leg_part_color = body_part_color
			left_leg.color = left_leg_part_color
		left_leg.show()
		print("Recovered ", left_leg_part_id)
		return true

	if body_part_type == "right_leg" and not has_right_leg:
		has_right_leg = true
		if body_part_id != "":
			right_leg_part_id = body_part_id
		if body_part_color.a >= 0.0:
			right_leg_part_color = body_part_color
			right_leg.color = right_leg_part_color
		right_leg.show()
		print("Recovered ", right_leg_part_id)
		return true

	return false


func recover_carried_item(carried_item_type: String) -> void:
	if carried_item_type == "sword":
		has_sword = true
		has_axe = false
		sword_icon.show()
		axe_icon.hide()
	elif carried_item_type == "axe":
		has_axe = true
		has_sword = false
		axe_icon.show()
		sword_icon.hide()
	elif carried_item_type == "shield":
		has_shield = true
		shield_icon.show()


func get_throw_damage(carried_item_type: String) -> int:
	var throw_damage := ARM_THROW_DAMAGE

	if carried_item_type == "sword":
		throw_damage += SWORD_ATTACK_DAMAGE
	elif carried_item_type == "axe":
		throw_damage += AXE_ATTACK_DAMAGE
	elif carried_item_type == "shield":
		throw_damage += SHIELD_THROW_DAMAGE_BONUS

	return throw_damage


func throw_body_part(body_part_type: String, body_part_id: String, part_color: Color, carried_item_type: String = "") -> void:
	var thrown_part := THROWN_BODY_PART_SCENE.instantiate()
	var throw_direction := Vector2(facing_direction, 0)
	var throw_damage := get_throw_damage(carried_item_type)

	thrown_part.setup(throw_direction, part_color, throw_damage, body_part_type, carried_item_type, body_part_id)
	get_tree().current_scene.add_child(thrown_part)
	thrown_part.global_position = global_position + Vector2(ARM_THROW_OFFSET.x * facing_direction, ARM_THROW_OFFSET.y)


func drop_body_part(body_part_type: String, body_part_id: String, part_color: Color) -> void:
	var dropped_part := THROWN_BODY_PART_SCENE.instantiate()

	dropped_part.setup_dropped(part_color, body_part_type, "", body_part_id)
	get_tree().current_scene.add_child(dropped_part)
	dropped_part.global_position = global_position + LEG_DROP_OFFSET
