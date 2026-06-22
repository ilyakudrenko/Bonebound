extends "res://scripts/dummy_enemy_16px.gd"

const SHIELD_BLOCK_STUN_DURATION := 0.65
const SHIELD_FRONT_OFFSET := 10.0
const SHIELD_BLOCK_COLOR := Color(0.8, 0.9, 1.0, 1)
const SHIELD_NORMAL_COLOR := Color(0.2, 0.35, 0.48, 1)

@onready var shield_visual: ColorRect = $Shield

var facing_before_recent_damage := -1
var should_preserve_facing_on_next_stun := false


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_shield_visual()


func take_damage(amount: int, is_critical: bool = false) -> void:
	if blocks_damage_with_shield():
		block_front_hit()
		return

	facing_before_recent_damage = patrol_direction
	should_preserve_facing_on_next_stun = true
	super.take_damage(amount, is_critical)
	call_deferred("clear_pending_stun_facing")


func take_ground_slam_damage(amount: int) -> void:
	super.take_damage(amount)


func take_parry_counter_damage(amount: int) -> void:
	super.take_damage(amount)


func get_arm_reward_pool() -> Array:
	return BodyPartDatabase.SHIELD_ENEMY_ARM_REWARDS


func get_leg_reward_pool() -> Array:
	return BodyPartDatabase.SHIELD_ENEMY_LEG_REWARDS


func stun_for_duration(duration: float) -> void:
	super.stun_for_duration(duration)

	if should_preserve_facing_on_next_stun:
		patrol_direction = facing_before_recent_damage
		attack_direction = facing_before_recent_damage
		should_preserve_facing_on_next_stun = false
		update_shield_visual()


func clear_pending_stun_facing() -> void:
	should_preserve_facing_on_next_stun = false


func blocks_damage_with_shield() -> bool:
	if player == null or state == STUNNED_STATE:
		return false

	var direction_to_player := signf(player.global_position.x - global_position.x)
	if is_zero_approx(direction_to_player):
		return true

	return int(direction_to_player) == patrol_direction


func block_front_hit() -> void:
	flash_shield_block()

	if player != null and player.has_method("stun_player"):
		player.call("stun_player", SHIELD_BLOCK_STUN_DURATION)


func flash_shield_block() -> void:
	shield_visual.color = SHIELD_BLOCK_COLOR

	var tween := create_tween()
	tween.tween_property(shield_visual, "color", SHIELD_NORMAL_COLOR, 0.18)


func update_shield_visual() -> void:
	shield_visual.position.x = patrol_direction * SHIELD_FRONT_OFFSET
