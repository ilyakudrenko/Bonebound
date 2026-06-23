extends CharacterBody2D

const SPEED := 120.0
const JUMP_VELOCITY := -285.0
const DOUBLE_JUMP_VELOCITY := -260.0
const GRAVITY := 800.0
const ONE_LEG_SPEED_MULTIPLIER := 0.65
const NO_LEGS_SPEED_MULTIPLIER := 0.25
const ONE_LEG_JUMP_MULTIPLIER := 0.75
const CRAWLER_JUMP_VELOCITY := -110.0
const FIRST_LEG_SACRIFICE_JUMP := -390.0
const LAST_LEG_SACRIFICE_JUMP := -290.0
const LADDER_CLIMB_UP_SPEED := 80.0
const LADDER_SLIDE_DOWN_SPEED := 24.0
const LADDER_DESCEND_SPEED := 96.0
const ARM_THROW_DAMAGE := 1
const ARM_THROW_OFFSET := Vector2(18, -26)
const LEG_DROP_OFFSET := Vector2(0, -6)
const NORMAL_BODY_PARTS_POSITION := Vector2.ZERO
const CRAWLER_BODY_PARTS_POSITION := Vector2(0, 16)
const NORMAL_COLLISION_POSITION := Vector2(0, -24)
const CRAWLER_COLLISION_POSITION := Vector2(0, -16)
const ROLL_COLLISION_POSITION := Vector2(0, -10)
const NORMAL_COLLISION_SIZE := Vector2(20, 48)
const CRAWLER_COLLISION_SIZE := Vector2(20, 32)
const ROLL_COLLISION_SIZE := Vector2(24, 20)
const ROLL_BODY_PARTS_POSITION := Vector2.ZERO
const NORMAL_BODY_PARTS_SCALE_Y := 1.0
const ROLL_BODY_PARTS_SCALE_Y := 0.42
const ROLL_SPEED := 220.0
const FORCED_TUNNEL_ROLL_SPEED := 150.0
const ONE_LEG_ROLL_SPEED_MULTIPLIER := 0.65
const ROLL_DURATION := 0.32
const AIR_ROLL_DURATION := 0.42
const ROLL_COOLDOWN := 0.45
const SWORD_BATTLE_RHYTHM_DEFAULT_HITS_REQUIRED := 3
const SWORD_BATTLE_RHYTHM_DEFAULT_CRITICAL_MULTIPLIER := 2.0
const DUELIST_MOMENTUM_DEFAULT_DURATION := 2.0
const DUELIST_MOMENTUM_DEFAULT_SPEED_MULTIPLIER := 1.2
const DUELIST_MOMENTUM_DEFAULT_ROLL_MULTIPLIER := 1.2
const SHIELD_USE_DURATION := 0.35
const SHIELD_PARRY_DURATION := 0.14
const SHIELD_COOLDOWN := 0.35
const PERFECT_PARRY_DEFAULT_DAMAGE_MULTIPLIER := 1.1
const PERFECT_PARRY_DEFAULT_DAMAGE_DURATION := 3.0
const BASIC_SHIELD_TYPE := ItemDatabase.SHIELD_BASIC
const BONE_MIRROR_SHIELD_TYPE := ItemDatabase.SHIELD_BONE_MIRROR
const SPIKED_SHIELD_TYPE := ItemDatabase.SHIELD_SPIKED
const STARTING_HEALTH := 5
const PLAYER_STUN_DURATION := 0.55
const PLAYER_STUN_COLOR := Color(0.25, 0.45, 1.0, 1)
const HAZARD_COLLISION_MASK := 16
const SPIKE_DAMAGE := 1
const SPIKE_DAMAGE_COOLDOWN := 0.75
const HEAD_DEATH_PIECE_SIZE := Vector2(12, 12)
const TORSO_DEATH_PIECE_SIZE := Vector2(14, 20)
const ARM_DEATH_PIECE_SIZE := Vector2(6, 18)
const LEG_DEATH_PIECE_SIZE := Vector2(6, 16)
const SKELETON_ARM_COLOR := Color(1, 0.05, 0.05, 1)
const SKELETON_LEG_COLOR := Color(0.05, 0.85, 0.15, 1)
const ENEMY_ARM_COLOR := Color(1, 0.35, 0.75, 1)
const ENEMY_LEG_COLOR := Color(0.45, 0.85, 1, 1)
const ENEMY_LEG_DOUBLE_JUMPS := 1
const STOMP_LEG_COLOR := Color(0.65, 0.35, 1, 1)
const GROUND_SLAM_SPEED := 760.0
const GROUND_SLAM_DAMAGE := 2
const GROUND_SLAM_RADIUS := 52.0
const GROUND_SLAM_STUN_DURATION := 0.75
const GROUND_SLAM_KNOCKBACK := 18.0
const GROUND_SLAM_KNOCKBACK_STEP := 3.0
const GROUND_SLAM_COOLDOWN := 4.0
const SPIDER_LEG_COLOR := Color(0.18, 0.95, 0.65, 1)
const SPIDER_WALL_CLIMB_SPEED := 150.0
const SPIDER_WALL_CLIMB_DURATION := 0.35
const SPIDER_WALL_CLIMB_COOLDOWN := 0.18
const SPIDER_WALL_CHECK_DISTANCE := 16.0
const SPIDER_WALL_BODY_OFFSET := Vector2(0, -24)
const SPIDER_WALL_HOP_VELOCITY := -265.0
const SPIDER_WALL_HOP_HORIZONTAL_SPEED := 155.0
const SPIDER_WALL_HOP_DURATION := 0.18
const SPIDER_WALL_HOP_COOLDOWN := 0.35
const SPIDER_WALL_HOP_WINDOW := 0.14
const SPIDER_LEDGE_BOOST_VELOCITY := -220.0
const SPIDER_LEDGE_BOOST_HORIZONTAL_SPEED := 95.0
const SPIDER_LEDGE_BOOST_DURATION := 0.16
const SPIDER_DAMAGE_FALL_SPEED := 170.0
const SPIDER_DAMAGE_CLIMB_LOCKOUT := 0.45
const BOOMERANG_ARM_COLOR := Color(0.95, 0.55, 0.1, 1)
const BOOMERANG_ARM_THROW_COOLDOWN := 3.0
const BOOMERANG_ARM_USE_COOLDOWN := 0.8
const HARPOON_ARM_COLOR := Color(0.72, 0.72, 0.78, 1)
const HARPOON_ARM_THROW_COOLDOWN := 3.5
const SOUL_STACK_PIP_SIZE := Vector2(10, 8)
const SOUL_STACK_FILLED_COLOR := Color(0.58, 0.22, 0.95, 1)
const SOUL_STACK_EMPTY_COLOR := Color(0.16, 0.08, 0.24, 0.9)
const SWIFT_BONE_DEFAULT_SPEED_MULTIPLIER := 1.2
const SWIFT_BONE_DEFAULT_ROLL_MULTIPLIER := 1.2

const THROWN_BODY_PART_SCENE := preload("res://scenes/scaled/body_parts/ThrownBodyPart_16px.tscn")
const FLOATING_FEEDBACK_MESSAGE_SCENE := preload("res://scenes/ui/FloatingFeedbackMessage.tscn")

var facing_direction := 1
var is_rolling := false
var is_forced_tunnel_roll := false
var roll_time_left := 0.0
var roll_cooldown_left := 0.0
var has_sword := false
var has_axe := false
var has_rapier := false
var has_bone_cleaver := false
var has_soul_harvester := false
var main_weapon_rarity := ItemDatabase.RARITY_COMMON
var soul_harvester_stacks := 0
var is_sword_attacking := false
var sword_attack_phase := ""
var sword_attack_phase_time_left := 0.0
var sword_hit_targets := []
var is_rapier_riposte_ready := false
var rapier_riposte_time_left := 0.0
var is_current_attack_critical := false
var sword_battle_rhythm_hits := 0
var is_sword_battle_rhythm_critical_ready := false
var duelist_momentum_time_left := 0.0
var has_shield := false
var shield_type := BASIC_SHIELD_TYPE
var shield_rarity := ItemDatabase.RARITY_COMMON
var is_using_shield := false
var shield_use_time_left := 0.0
var shield_parry_time_left := 0.0
var shield_cooldown_left := 0.0
var skip_next_shield_cooldown := false
var perfect_parry_damage_buff_time_left := 0.0
var health := STARTING_HEALTH
var double_jumps_left := 0
var is_dead := false
var is_player_stunned := false
var player_stun_time_left := 0.0
var ladder_overlap_count := 0
var is_climbing_ladder := false
var spike_damage_cooldown_left := 0.0
var left_arm_throw_cooldown_left := 0.0
var right_arm_throw_cooldown_left := 0.0
var left_arm_use_cooldown_left := 0.0
var right_arm_use_cooldown_left := 0.0
var is_ground_slamming := false
var ground_slam_cooldown_left := 0.0
var is_spider_wall_climbing := false
var spider_wall_climb_time_left := 0.0
var spider_wall_climb_cooldown_left := 0.0
var spider_wall_direction := 0
var is_spider_wall_hopping := false
var spider_wall_hop_time_left := 0.0
var spider_wall_hop_cooldown_left := 0.0
var spider_wall_hop_direction := 0
var swift_bone_time_left := 0.0

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
@onready var sword_icon: TextureRect = $HUD/SwordIcon
@onready var axe_icon: TextureRect = $HUD/AxeIcon
@onready var rapier_icon: TextureRect = $HUD/RapierIcon
@onready var bone_cleaver_icon: TextureRect = $HUD/BoneCleaverIcon
@onready var soul_harvester_icon: TextureRect = $HUD/SoulHarvesterIcon
@onready var shield_icon: TextureRect = $HUD/ShieldIcon
@onready var bone_mirror_icon: TextureRect = $HUD/BoneMirrorIcon
@onready var spiked_shield_icon: TextureRect = $HUD/SpikedShieldIcon
@onready var health_bar: ColorRect = $HUD/HealthBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var soul_stack_label: Label = $HUD/SoulStackLabel
@onready var soul_stack_pips: HBoxContainer = $HUD/SoulStackPips
@onready var soul_aura: ColorRect = $BodyParts/SoulAura


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	update_player_stun(delta)
	if is_player_stunned:
		record_current_action_key_states()
		if not is_on_floor():
			velocity.y += GRAVITY * delta

		velocity.x = 0.0
		update_body_pose()
		move_and_slide()
		check_spike_hazards()
		return

	update_shield_cooldown(delta)
	update_perfect_parry_damage_buff(delta)
	handle_detach_input()
	update_sword_attack(delta)
	update_shield_use(delta)
	update_roll_state(delta)
	update_hazard_damage_cooldown(delta)
	update_arm_throw_cooldowns(delta)
	update_rapier_riposte(delta)
	update_duelist_momentum(delta)
	update_swift_bone(delta)
	update_ground_slam_cooldown(delta)
	update_spider_wall_climb(delta)
	update_spider_wall_hop(delta)

	if is_on_floor():
		double_jumps_left = get_max_double_jumps()

	var direction := get_move_direction()
	var wants_ladder_climb := wants_to_use_ladder()

	handle_ground_slam_input()

	if can_start_ladder_climb() and wants_ladder_climb:
		start_ladder_climb()

	if is_climbing_ladder and ladder_overlap_count <= 0:
		stop_ladder_climb()

	if not is_on_floor() and not is_climbing_ladder:
		velocity.y += GRAVITY * delta

	if not is_rolling:
		if direction != 0.0:
			facing_direction = int(signf(direction))
			update_body_parts_scale()

	if is_key_just_pressed(KEY_SPACE):
		if not is_climbing_ladder:
			try_jump()

	update_body_pose()

	if is_ground_slamming:
		velocity.x = 0.0
		velocity.y = GROUND_SLAM_SPEED
	elif is_spider_wall_climbing:
		velocity.x = spider_wall_direction * 10.0
		velocity.y = -SPIDER_WALL_CLIMB_SPEED
	elif is_spider_wall_hopping:
		velocity.x = spider_wall_hop_direction * SPIDER_WALL_HOP_HORIZONTAL_SPEED
	elif is_rolling:
		velocity.x = facing_direction * get_current_roll_speed()
	elif is_climbing_ladder:
		velocity.x = direction * get_current_speed()
		velocity.y = get_ladder_vertical_speed()
	else:
		velocity.x = direction * get_current_speed()
		if is_sword_attacking:
			velocity.x *= get_weapon_attack_move_multiplier()

	move_and_slide()

	if is_ground_slamming and is_on_floor():
		finish_ground_slam()

	check_spike_hazards()


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


func record_current_action_key_states() -> void:
	for key in [KEY_1, KEY_2, KEY_3, KEY_5, KEY_J, KEY_K, KEY_SHIFT, KEY_SPACE, KEY_S]:
		previous_key_states[key] = Input.is_key_pressed(key)


func get_move_direction() -> float:
	var direction := 0.0

	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction += 1.0

	return direction


func wants_to_use_ladder() -> bool:
	return Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_S)


func get_ladder_vertical_speed() -> float:
	if Input.is_key_pressed(KEY_S):
		return LADDER_DESCEND_SPEED
	if Input.is_key_pressed(KEY_SPACE):
		return -LADDER_CLIMB_UP_SPEED

	return LADDER_SLIDE_DOWN_SPEED


func enter_ladder_area() -> void:
	ladder_overlap_count += 1


func exit_ladder_area() -> void:
	ladder_overlap_count = maxi(ladder_overlap_count - 1, 0)

	if ladder_overlap_count == 0:
		stop_ladder_climb()


func can_start_ladder_climb() -> bool:
	return ladder_overlap_count > 0 and not is_dead and not is_rolling and not is_ground_slamming


func start_ladder_climb() -> void:
	is_climbing_ladder = true
	velocity.y = 0.0
	stop_roll()
	stop_spider_wall_climb()
	stop_spider_wall_hop()


func stop_ladder_climb() -> void:
	is_climbing_ladder = false


func stun_player(duration: float = PLAYER_STUN_DURATION) -> void:
	if is_dead:
		return

	is_player_stunned = true
	player_stun_time_left = maxf(player_stun_time_left, duration)
	velocity.x = 0.0
	stop_sword_attack()
	stop_shield_use()
	stop_roll()
	stop_ladder_climb()
	stop_spider_wall_climb()
	stop_spider_wall_hop()
	apply_stun_visual()
	show_feedback_message("Stunned")


func update_player_stun(delta: float) -> void:
	if not is_player_stunned:
		return

	player_stun_time_left -= delta
	if player_stun_time_left <= 0.0:
		is_player_stunned = false
		player_stun_time_left = 0.0
		restore_body_part_colors()


func apply_stun_visual() -> void:
	head.color = PLAYER_STUN_COLOR
	torso.color = PLAYER_STUN_COLOR
	left_arm.color = PLAYER_STUN_COLOR
	right_arm.color = PLAYER_STUN_COLOR
	left_leg.color = PLAYER_STUN_COLOR
	right_leg.color = PLAYER_STUN_COLOR


func restore_body_part_colors() -> void:
	head.color = Color(1, 0.9, 0.05, 1)
	torso.color = Color(0.05, 0.25, 1, 1)
	left_arm.color = left_arm_part_color
	right_arm.color = right_arm_part_color
	left_leg.color = left_leg_part_color
	right_leg.color = right_leg_part_color


func jump_from_ladder() -> void:
	stop_ladder_climb()
	velocity.y = get_current_jump_velocity()


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

	var shift_was_pressed := is_key_just_pressed(KEY_SHIFT)

	if shift_was_pressed and can_roll_from_ladder():
		roll_from_ladder()
		return

	if shift_was_pressed and can_roll():
		start_roll()


func can_roll() -> bool:
	return get_leg_count() > 0 and roll_cooldown_left <= 0.0 and not is_climbing_ladder and not is_ground_slamming and not is_spider_wall_climbing and not is_spider_wall_hopping


func can_roll_from_ladder() -> bool:
	return is_climbing_ladder and get_move_direction() != 0.0 and get_leg_count() > 0 and roll_cooldown_left <= 0.0


func roll_from_ladder() -> void:
	stop_ladder_climb()
	start_roll()


func is_door_smashing_roll() -> bool:
	return is_rolling and not is_dead


func start_roll() -> void:
	var direction := get_move_direction()

	if direction != 0.0:
		facing_direction = int(signf(direction))
		update_body_parts_scale()

	is_rolling = true
	is_forced_tunnel_roll = false
	stop_spider_wall_climb()
	stop_spider_wall_hop()
	if is_on_floor():
		roll_time_left = ROLL_DURATION
	else:
		roll_time_left = AIR_ROLL_DURATION

	activate_rapier_riposte("Roll")
	roll_cooldown_left = ROLL_COOLDOWN


func stop_roll() -> void:
	is_rolling = false
	is_forced_tunnel_roll = false
	roll_time_left = 0.0


func get_current_roll_speed() -> float:
	if is_forced_tunnel_roll:
		return FORCED_TUNNEL_ROLL_SPEED

	var roll_speed := ROLL_SPEED
	if get_leg_count() == 1:
		roll_speed *= ONE_LEG_ROLL_SPEED_MULTIPLIER

	return roll_speed * get_duelist_momentum_roll_multiplier() * get_swift_bone_roll_multiplier()


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
	var current_speed := SPEED

	if leg_count == 1:
		current_speed *= ONE_LEG_SPEED_MULTIPLIER
	elif leg_count == 0:
		current_speed *= NO_LEGS_SPEED_MULTIPLIER

	return current_speed * get_duelist_momentum_speed_multiplier() * get_swift_bone_speed_multiplier()


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


func has_stomp_legs() -> bool:
	return has_left_leg and has_right_leg and left_leg_part_id.begins_with("stomp_") and right_leg_part_id.begins_with("stomp_")


func has_spider_legs() -> bool:
	return has_left_leg and has_right_leg and left_leg_part_id.begins_with("spider_") and right_leg_part_id.begins_with("spider_")


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


func pickup_sword(rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	return exchange_main_weapon(ItemDatabase.WEAPON_SWORD, rarity) != "blocked"


func pickup_axe(rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	return exchange_main_weapon(ItemDatabase.WEAPON_AXE, rarity) != "blocked"


func pickup_rapier(rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	return exchange_main_weapon(ItemDatabase.WEAPON_RAPIER, rarity) != "blocked"


func pickup_bone_cleaver(rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	return exchange_main_weapon(ItemDatabase.WEAPON_BONE_CLEAVER, rarity) != "blocked"


func pickup_soul_harvester(rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	return exchange_main_weapon(ItemDatabase.WEAPON_SOUL_HARVESTER, rarity) != "blocked"


func exchange_main_weapon(new_weapon_type: String, new_weapon_rarity: String = ItemDatabase.RARITY_COMMON) -> String:
	if not has_right_arm:
		show_feedback_message("Need right arm")
		return "blocked"
	if not can_use_main_weapon(new_weapon_type):
		show_feedback_message("Need enemy arm")
		return "blocked"

	var old_weapon_type := get_main_weapon_type()
	equip_main_weapon(new_weapon_type, new_weapon_rarity)
	return old_weapon_type


func equip_main_weapon(weapon_type: String, weapon_rarity: String = ItemDatabase.RARITY_COMMON) -> void:
	has_sword = weapon_type == ItemDatabase.WEAPON_SWORD
	has_axe = weapon_type == ItemDatabase.WEAPON_AXE
	has_rapier = weapon_type == ItemDatabase.WEAPON_RAPIER
	has_bone_cleaver = weapon_type == ItemDatabase.WEAPON_BONE_CLEAVER
	has_soul_harvester = weapon_type == ItemDatabase.WEAPON_SOUL_HARVESTER
	main_weapon_rarity = weapon_rarity
	if not has_soul_harvester:
		reset_soul_harvester_stacks()
	else:
		soul_harvester_stacks = mini(soul_harvester_stacks, get_soul_harvester_max_stacks())
	if weapon_type != ItemDatabase.WEAPON_SWORD or weapon_rarity != ItemDatabase.RARITY_LEGENDARY:
		reset_sword_battle_rhythm()
	sword_icon.visible = has_sword
	axe_icon.visible = has_axe
	rapier_icon.visible = has_rapier
	bone_cleaver_icon.visible = has_bone_cleaver
	soul_harvester_icon.visible = has_soul_harvester
	update_soul_harvester_ui()


func get_main_weapon_rarity() -> String:
	if not has_main_weapon():
		return ItemDatabase.RARITY_COMMON

	return main_weapon_rarity


func can_use_main_weapon(weapon_type: String) -> bool:
	var weapon_weight := get_weapon_weight(weapon_type)

	if weapon_weight == ItemDatabase.WEIGHT_HEAVY:
		return has_strong_right_arm()

	return true


func get_weapon_weight(weapon_type: String) -> String:
	return String(ItemDatabase.get_weapon_value(weapon_type, "weight", ItemDatabase.WEIGHT_LIGHT))


func has_strong_right_arm() -> bool:
	return has_right_arm and right_arm_part_id.begins_with("enemy_")


func can_attack_with_sword() -> bool:
	return has_main_weapon() and has_right_arm and can_use_right_arm() and can_use_main_weapon(get_main_weapon_type()) and not is_sword_attacking and not is_using_shield


func attack_with_sword() -> void:
	if is_using_shield:
		show_feedback_message("Shield up")
		return
	if not can_attack_with_sword():
		return

	is_sword_attacking = true
	sword_attack_phase = "startup"
	sword_attack_phase_time_left = get_weapon_startup_duration()
	sword_hit_targets.clear()
	is_current_attack_critical = consume_rapier_riposte_for_attack() or consume_sword_battle_rhythm_for_attack()
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
	is_current_attack_critical = false
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
			var target_was_crowd_controlled := is_target_crowd_controlled(body)
			var target_health_before := get_target_health(body)
			var hit_position := get_target_global_position(body)
			var attack_damage := get_weapon_attack_damage(body)
			if is_current_attack_critical and body.is_in_group("enemies"):
				body.call("take_damage", attack_damage, true)
			else:
				body.call("take_damage", attack_damage)

			var target_was_killed := target_health_before > 0 and get_target_health(body) <= 0
			if not target_was_killed:
				apply_weapon_hit_effect(body)
			register_weapon_hit(body)
			apply_weapon_hit_specials(body, target_was_crowd_controlled, hit_position)
			apply_weapon_kill_effects(body, target_was_crowd_controlled, target_was_killed)
			if body.is_in_group("enemies") and get_main_weapon_type() == ItemDatabase.WEAPON_RAPIER and is_current_attack_critical:
				activate_duelist_momentum()


func has_main_weapon() -> bool:
	return has_sword or has_axe or has_rapier or has_bone_cleaver or has_soul_harvester


func apply_weapon_hit_effect(target: Node) -> void:
	var weapon_type := get_main_weapon_type()
	if bool(ItemDatabase.get_weapon_value(weapon_type, "stun_on_hit", false)):
		apply_weapon_stun(target, weapon_type)
		return

	var stagger_duration := float(ItemDatabase.get_weapon_value(weapon_type, "stagger_duration", 0.0))
	if stagger_duration > 0.0 and target.has_method("stun_for_duration"):
		target.call("stun_for_duration", stagger_duration)


func get_main_weapon_type() -> String:
	if has_axe:
		return ItemDatabase.WEAPON_AXE
	if has_bone_cleaver:
		return ItemDatabase.WEAPON_BONE_CLEAVER
	if has_soul_harvester:
		return ItemDatabase.WEAPON_SOUL_HARVESTER
	if has_rapier:
		return ItemDatabase.WEAPON_RAPIER
	if has_sword:
		return ItemDatabase.WEAPON_SWORD

	return ""


func clear_main_weapon() -> void:
	has_sword = false
	has_axe = false
	has_rapier = false
	has_bone_cleaver = false
	has_soul_harvester = false
	main_weapon_rarity = ItemDatabase.RARITY_COMMON
	duelist_momentum_time_left = 0.0
	reset_sword_battle_rhythm()
	reset_soul_harvester_stacks()
	sword_icon.hide()
	axe_icon.hide()
	rapier_icon.hide()
	bone_cleaver_icon.hide()
	soul_harvester_icon.hide()
	update_soul_harvester_ui()


func get_weapon_attack_damage(target: Node = null) -> int:
	var weapon_type := get_main_weapon_type()

	if weapon_type == ItemDatabase.WEAPON_BONE_CLEAVER:
		if is_target_crowd_controlled(target):
			return get_bone_cleaver_execution_damage()
		return get_weapon_base_damage(weapon_type)
	if weapon_type == ItemDatabase.WEAPON_SOUL_HARVESTER:
		return get_soul_harvester_damage()
	if weapon_type == ItemDatabase.WEAPON_RAPIER and is_current_attack_critical:
		return get_rapier_critical_damage()
	if weapon_type == ItemDatabase.WEAPON_SWORD and is_current_attack_critical:
		return get_sword_critical_damage()

	return get_weapon_base_damage(weapon_type)


func get_weapon_base_damage(weapon_type: String) -> int:
	return get_weapon_damage_with_rarity(weapon_type, get_main_weapon_rarity())


func get_weapon_damage_with_rarity(weapon_type: String, weapon_rarity: String) -> int:
	var base_damage := float(ItemDatabase.get_weapon_value(weapon_type, "damage", 1))
	base_damage *= get_weapon_rarity_damage_multiplier(weapon_type, weapon_rarity)
	base_damage *= get_perfect_parry_damage_multiplier()
	return maxi(1, int(round(base_damage)))


func get_weapon_rarity_damage_multiplier(weapon_type: String, weapon_rarity: String) -> float:
	return float(ItemDatabase.get_item_rarity_value(weapon_type, weapon_rarity, "damage_multiplier", 1.0))


func get_weapon_rarity_attack_speed_multiplier(weapon_type: String, weapon_rarity: String) -> float:
	return float(ItemDatabase.get_item_rarity_value(weapon_type, weapon_rarity, "attack_speed_multiplier", 1.0))


func apply_weapon_stun(target: Node, weapon_type: String) -> void:
	if target == null:
		return

	var base_duration := float(ItemDatabase.get_weapon_value(weapon_type, "stun_duration", 0.0))
	var duration_multiplier := float(ItemDatabase.get_item_rarity_value(weapon_type, get_main_weapon_rarity(), "stun_duration_multiplier", 1.0))
	var stun_duration := base_duration * duration_multiplier
	if stun_duration > 0.0 and target.has_method("stun_for_duration"):
		target.call("stun_for_duration", stun_duration)
	elif target.has_method("stun"):
		target.call("stun")


func apply_weapon_hit_specials(target: Node, target_was_crowd_controlled: bool, hit_position: Vector2) -> void:
	if get_main_weapon_type() != ItemDatabase.WEAPON_AXE:
		return
	if get_main_weapon_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return
	if target == null or not target.is_in_group("enemies"):
		return
	if not target_was_crowd_controlled:
		return

	create_axe_shockwave(hit_position, target)


func create_axe_shockwave(center: Vector2, primary_target: Node) -> void:
	var radius := float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_AXE,
		get_main_weapon_rarity(),
		"shockwave_radius",
		48.0
	))
	var damage_multiplier := float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_AXE,
		get_main_weapon_rarity(),
		"shockwave_damage_multiplier",
		0.5
	))
	var shockwave_damage := maxi(1, int(round(float(get_weapon_base_damage(ItemDatabase.WEAPON_AXE)) * damage_multiplier)))
	var shockwave_shape := CircleShape2D.new()
	shockwave_shape.radius = radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shockwave_shape
	query.transform = Transform2D(0.0, center)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results := get_world_2d().direct_space_state.intersect_shape(query, 16)
	for result in results:
		var enemy := result["collider"] as Node
		if enemy == null or enemy == primary_target:
			continue
		if not enemy.is_in_group("enemies") or not enemy.has_method("take_damage"):
			continue

		enemy.call("take_damage", shockwave_damage)

	show_feedback_message("Shockwave")


func get_bone_cleaver_execution_damage() -> int:
	var weapon_type := ItemDatabase.WEAPON_BONE_CLEAVER
	var base_damage := float(ItemDatabase.get_weapon_value(weapon_type, "damage", 1))
	var damage_multiplier := get_weapon_rarity_damage_multiplier(weapon_type, get_main_weapon_rarity())
	damage_multiplier *= get_perfect_parry_damage_multiplier()
	var execution_multiplier := float(ItemDatabase.get_item_rarity_value(
		weapon_type,
		get_main_weapon_rarity(),
		"execution_damage_multiplier",
		1.5
	))
	return maxi(1, int(round(base_damage * damage_multiplier * execution_multiplier)))


func apply_weapon_kill_effects(target: Node, target_was_crowd_controlled: bool, target_was_killed: bool) -> void:
	if not target_was_killed:
		return
	if target == null or not target.is_in_group("enemies"):
		return
	if get_main_weapon_type() != ItemDatabase.WEAPON_BONE_CLEAVER:
		return
	if get_main_weapon_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return
	if not target_was_crowd_controlled:
		return

	var heal_amount := int(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_BONE_CLEAVER,
		get_main_weapon_rarity(),
		"execution_kill_heal",
		0
	))
	restore_health(heal_amount)


func restore_health(amount: int, feedback_text: String = "Execution Heal") -> void:
	if amount <= 0 or is_dead:
		return

	var previous_health := health
	health = mini(STARTING_HEALTH, health + amount)
	if health > previous_health:
		update_health_bar()
		show_feedback_message(feedback_text)


func get_target_health(target: Node) -> int:
	if target == null:
		return 0

	var health_value: Variant = target.get("health")
	if health_value == null:
		return 0

	return int(health_value)


func get_target_global_position(target: Node) -> Vector2:
	if target is Node2D:
		return (target as Node2D).global_position

	return global_position


func is_target_crowd_controlled(target: Node) -> bool:
	if target == null or not target.has_method("is_crowd_controlled"):
		return false

	return bool(target.call("is_crowd_controlled"))


func get_current_weapon_attack_speed_multiplier() -> float:
	return maxf(get_weapon_rarity_attack_speed_multiplier(get_main_weapon_type(), get_main_weapon_rarity()), 0.01)


func get_sword_critical_multiplier() -> float:
	return float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_SWORD,
		get_main_weapon_rarity(),
		"battle_rhythm_critical_multiplier",
		SWORD_BATTLE_RHYTHM_DEFAULT_CRITICAL_MULTIPLIER
	))


func get_sword_critical_damage() -> int:
	var weapon_type := ItemDatabase.WEAPON_SWORD
	var base_damage := float(ItemDatabase.get_weapon_value(weapon_type, "damage", 1))
	var damage_multiplier := get_weapon_rarity_damage_multiplier(weapon_type, get_main_weapon_rarity())
	damage_multiplier *= get_perfect_parry_damage_multiplier()
	return maxi(1, int(round(base_damage * damage_multiplier * get_sword_critical_multiplier())))


func get_rapier_critical_multiplier() -> float:
	return float(ItemDatabase.get_item_rarity_value(ItemDatabase.WEAPON_RAPIER, get_main_weapon_rarity(), "critical_multiplier", 2.0))


func get_rapier_critical_damage() -> int:
	var weapon_type := ItemDatabase.WEAPON_RAPIER
	var base_damage := float(ItemDatabase.get_weapon_value(weapon_type, "damage", 1))
	var damage_multiplier := get_weapon_rarity_damage_multiplier(weapon_type, get_main_weapon_rarity())
	damage_multiplier *= get_perfect_parry_damage_multiplier()
	return maxi(1, int(round(base_damage * damage_multiplier * get_rapier_critical_multiplier())))


func get_weapon_startup_duration() -> float:
	return float(ItemDatabase.get_weapon_value(get_main_weapon_type(), "startup", 0.08)) / get_current_weapon_attack_speed_multiplier()


func get_weapon_active_duration() -> float:
	return float(ItemDatabase.get_weapon_value(get_main_weapon_type(), "active", 0.08)) / get_current_weapon_attack_speed_multiplier()


func get_weapon_recovery_duration() -> float:
	return float(ItemDatabase.get_weapon_value(get_main_weapon_type(), "recovery", 0.22)) / get_current_weapon_attack_speed_multiplier()


func get_weapon_attack_move_multiplier() -> float:
	return float(ItemDatabase.get_weapon_value(get_main_weapon_type(), "move_multiplier", 0.45))


func get_weapon_hitbox_size() -> Vector2:
	return ItemDatabase.get_weapon_value(get_main_weapon_type(), "hitbox_size", Vector2(36, 24)) as Vector2


func get_weapon_hitbox_offset() -> Vector2:
	return ItemDatabase.get_weapon_value(get_main_weapon_type(), "hitbox_offset", Vector2(26, -27)) as Vector2


func get_weapon_startup_color() -> Color:
	return ItemDatabase.get_weapon_value(get_main_weapon_type(), "startup_color", Color(0.85, 0.87, 0.92, 1)) as Color


func get_weapon_active_color() -> Color:
	var weapon_type := get_main_weapon_type()
	if weapon_type == ItemDatabase.WEAPON_RAPIER and is_current_attack_critical:
		return ItemDatabase.get_weapon_value(weapon_type, "critical_active_color", Color(1.0, 0.35, 0.9, 1)) as Color
	if weapon_type == ItemDatabase.WEAPON_SWORD and is_current_attack_critical:
		return Color(1.0, 0.86, 0.35, 1)

	return ItemDatabase.get_weapon_value(weapon_type, "active_color", Color(1, 1, 1, 1)) as Color


func get_weapon_recovery_color() -> Color:
	return ItemDatabase.get_weapon_value(get_main_weapon_type(), "recovery_color", Color(0.55, 0.58, 0.64, 1)) as Color


func update_weapon_visual_shape() -> void:
	var visual_rect := ItemDatabase.get_weapon_value(get_main_weapon_type(), "visual_rect", Rect2(12, -30, 26, 4)) as Rect2
	sword_visual.offset_left = visual_rect.position.x
	sword_visual.offset_top = visual_rect.position.y
	sword_visual.offset_right = visual_rect.position.x + visual_rect.size.x
	sword_visual.offset_bottom = visual_rect.position.y + visual_rect.size.y


func update_rapier_riposte(delta: float) -> void:
	if not is_rapier_riposte_ready:
		return

	rapier_riposte_time_left -= delta
	if rapier_riposte_time_left <= 0.0:
		is_rapier_riposte_ready = false
		rapier_riposte_time_left = 0.0


func update_duelist_momentum(delta: float) -> void:
	if duelist_momentum_time_left <= 0.0:
		return

	duelist_momentum_time_left = maxf(duelist_momentum_time_left - delta, 0.0)


func activate_rapier_riposte(_source: String = "") -> void:
	is_rapier_riposte_ready = true
	rapier_riposte_time_left = float(ItemDatabase.get_weapon_value(ItemDatabase.WEAPON_RAPIER, "riposte_window", 0.75))


func consume_rapier_riposte_for_attack() -> bool:
	if not has_rapier or not is_rapier_riposte_ready:
		return false

	is_rapier_riposte_ready = false
	rapier_riposte_time_left = 0.0
	return true


func register_weapon_hit(target: Node) -> void:
	if target == null or not target.is_in_group("enemies"):
		return
	if get_main_weapon_type() != ItemDatabase.WEAPON_SWORD:
		return
	if get_main_weapon_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return
	if is_current_attack_critical:
		reset_sword_battle_rhythm()
		return

	sword_battle_rhythm_hits += 1
	var hits_required := int(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_SWORD,
		get_main_weapon_rarity(),
		"battle_rhythm_hits_required",
		SWORD_BATTLE_RHYTHM_DEFAULT_HITS_REQUIRED
	))
	if sword_battle_rhythm_hits >= hits_required:
		sword_battle_rhythm_hits = 0
		is_sword_battle_rhythm_critical_ready = true
		show_feedback_message("Battle Rhythm")


func consume_sword_battle_rhythm_for_attack() -> bool:
	if get_main_weapon_type() != ItemDatabase.WEAPON_SWORD:
		return false
	if get_main_weapon_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return false
	if not is_sword_battle_rhythm_critical_ready:
		return false

	is_sword_battle_rhythm_critical_ready = false
	sword_battle_rhythm_hits = 0
	return true


func reset_sword_battle_rhythm() -> void:
	sword_battle_rhythm_hits = 0
	is_sword_battle_rhythm_critical_ready = false


func activate_duelist_momentum() -> void:
	if get_main_weapon_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return

	duelist_momentum_time_left = float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_RAPIER,
		get_main_weapon_rarity(),
		"duelist_momentum_duration",
		DUELIST_MOMENTUM_DEFAULT_DURATION
	))
	show_feedback_message("Duelist Momentum")


func get_duelist_momentum_speed_multiplier() -> float:
	if duelist_momentum_time_left <= 0.0:
		return 1.0

	return float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_RAPIER,
		get_main_weapon_rarity(),
		"duelist_momentum_speed_multiplier",
		DUELIST_MOMENTUM_DEFAULT_SPEED_MULTIPLIER
	))


func get_duelist_momentum_roll_multiplier() -> float:
	if duelist_momentum_time_left <= 0.0:
		return 1.0

	return float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_RAPIER,
		get_main_weapon_rarity(),
		"duelist_momentum_roll_multiplier",
		DUELIST_MOMENTUM_DEFAULT_ROLL_MULTIPLIER
	))


func activate_swift_bone(duration: float) -> void:
	swift_bone_time_left = maxf(swift_bone_time_left, duration)
	show_feedback_message("Swift Bone")


func update_swift_bone(delta: float) -> void:
	if swift_bone_time_left <= 0.0:
		return

	swift_bone_time_left = maxf(swift_bone_time_left - delta, 0.0)


func get_swift_bone_speed_multiplier() -> float:
	if swift_bone_time_left <= 0.0:
		return 1.0

	return float(ItemDatabase.get_consumable_value(
		ItemDatabase.CONSUMABLE_SWIFT_BONE,
		"speed_multiplier",
		SWIFT_BONE_DEFAULT_SPEED_MULTIPLIER
	))


func get_swift_bone_roll_multiplier() -> float:
	if swift_bone_time_left <= 0.0:
		return 1.0

	return float(ItemDatabase.get_consumable_value(
		ItemDatabase.CONSUMABLE_SWIFT_BONE,
		"roll_multiplier",
		SWIFT_BONE_DEFAULT_ROLL_MULTIPLIER
	))


func get_soul_harvester_damage() -> int:
	var bonus_per_stack := get_soul_harvester_damage_bonus_per_stack()
	var damage_multiplier := 1.0 + (float(soul_harvester_stacks) * bonus_per_stack)
	return maxi(1, int(round(get_weapon_base_damage(ItemDatabase.WEAPON_SOUL_HARVESTER) * damage_multiplier)))


func notify_enemy_killed() -> void:
	notify_challenge_enemy_killed()

	if not has_soul_harvester:
		return

	var was_at_max_stacks := soul_harvester_stacks >= get_soul_harvester_max_stacks()
	add_soul_harvester_stacks(1, false)
	if was_at_max_stacks:
		restore_health(get_soul_harvester_max_stack_kill_heal())


func can_use_soul_vial() -> bool:
	return has_soul_harvester


func add_soul_harvester_stacks(amount: int, show_feedback: bool = true) -> bool:
	if not has_soul_harvester or amount <= 0:
		return false

	soul_harvester_stacks = mini(soul_harvester_stacks + amount, get_soul_harvester_max_stacks())
	update_soul_harvester_ui()
	if show_feedback:
		show_feedback_message("Soul Vial")

	return true


func notify_challenge_enemy_killed() -> void:
	for challenge_chest in get_tree().get_nodes_in_group("challenge_chests"):
		if challenge_chest.has_method("notify_enemy_killed_by_player"):
			challenge_chest.call("notify_enemy_killed_by_player", self)


func notify_challenge_body_part_enemy_killed() -> void:
	for challenge_chest in get_tree().get_nodes_in_group("challenge_chests"):
		if challenge_chest.has_method("notify_enemy_killed_by_body_part"):
			challenge_chest.call("notify_enemy_killed_by_body_part", self)


func notify_challenge_player_damaged() -> void:
	for challenge_chest in get_tree().get_nodes_in_group("challenge_chests"):
		if challenge_chest.has_method("notify_player_took_damage"):
			challenge_chest.call("notify_player_took_damage", self)


func reset_soul_harvester_stacks() -> void:
	soul_harvester_stacks = 0


func update_soul_harvester_ui() -> void:
	var should_show_soul_ui := has_soul_harvester
	soul_stack_label.visible = false
	soul_stack_pips.visible = should_show_soul_ui
	soul_harvester_icon.visible = should_show_soul_ui
	soul_aura.visible = should_show_soul_ui and soul_harvester_stacks > 0
	var max_stacks := get_soul_harvester_max_stacks()
	soul_stack_label.text = "Soul Stacks: " + str(soul_harvester_stacks) + "/" + str(max_stacks)
	update_soul_stack_pips(max_stacks)

	if soul_harvester_stacks > 0:
		var aura_alpha := 0.12 + (float(soul_harvester_stacks) * 0.06)
		soul_aura.color = Color(0.55, 0.18, 1, minf(aura_alpha, 0.45))


func update_soul_stack_pips(max_stacks: int) -> void:
	if soul_stack_pips.get_child_count() != max_stacks:
		rebuild_soul_stack_pips(max_stacks)

	for index in range(soul_stack_pips.get_child_count()):
		var pip := soul_stack_pips.get_child(index) as ColorRect
		if pip == null:
			continue

		pip.color = SOUL_STACK_FILLED_COLOR if index < soul_harvester_stacks else SOUL_STACK_EMPTY_COLOR


func rebuild_soul_stack_pips(max_stacks: int) -> void:
	for child in soul_stack_pips.get_children():
		soul_stack_pips.remove_child(child)
		child.queue_free()

	for index in range(max_stacks):
		var pip := ColorRect.new()
		pip.custom_minimum_size = SOUL_STACK_PIP_SIZE
		pip.color = SOUL_STACK_EMPTY_COLOR
		soul_stack_pips.add_child(pip)


func get_soul_harvester_max_stacks() -> int:
	return int(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_SOUL_HARVESTER,
		get_main_weapon_rarity(),
		"soul_max_stacks",
		int(ItemDatabase.get_weapon_value(ItemDatabase.WEAPON_SOUL_HARVESTER, "soul_max_stacks", 5))
	))


func get_soul_harvester_damage_bonus_per_stack() -> float:
	return float(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_SOUL_HARVESTER,
		get_main_weapon_rarity(),
		"soul_damage_bonus_per_stack",
		float(ItemDatabase.get_weapon_value(ItemDatabase.WEAPON_SOUL_HARVESTER, "soul_damage_bonus_per_stack", 0.05))
	))


func get_soul_harvester_max_stack_kill_heal() -> int:
	return int(ItemDatabase.get_item_rarity_value(
		ItemDatabase.WEAPON_SOUL_HARVESTER,
		get_main_weapon_rarity(),
		"soul_max_stack_kill_heal",
		0
	))


func pickup_shield(new_shield_type: String = BASIC_SHIELD_TYPE, new_shield_rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	return exchange_shield(new_shield_type, new_shield_rarity) != "blocked"


func exchange_shield(new_shield_type: String, new_shield_rarity: String = ItemDatabase.RARITY_COMMON) -> String:
	if not has_left_arm:
		show_feedback_message("Need left arm")
		return "blocked"

	var old_shield_type := get_shield_type()
	has_shield = true
	shield_type = new_shield_type
	shield_rarity = new_shield_rarity
	update_shield_icon()
	return old_shield_type


func get_shield_type() -> String:
	if not has_shield:
		return ""

	return shield_type


func get_shield_rarity() -> String:
	if not has_shield:
		return ItemDatabase.RARITY_COMMON

	return shield_rarity


func can_use_shield() -> bool:
	return has_shield and has_left_arm and can_use_left_arm() and not is_sword_attacking and shield_cooldown_left <= 0.0


func use_shield() -> void:
	if is_sword_attacking:
		show_feedback_message("Attacking")
		return
	if not can_use_shield():
		return

	is_using_shield = true
	shield_use_time_left = SHIELD_USE_DURATION
	shield_parry_time_left = get_shield_parry_duration()
	shield_visual.color = get_shield_parry_color()
	shield_visual.show()


func update_shield_use(delta: float) -> void:
	if not is_using_shield:
		return

	if not can_use_shield():
		stop_shield_use()
		return

	shield_use_time_left -= delta
	shield_parry_time_left -= delta

	if is_bone_mirror_equipped() and is_shield_parrying():
		try_reflect_projectiles()

	if shield_parry_time_left <= 0.0:
		shield_visual.color = get_shield_block_color()

	if shield_use_time_left <= 0.0:
		stop_shield_use()


func update_shield_cooldown(delta: float) -> void:
	if shield_cooldown_left <= 0.0:
		return

	shield_cooldown_left = maxf(shield_cooldown_left - delta, 0.0)


func update_perfect_parry_damage_buff(delta: float) -> void:
	if perfect_parry_damage_buff_time_left <= 0.0:
		return

	perfect_parry_damage_buff_time_left = maxf(perfect_parry_damage_buff_time_left - delta, 0.0)


func stop_shield_use() -> void:
	if is_using_shield and not skip_next_shield_cooldown:
		shield_cooldown_left = get_shield_cooldown()
	skip_next_shield_cooldown = false
	is_using_shield = false
	shield_use_time_left = 0.0
	shield_parry_time_left = 0.0
	shield_visual.hide()


func is_shield_blocking() -> bool:
	return is_using_shield and can_use_shield()


func is_shield_parrying() -> bool:
	return is_shield_blocking() and shield_parry_time_left > 0.0


func get_shield_parry_duration() -> float:
	var parry_multiplier := float(ItemDatabase.get_item_rarity_value(shield_type, get_shield_rarity(), "parry_window_multiplier", 1.0))
	return SHIELD_PARRY_DURATION * parry_multiplier


func get_shield_cooldown() -> float:
	var cooldown_multiplier := float(ItemDatabase.get_item_rarity_value(shield_type, get_shield_rarity(), "cooldown_multiplier", 1.0))
	return SHIELD_COOLDOWN * cooldown_multiplier


func activate_perfect_parry_bonus() -> void:
	if shield_type != BASIC_SHIELD_TYPE:
		return
	if get_shield_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return

	perfect_parry_damage_buff_time_left = float(ItemDatabase.get_item_rarity_value(
		BASIC_SHIELD_TYPE,
		get_shield_rarity(),
		"perfect_parry_damage_duration",
		PERFECT_PARRY_DEFAULT_DAMAGE_DURATION
	))
	show_feedback_message("Perfect Parry")


func get_perfect_parry_damage_multiplier() -> float:
	if perfect_parry_damage_buff_time_left <= 0.0:
		return 1.0

	return float(ItemDatabase.get_item_rarity_value(
		BASIC_SHIELD_TYPE,
		ItemDatabase.RARITY_LEGENDARY,
		"perfect_parry_damage_multiplier",
		PERFECT_PARRY_DEFAULT_DAMAGE_MULTIPLIER
	))


func is_bone_mirror_equipped() -> bool:
	return has_shield and shield_type == BONE_MIRROR_SHIELD_TYPE


func is_spiked_shield_equipped() -> bool:
	return has_shield and shield_type == SPIKED_SHIELD_TYPE


func get_shield_parry_color() -> Color:
	return ItemDatabase.get_shield_value(shield_type, "parry_color", Color(0.75, 0.95, 1, 1)) as Color


func get_shield_block_color() -> Color:
	return ItemDatabase.get_shield_value(shield_type, "block_color", Color(0.14, 0.62, 0.78, 1)) as Color


func update_shield_icon() -> void:
	shield_icon.visible = has_shield and shield_type == BASIC_SHIELD_TYPE
	bone_mirror_icon.visible = has_shield and shield_type == BONE_MIRROR_SHIELD_TYPE
	spiked_shield_icon.visible = has_shield and shield_type == SPIKED_SHIELD_TYPE


func clear_shield() -> void:
	has_shield = false
	shield_type = BASIC_SHIELD_TYPE
	shield_rarity = ItemDatabase.RARITY_COMMON
	stop_shield_use()
	update_shield_icon()


func try_reflect_projectiles() -> void:
	var reflect_shape := RectangleShape2D.new()
	reflect_shape.size = ItemDatabase.get_shield_value(shield_type, "reflect_size", Vector2(38, 48)) as Vector2

	var reflect_offset := ItemDatabase.get_shield_value(shield_type, "reflect_offset", Vector2(18, -25)) as Vector2
	var reflect_center := global_position + Vector2(reflect_offset.x * facing_direction, reflect_offset.y)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = reflect_shape
	query.transform = Transform2D(0.0, reflect_center)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := get_world_2d().direct_space_state.intersect_shape(query, 8)
	for result in results:
		var projectile := result["collider"] as Node
		if projectile != null and projectile.has_method("reflect_by_player"):
			var reflected_damage_multiplier := get_reflected_projectile_damage_multiplier()
			var was_reflected := bool(projectile.call("reflect_by_player", self, facing_direction, reflected_damage_multiplier))
			if was_reflected:
				show_feedback_message("Reflected")


func get_reflected_projectile_damage_multiplier() -> float:
	return float(ItemDatabase.get_item_rarity_value(
		BONE_MIRROR_SHIELD_TYPE,
		get_shield_rarity(),
		"reflected_projectile_damage_multiplier",
		1.0
	))


func notify_reflected_projectile_kill() -> void:
	if shield_type != BONE_MIRROR_SHIELD_TYPE:
		return
	if get_shield_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return

	var cooldown_reduction := float(ItemDatabase.get_item_rarity_value(
		BONE_MIRROR_SHIELD_TYPE,
		get_shield_rarity(),
		"reflected_projectile_kill_cooldown_reduction",
		0.0
	))
	if cooldown_reduction <= 0.0:
		return

	shield_cooldown_left = maxf(shield_cooldown_left - cooldown_reduction, 0.0)
	show_feedback_message("Mirror Reset")


func handle_successful_melee_parry(attacker: Node) -> void:
	activate_perfect_parry_bonus()
	if not is_spiked_shield_equipped():
		return
	if attacker == null or not is_instance_valid(attacker):
		return

	var target_health_before := get_target_health(attacker)
	var counter_damage := get_spiked_shield_counter_damage()
	if attacker.has_method("take_parry_counter_damage"):
		attacker.call("take_parry_counter_damage", counter_damage)
	elif attacker.has_method("take_damage"):
		attacker.call("take_damage", counter_damage)
	var counter_killed_target := target_health_before > 0 and get_target_health(attacker) <= 0
	if counter_killed_target:
		handle_spiked_shield_counter_kill()
	show_feedback_message("Counter")


func get_spiked_shield_counter_damage() -> int:
	return int(ItemDatabase.get_item_rarity_value(
		SPIKED_SHIELD_TYPE,
		get_shield_rarity(),
		"counter_damage",
		int(ItemDatabase.get_shield_value(SPIKED_SHIELD_TYPE, "counter_damage", 1))
	))


func handle_spiked_shield_counter_kill() -> void:
	if get_shield_rarity() != ItemDatabase.RARITY_LEGENDARY:
		return
	if not bool(ItemDatabase.get_item_rarity_value(SPIKED_SHIELD_TYPE, get_shield_rarity(), "counter_kill_resets_cooldown", false)):
		return

	shield_cooldown_left = 0.0
	skip_next_shield_cooldown = true
	stop_shield_use()
	show_feedback_message("Counter Reset")


func take_player_damage(amount: int, attacker: Variant = null) -> void:
	if is_dead:
		return

	if is_shield_parrying():
		if is_instance_valid(attacker) and attacker.has_method("take_damage"):
			activate_perfect_parry_bonus()
			attacker.call("take_damage", 1)
		return

	if is_shield_blocking():
		return

	health = maxi(health - amount, 0)
	notify_challenge_player_damaged()
	reset_sword_battle_rhythm()
	reset_soul_harvester_stacks()
	update_soul_harvester_ui()
	update_health_bar()
	interrupt_spider_climb_from_damage()

	if health <= 0:
		die()


func update_hazard_damage_cooldown(delta: float) -> void:
	if spike_damage_cooldown_left > 0.0:
		spike_damage_cooldown_left -= delta


func update_arm_throw_cooldowns(delta: float) -> void:
	if left_arm_throw_cooldown_left > 0.0:
		left_arm_throw_cooldown_left = maxf(left_arm_throw_cooldown_left - delta, 0.0)
	if right_arm_throw_cooldown_left > 0.0:
		right_arm_throw_cooldown_left = maxf(right_arm_throw_cooldown_left - delta, 0.0)
	if left_arm_use_cooldown_left > 0.0:
		left_arm_use_cooldown_left = maxf(left_arm_use_cooldown_left - delta, 0.0)
	if right_arm_use_cooldown_left > 0.0:
		right_arm_use_cooldown_left = maxf(right_arm_use_cooldown_left - delta, 0.0)


func update_ground_slam_cooldown(delta: float) -> void:
	if ground_slam_cooldown_left > 0.0:
		ground_slam_cooldown_left = maxf(ground_slam_cooldown_left - delta, 0.0)


func update_spider_wall_climb(delta: float) -> void:
	if spider_wall_climb_cooldown_left > 0.0:
		spider_wall_climb_cooldown_left = maxf(spider_wall_climb_cooldown_left - delta, 0.0)
	if spider_wall_hop_cooldown_left > 0.0:
		spider_wall_hop_cooldown_left = maxf(spider_wall_hop_cooldown_left - delta, 0.0)

	if not Input.is_key_pressed(KEY_SPACE) or is_on_floor() or is_climbing_ladder or is_ground_slamming or is_spider_wall_hopping:
		stop_spider_wall_climb()
		return

	if is_spider_wall_climbing:
		if can_start_spider_wall_hop():
			start_spider_wall_hop()
			return

		if get_spider_wall_direction() == 0:
			start_spider_ledge_boost()
			return

		spider_wall_climb_time_left -= delta
		if spider_wall_climb_time_left <= 0.0:
			stop_spider_wall_climb()
			spider_wall_climb_cooldown_left = SPIDER_WALL_CLIMB_COOLDOWN
		return

	if can_start_spider_wall_climb():
		start_spider_wall_climb()


func can_start_spider_wall_climb() -> bool:
	return has_spider_legs() and not is_rolling and not is_spider_wall_hopping and spider_wall_climb_cooldown_left <= 0.0 and get_spider_wall_direction() != 0


func start_spider_wall_climb() -> void:
	spider_wall_direction = get_spider_wall_direction()
	is_spider_wall_climbing = true
	spider_wall_climb_time_left = SPIDER_WALL_CLIMB_DURATION
	velocity.x = spider_wall_direction * 10.0
	velocity.y = -SPIDER_WALL_CLIMB_SPEED


func stop_spider_wall_climb() -> void:
	is_spider_wall_climbing = false
	spider_wall_climb_time_left = 0.0
	spider_wall_direction = 0


func update_spider_wall_hop(delta: float) -> void:
	if not is_spider_wall_hopping:
		return

	spider_wall_hop_time_left -= delta
	if spider_wall_hop_time_left <= 0.0 or is_on_floor():
		stop_spider_wall_hop()


func can_start_spider_wall_hop() -> bool:
	return spider_wall_hop_cooldown_left <= 0.0 and spider_wall_climb_time_left <= SPIDER_WALL_HOP_WINDOW and get_move_direction() != 0.0


func start_spider_wall_hop() -> void:
	var hop_direction := int(signf(get_move_direction()))
	if hop_direction == 0:
		hop_direction = -spider_wall_direction

	is_spider_wall_hopping = true
	spider_wall_hop_time_left = SPIDER_WALL_HOP_DURATION
	spider_wall_hop_cooldown_left = SPIDER_WALL_HOP_COOLDOWN
	spider_wall_hop_direction = hop_direction
	velocity.x = spider_wall_hop_direction * SPIDER_WALL_HOP_HORIZONTAL_SPEED
	velocity.y = SPIDER_WALL_HOP_VELOCITY
	stop_spider_wall_climb()
	facing_direction = spider_wall_hop_direction
	update_body_parts_scale()


func start_spider_ledge_boost() -> void:
	if spider_wall_direction == 0:
		stop_spider_wall_climb()
		return

	is_spider_wall_hopping = true
	spider_wall_hop_time_left = SPIDER_LEDGE_BOOST_DURATION
	spider_wall_hop_cooldown_left = SPIDER_WALL_HOP_COOLDOWN
	spider_wall_hop_direction = spider_wall_direction
	velocity.x = spider_wall_hop_direction * SPIDER_LEDGE_BOOST_HORIZONTAL_SPEED
	velocity.y = SPIDER_LEDGE_BOOST_VELOCITY
	stop_spider_wall_climb()
	facing_direction = spider_wall_hop_direction
	update_body_parts_scale()


func stop_spider_wall_hop() -> void:
	is_spider_wall_hopping = false
	spider_wall_hop_time_left = 0.0
	spider_wall_hop_direction = 0


func interrupt_spider_climb_from_damage() -> void:
	if not is_spider_wall_climbing and not is_spider_wall_hopping:
		return

	stop_spider_wall_climb()
	stop_spider_wall_hop()
	spider_wall_climb_cooldown_left = maxf(spider_wall_climb_cooldown_left, SPIDER_DAMAGE_CLIMB_LOCKOUT)
	spider_wall_hop_cooldown_left = maxf(spider_wall_hop_cooldown_left, SPIDER_DAMAGE_CLIMB_LOCKOUT)
	velocity.y = maxf(velocity.y, SPIDER_DAMAGE_FALL_SPEED)


func get_spider_wall_direction() -> int:
	if has_wall_in_direction(facing_direction):
		return facing_direction

	if has_wall_in_direction(-facing_direction):
		return -facing_direction

	return 0


func has_wall_in_direction(direction: int) -> bool:
	var ray_start := global_position + SPIDER_WALL_BODY_OFFSET
	var ray_end := ray_start + Vector2(direction * SPIDER_WALL_CHECK_DISTANCE, 0)
	var query := PhysicsRayQueryParameters2D.new()
	query.from = ray_start
	query.to = ray_end
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := get_world_2d().direct_space_state.intersect_ray(query)
	return not result.is_empty()


func check_spike_hazards() -> void:
	if spike_damage_cooldown_left > 0.0:
		return

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = collision_shape.global_transform
	query.collision_mask = HAZARD_COLLISION_MASK
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results := get_world_2d().direct_space_state.intersect_shape(query, 4)

	if not results.is_empty():
		take_spike_damage()


func take_spike_damage() -> void:
	if is_dead:
		return

	spike_damage_cooldown_left = SPIKE_DAMAGE_COOLDOWN
	health = maxi(health - SPIKE_DAMAGE, 0)
	notify_challenge_player_damaged()
	reset_sword_battle_rhythm()
	reset_soul_harvester_stacks()
	update_soul_harvester_ui()
	update_health_bar()
	interrupt_spider_climb_from_damage()

	if health <= 0:
		die()


func update_health_bar() -> void:
	var health_ratio := float(health) / float(STARTING_HEALTH)
	health_bar.size.x = 80.0 * health_ratio


func show_feedback_message(message: String) -> void:
	var feedback_message := FLOATING_FEEDBACK_MESSAGE_SCENE.instantiate()

	feedback_message.setup(message)
	get_tree().current_scene.add_child(feedback_message)
	feedback_message.global_position = global_position + Vector2(0, -60)


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	stop_sword_attack()
	stop_shield_use()
	stop_roll()
	clear_main_weapon()
	clear_shield()
	spawn_death_pieces()
	body_parts.hide()
	collision_shape.set_deferred("disabled", true)
	show_feedback_message("You died")


func spawn_death_pieces() -> void:
	if has_head:
		spawn_death_piece(head.global_position, head.color, HEAD_DEATH_PIECE_SIZE, Vector2(10, -90))

	spawn_death_piece(torso.global_position, torso.color, TORSO_DEATH_PIECE_SIZE, Vector2(0, -40))

	if has_left_arm:
		spawn_death_piece(left_arm.global_position, left_arm_part_color, ARM_DEATH_PIECE_SIZE, Vector2(-90, -65))
	if has_right_arm:
		spawn_death_piece(right_arm.global_position, right_arm_part_color, ARM_DEATH_PIECE_SIZE, Vector2(90, -65))
	if has_left_leg:
		spawn_death_piece(left_leg.global_position, left_leg_part_color, LEG_DEATH_PIECE_SIZE, Vector2(-45, -35))
	if has_right_leg:
		spawn_death_piece(right_leg.global_position, right_leg_part_color, LEG_DEATH_PIECE_SIZE, Vector2(45, -35))


func spawn_death_piece(piece_position: Vector2, piece_color: Color, piece_size: Vector2, launch_velocity: Vector2) -> void:
	var death_piece := THROWN_BODY_PART_SCENE.instantiate()

	get_tree().current_scene.add_child(death_piece)
	death_piece.global_position = piece_position
	death_piece.setup_death_piece(piece_color, piece_size, launch_velocity)


func detach_left_arm() -> void:
	if not has_left_arm:
		return
	if not can_throw_arm(BodyPartDatabase.BODY_PART_LEFT_ARM):
		show_feedback_message("Arm cooldown")
		return

	var carried_item_type := ""
	var carried_item_rarity := ItemDatabase.RARITY_COMMON
	if has_shield:
		carried_item_type = shield_type
		carried_item_rarity = get_shield_rarity()
		clear_shield()

	has_left_arm = false
	left_arm.hide()
	stop_shield_use()
	throw_body_part(BodyPartDatabase.BODY_PART_LEFT_ARM, left_arm_part_id, left_arm_part_color, carried_item_type, carried_item_rarity)


func sacrifice_left_arm_for_challenge() -> bool:
	if not has_left_arm:
		show_feedback_message("No left arm")
		return false

	if has_shield:
		clear_shield()

	has_left_arm = false
	left_arm.hide()
	stop_shield_use()
	show_feedback_message("Left arm sacrificed")
	return true


func detach_right_arm() -> void:
	if not has_right_arm:
		return
	if not can_throw_arm(BodyPartDatabase.BODY_PART_RIGHT_ARM):
		show_feedback_message("Arm cooldown")
		return

	var carried_item_type := get_main_weapon_type()
	var carried_item_rarity := get_main_weapon_rarity()
	if carried_item_type != "":
		clear_main_weapon()

	has_right_arm = false
	right_arm.hide()
	stop_sword_attack()
	throw_body_part(BodyPartDatabase.BODY_PART_RIGHT_ARM, right_arm_part_id, right_arm_part_color, carried_item_type, carried_item_rarity)


func sacrifice_leg() -> void:
	if has_enemy_legs():
		show_feedback_message("Enemy legs cannot detach")
		return

	var leg_count := get_leg_count()

	if leg_count == 0:
		return

	if has_left_leg:
		detach_left_leg()
		drop_body_part(BodyPartDatabase.BODY_PART_LEFT_LEG, left_leg_part_id, left_leg_part_color)
	else:
		detach_right_leg()
		drop_body_part(BodyPartDatabase.BODY_PART_RIGHT_LEG, right_leg_part_id, right_leg_part_color)

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


func obtain_body_part_reward(reward_id: String) -> void:
	if reward_id == BodyPartDatabase.ENEMY_ARM_REWARD:
		obtain_enemy_arm()
	elif reward_id == BodyPartDatabase.BOOMERANG_ARMS_REWARD:
		obtain_boomerang_arms()
	elif reward_id == BodyPartDatabase.HARPOON_ARMS_REWARD:
		obtain_harpoon_arms()
	elif reward_id == BodyPartDatabase.ENEMY_LEGS_REWARD:
		obtain_enemy_leg()
	elif reward_id == BodyPartDatabase.STOMP_LEGS_REWARD:
		obtain_stomp_legs()
	elif reward_id == BodyPartDatabase.SPIDER_LEGS_REWARD:
		obtain_spider_legs()
	else:
		show_feedback_message("Unknown body part")


func obtain_boomerang_arms() -> void:
	has_left_arm = true
	has_right_arm = true
	left_arm_part_id = "boomerang_left_arm"
	right_arm_part_id = "boomerang_right_arm"
	left_arm_part_color = BOOMERANG_ARM_COLOR
	right_arm_part_color = BOOMERANG_ARM_COLOR
	left_arm_throw_cooldown_left = 0.0
	right_arm_throw_cooldown_left = 0.0
	left_arm_use_cooldown_left = 0.0
	right_arm_use_cooldown_left = 0.0
	left_arm.color = left_arm_part_color
	right_arm.color = right_arm_part_color
	left_arm.show()
	right_arm.show()
	show_feedback_message("Boomerang arms")


func obtain_harpoon_arms() -> void:
	has_left_arm = true
	has_right_arm = true
	left_arm_part_id = "harpoon_left_arm"
	right_arm_part_id = "harpoon_right_arm"
	left_arm_part_color = HARPOON_ARM_COLOR
	right_arm_part_color = HARPOON_ARM_COLOR
	left_arm_throw_cooldown_left = 0.0
	right_arm_throw_cooldown_left = 0.0
	left_arm_use_cooldown_left = 0.0
	right_arm_use_cooldown_left = 0.0
	left_arm.color = left_arm_part_color
	right_arm.color = right_arm_part_color
	left_arm.show()
	right_arm.show()
	show_feedback_message("Harpoon arms")


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


func obtain_stomp_legs() -> void:
	has_left_leg = true
	has_right_leg = true
	left_leg_part_id = "stomp_left_leg"
	right_leg_part_id = "stomp_right_leg"
	left_leg_part_color = STOMP_LEG_COLOR
	right_leg_part_color = STOMP_LEG_COLOR
	left_leg.color = left_leg_part_color
	right_leg.color = right_leg_part_color
	left_leg.show()
	right_leg.show()
	double_jumps_left = get_max_double_jumps()
	ground_slam_cooldown_left = 0.0
	show_feedback_message("Stomp legs")


func obtain_spider_legs() -> void:
	has_left_leg = true
	has_right_leg = true
	left_leg_part_id = "spider_left_leg"
	right_leg_part_id = "spider_right_leg"
	left_leg_part_color = SPIDER_LEG_COLOR
	right_leg_part_color = SPIDER_LEG_COLOR
	left_leg.color = left_leg_part_color
	right_leg.color = right_leg_part_color
	left_leg.show()
	right_leg.show()
	double_jumps_left = get_max_double_jumps()
	is_ground_slamming = false
	ground_slam_cooldown_left = 0.0
	is_spider_wall_climbing = false
	spider_wall_climb_cooldown_left = 0.0
	is_spider_wall_hopping = false
	spider_wall_hop_cooldown_left = 0.0
	show_feedback_message("Spider legs")


func recover_body_part(body_part_type: String, carried_item_type: String = "", body_part_id: String = "", body_part_color: Color = Color(-1, -1, -1, -1), carried_item_rarity: String = ItemDatabase.RARITY_COMMON) -> bool:
	if body_part_type == BodyPartDatabase.BODY_PART_LEFT_ARM and not has_left_arm:
		has_left_arm = true
		if body_part_id != "":
			left_arm_part_id = body_part_id
		if body_part_color.a >= 0.0:
			left_arm_part_color = body_part_color
			left_arm.color = left_arm_part_color
		left_arm.show()
		recover_carried_item(carried_item_type, carried_item_rarity)
		start_arm_throw_cooldown(BodyPartDatabase.BODY_PART_LEFT_ARM, left_arm_part_id)
		print("Recovered ", left_arm_part_id)
		return true

	if body_part_type == BodyPartDatabase.BODY_PART_RIGHT_ARM and not has_right_arm:
		has_right_arm = true
		if body_part_id != "":
			right_arm_part_id = body_part_id
		if body_part_color.a >= 0.0:
			right_arm_part_color = body_part_color
			right_arm.color = right_arm_part_color
		right_arm.show()
		recover_carried_item(carried_item_type, carried_item_rarity)
		start_arm_throw_cooldown(BodyPartDatabase.BODY_PART_RIGHT_ARM, right_arm_part_id)
		print("Recovered ", right_arm_part_id)
		return true

	if body_part_type == BodyPartDatabase.BODY_PART_LEFT_LEG and not has_left_leg:
		has_left_leg = true
		if body_part_id != "":
			left_leg_part_id = body_part_id
		if body_part_color.a >= 0.0:
			left_leg_part_color = body_part_color
			left_leg.color = left_leg_part_color
		left_leg.show()
		print("Recovered ", left_leg_part_id)
		return true

	if body_part_type == BodyPartDatabase.BODY_PART_RIGHT_LEG and not has_right_leg:
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


func has_missing_body_parts() -> bool:
	return not has_head or not has_left_arm or not has_right_arm or not has_left_leg or not has_right_leg


func repair_missing_body_parts() -> bool:
	if not has_missing_body_parts():
		show_feedback_message("No parts missing")
		return false

	if not has_head:
		has_head = true
		head_part_id = "skeleton_head"
		head.show()

	if not has_left_arm:
		has_left_arm = true
		left_arm_part_id = "skeleton_left_arm"
		left_arm_part_color = SKELETON_ARM_COLOR
		left_arm_throw_cooldown_left = 0.0
		left_arm_use_cooldown_left = 0.0
		left_arm.color = left_arm_part_color
		left_arm.show()

	if not has_right_arm:
		has_right_arm = true
		right_arm_part_id = "skeleton_right_arm"
		right_arm_part_color = SKELETON_ARM_COLOR
		right_arm_throw_cooldown_left = 0.0
		right_arm_use_cooldown_left = 0.0
		right_arm.color = right_arm_part_color
		right_arm.show()

	if not has_left_leg:
		has_left_leg = true
		left_leg_part_id = "skeleton_left_leg"
		left_leg_part_color = SKELETON_LEG_COLOR
		left_leg.color = left_leg_part_color
		left_leg.show()

	if not has_right_leg:
		has_right_leg = true
		right_leg_part_id = "skeleton_right_leg"
		right_leg_part_color = SKELETON_LEG_COLOR
		right_leg.color = right_leg_part_color
		right_leg.show()

	double_jumps_left = get_max_double_jumps()
	is_ground_slamming = false
	is_spider_wall_climbing = false
	is_spider_wall_hopping = false
	update_body_pose()
	show_feedback_message("Body repaired")
	return true


func recover_carried_item(carried_item_type: String, carried_item_rarity: String = ItemDatabase.RARITY_COMMON) -> void:
	if carried_item_type == ItemDatabase.WEAPON_SWORD:
		has_sword = true
		main_weapon_rarity = carried_item_rarity
		has_axe = false
		has_rapier = false
		has_bone_cleaver = false
		has_soul_harvester = false
		sword_icon.show()
		axe_icon.hide()
		rapier_icon.hide()
		bone_cleaver_icon.hide()
		soul_harvester_icon.hide()
	elif carried_item_type == ItemDatabase.WEAPON_AXE:
		has_axe = true
		main_weapon_rarity = carried_item_rarity
		has_sword = false
		has_rapier = false
		has_bone_cleaver = false
		has_soul_harvester = false
		axe_icon.show()
		sword_icon.hide()
		rapier_icon.hide()
		bone_cleaver_icon.hide()
		soul_harvester_icon.hide()
	elif carried_item_type == ItemDatabase.WEAPON_RAPIER:
		has_rapier = true
		main_weapon_rarity = carried_item_rarity
		has_sword = false
		has_axe = false
		has_bone_cleaver = false
		has_soul_harvester = false
		rapier_icon.show()
		sword_icon.hide()
		axe_icon.hide()
		bone_cleaver_icon.hide()
		soul_harvester_icon.hide()
	elif carried_item_type == ItemDatabase.WEAPON_BONE_CLEAVER:
		has_bone_cleaver = true
		main_weapon_rarity = carried_item_rarity
		has_sword = false
		has_axe = false
		has_rapier = false
		has_soul_harvester = false
		bone_cleaver_icon.show()
		sword_icon.hide()
		axe_icon.hide()
		rapier_icon.hide()
		soul_harvester_icon.hide()
	elif carried_item_type == ItemDatabase.WEAPON_SOUL_HARVESTER:
		has_soul_harvester = true
		main_weapon_rarity = carried_item_rarity
		has_sword = false
		has_axe = false
		has_rapier = false
		has_bone_cleaver = false
		soul_harvester_icon.show()
		sword_icon.hide()
		axe_icon.hide()
		rapier_icon.hide()
		bone_cleaver_icon.hide()
	elif carried_item_type == ItemDatabase.SHIELD_BASIC:
		has_shield = true
		shield_type = ItemDatabase.SHIELD_BASIC
		shield_rarity = carried_item_rarity
		update_shield_icon()
	elif carried_item_type == ItemDatabase.SHIELD_BONE_MIRROR:
		has_shield = true
		shield_type = ItemDatabase.SHIELD_BONE_MIRROR
		shield_rarity = carried_item_rarity
		update_shield_icon()
	elif carried_item_type == ItemDatabase.SHIELD_SPIKED:
		has_shield = true
		shield_type = ItemDatabase.SHIELD_SPIKED
		shield_rarity = carried_item_rarity
		update_shield_icon()

	update_soul_harvester_ui()


func get_throw_damage(carried_item_type: String, carried_item_rarity: String = ItemDatabase.RARITY_COMMON) -> int:
	var throw_damage := ARM_THROW_DAMAGE

	if carried_item_type == ItemDatabase.WEAPON_SOUL_HARVESTER:
		throw_damage += get_soul_harvester_damage()
	elif ItemDatabase.get_weapon_data(carried_item_type).is_empty() == false:
		throw_damage += get_weapon_damage_with_rarity(carried_item_type, carried_item_rarity)
	elif ItemDatabase.get_shield_data(carried_item_type).is_empty() == false:
		throw_damage += int(ItemDatabase.get_shield_value(carried_item_type, "throw_damage_bonus", 1))

	return throw_damage


func throw_body_part(body_part_type: String, body_part_id: String, part_color: Color, carried_item_type: String = "", carried_item_rarity: String = ItemDatabase.RARITY_COMMON) -> void:
	var thrown_part := THROWN_BODY_PART_SCENE.instantiate()
	var throw_direction := Vector2(facing_direction, 0)
	var throw_damage := get_throw_damage(carried_item_type, carried_item_rarity)

	get_tree().current_scene.add_child(thrown_part)
	thrown_part.global_position = global_position + Vector2(ARM_THROW_OFFSET.x * facing_direction, ARM_THROW_OFFSET.y)
	thrown_part.setup(throw_direction, part_color, throw_damage, body_part_type, carried_item_type, body_part_id, self, carried_item_rarity)


func drop_body_part(body_part_type: String, body_part_id: String, part_color: Color) -> void:
	var dropped_part := THROWN_BODY_PART_SCENE.instantiate()

	get_tree().current_scene.add_child(dropped_part)
	dropped_part.global_position = global_position + LEG_DROP_OFFSET
	dropped_part.setup_dropped(part_color, body_part_type, "", body_part_id)


func notify_hook_pull_success() -> void:
	activate_rapier_riposte("Hook")


func can_throw_arm(body_part_type: String) -> bool:
	if body_part_type == BodyPartDatabase.BODY_PART_LEFT_ARM:
		return left_arm_throw_cooldown_left <= 0.0
	if body_part_type == BodyPartDatabase.BODY_PART_RIGHT_ARM:
		return right_arm_throw_cooldown_left <= 0.0

	return true


func start_arm_throw_cooldown(body_part_type: String, body_part_id: String) -> void:
	if not is_boomerang_arm_id(body_part_id) and not is_harpoon_arm_id(body_part_id):
		return

	if body_part_type == BodyPartDatabase.BODY_PART_LEFT_ARM:
		left_arm_throw_cooldown_left = get_special_arm_throw_cooldown(body_part_id)
		left_arm_use_cooldown_left = get_special_arm_use_cooldown(body_part_id)
	elif body_part_type == BodyPartDatabase.BODY_PART_RIGHT_ARM:
		right_arm_throw_cooldown_left = get_special_arm_throw_cooldown(body_part_id)
		right_arm_use_cooldown_left = get_special_arm_use_cooldown(body_part_id)


func is_boomerang_arm_id(body_part_id: String) -> bool:
	return body_part_id.begins_with("boomerang_")


func is_harpoon_arm_id(body_part_id: String) -> bool:
	return body_part_id.begins_with("harpoon_")


func get_special_arm_throw_cooldown(body_part_id: String) -> float:
	if is_harpoon_arm_id(body_part_id):
		return HARPOON_ARM_THROW_COOLDOWN

	return BOOMERANG_ARM_THROW_COOLDOWN


func get_special_arm_use_cooldown(body_part_id: String) -> float:
	if is_harpoon_arm_id(body_part_id):
		return 0.0

	return BOOMERANG_ARM_USE_COOLDOWN


func can_use_left_arm() -> bool:
	return left_arm_use_cooldown_left <= 0.0


func can_use_right_arm() -> bool:
	return right_arm_use_cooldown_left <= 0.0


func handle_ground_slam_input() -> void:
	if is_key_just_pressed(KEY_S) and can_start_ground_slam():
		start_ground_slam()


func can_start_ground_slam() -> bool:
	return has_stomp_legs() and not is_on_floor() and not is_climbing_ladder and ground_slam_cooldown_left <= 0.0 and not is_ground_slamming


func start_ground_slam() -> void:
	is_ground_slamming = true
	velocity.x = 0.0
	velocity.y = GROUND_SLAM_SPEED
	stop_roll()
	stop_spider_wall_climb()
	stop_spider_wall_hop()
	stop_sword_attack()
	stop_shield_use()


func finish_ground_slam() -> void:
	is_ground_slamming = false
	ground_slam_cooldown_left = GROUND_SLAM_COOLDOWN
	velocity.x = 0.0
	apply_ground_slam_impact()
	spawn_ground_slam_impact_visual()


func apply_ground_slam_impact() -> void:
	var impact_shape := CircleShape2D.new()
	impact_shape.radius = GROUND_SLAM_RADIUS

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = impact_shape
	query.transform = Transform2D(0.0, global_position + Vector2(0, -16))
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := get_world_2d().direct_space_state.intersect_shape(query, 16)
	var hit_enemies := []

	for result in results:
		var enemy := result["collider"] as Node
		if enemy == null or not enemy.is_in_group("enemies") or hit_enemies.has(enemy):
			continue

		hit_enemies.append(enemy)

		if enemy.has_method("take_ground_slam_damage"):
			enemy.call("take_ground_slam_damage", GROUND_SLAM_DAMAGE)
		elif enemy.has_method("take_damage"):
			enemy.call("take_damage", GROUND_SLAM_DAMAGE)
		if enemy.has_method("stun_for_duration"):
			enemy.call("stun_for_duration", GROUND_SLAM_STUN_DURATION)
		elif enemy.has_method("stun"):
			enemy.call("stun")

		apply_ground_slam_knockback(enemy)


func apply_ground_slam_knockback(enemy: Node) -> void:
	if not (enemy is Node2D):
		return

	var enemy_node := enemy as Node2D
	var knockback_direction := signf(enemy_node.global_position.x - global_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = float(facing_direction)

	var remaining_distance := GROUND_SLAM_KNOCKBACK
	while remaining_distance > 0.0:
		var step_distance = minf(GROUND_SLAM_KNOCKBACK_STEP, remaining_distance)
		var step_offset := Vector2(knockback_direction * step_distance, 0.0)
		if would_enemy_hit_world(enemy_node, step_offset):
			return

		enemy_node.global_position += step_offset
		remaining_distance -= step_distance


func would_enemy_hit_world(enemy_node: Node2D, offset: Vector2) -> bool:
	var enemy_collision_object := enemy_node as CollisionObject2D
	if enemy_collision_object == null:
		return false

	var enemy_collision_shape := enemy_node.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if enemy_collision_shape == null or enemy_collision_shape.shape == null:
		return false

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = enemy_collision_shape.shape
	query.transform = enemy_collision_shape.global_transform.translated(offset)
	query.exclude = [enemy_collision_object.get_rid()]
	query.collision_mask = enemy_collision_object.collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results := get_world_2d().direct_space_state.intersect_shape(query, 1)
	return not results.is_empty()


func spawn_ground_slam_impact_visual() -> void:
	var impact_root := Node2D.new()
	var impact_bar := ColorRect.new()

	get_tree().current_scene.add_child(impact_root)
	impact_root.global_position = global_position
	impact_root.z_index = 30

	impact_bar.offset_left = -GROUND_SLAM_RADIUS
	impact_bar.offset_top = -4.0
	impact_bar.offset_right = GROUND_SLAM_RADIUS
	impact_bar.offset_bottom = 4.0
	impact_bar.color = Color(0.75, 0.85, 1.0, 0.8)
	impact_root.add_child(impact_bar)

	var tween := create_tween()
	tween.tween_property(impact_root, "scale", Vector2(1.25, 0.6), 0.12)
	tween.parallel().tween_property(impact_root, "modulate:a", 0.0, 0.12)
	tween.tween_callback(Callable(impact_root, "queue_free"))
