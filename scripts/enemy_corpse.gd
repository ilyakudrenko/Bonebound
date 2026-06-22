extends Node2D

@onready var prompt: Node2D = $Prompt
@onready var interaction_area: Area2D = $InteractionArea
@onready var loot_panel: Control = $LootUI/LootPanel
@onready var arm_label: Label = $LootUI/LootPanel/ArmLabel
@onready var arm_swatch: ColorRect = $LootUI/LootPanel/ArmSwatch
@onready var arm_description: Label = $LootUI/LootPanel/ArmDescription
@onready var leg_label: Label = $LootUI/LootPanel/LegLabel
@onready var leg_swatch_left: ColorRect = $LootUI/LootPanel/LegSwatchLeft
@onready var leg_swatch_right: ColorRect = $LootUI/LootPanel/LegSwatchRight
@onready var leg_description: Label = $LootUI/LootPanel/LegDescription

var player_is_nearby := false
var was_interact_pressed := false
var was_arm_select_pressed := false
var was_leg_select_pressed := false
var nearby_player: Node = null
var arm_reward_pool := [BodyPartDatabase.FALLBACK_ARM_REWARD]
var leg_reward_pool := [BodyPartDatabase.FALLBACK_LEG_REWARD]
var selected_arm_reward := BodyPartDatabase.FALLBACK_ARM_REWARD
var selected_leg_reward := BodyPartDatabase.FALLBACK_LEG_REWARD


func _ready() -> void:
	roll_reward_options()
	update_reward_ui()
	prompt.hide()
	loot_panel.hide()
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	call_deferred("refresh_prompt_visibility")


func _process(_delta: float) -> void:
	var is_interact_pressed := Input.is_key_pressed(KEY_E)
	var is_arm_select_pressed := Input.is_key_pressed(KEY_W)
	var is_leg_select_pressed := Input.is_key_pressed(KEY_S)

	if player_is_nearby and is_interact_pressed and not was_interact_pressed:
		open_loot_panel()

	if loot_panel.visible and is_arm_select_pressed and not was_arm_select_pressed:
		select_enemy_arm()

	if loot_panel.visible and is_leg_select_pressed and not was_leg_select_pressed:
		select_enemy_leg()

	was_interact_pressed = is_interact_pressed
	was_arm_select_pressed = is_arm_select_pressed
	was_leg_select_pressed = is_leg_select_pressed


func refresh_prompt_visibility() -> void:
	await get_tree().physics_frame

	for body in interaction_area.get_overlapping_bodies():
		if body.name == "Player":
			player_is_nearby = true
			nearby_player = body
			prompt.show()
			return

	player_is_nearby = false
	nearby_player = null
	prompt.hide()
	loot_panel.hide()


func open_loot_panel() -> void:
	prompt.hide()
	update_reward_ui()
	loot_panel.show()


func setup_rewards(new_arm_reward_pool: Array, new_leg_reward_pool: Array) -> void:
	if not new_arm_reward_pool.is_empty():
		arm_reward_pool = new_arm_reward_pool
	if not new_leg_reward_pool.is_empty():
		leg_reward_pool = new_leg_reward_pool

	roll_reward_options()
	if is_node_ready():
		update_reward_ui()


func roll_reward_options() -> void:
	selected_arm_reward = pick_reward_from_pool(arm_reward_pool, BodyPartDatabase.FALLBACK_ARM_REWARD)
	selected_leg_reward = pick_reward_from_pool(leg_reward_pool, BodyPartDatabase.FALLBACK_LEG_REWARD)


func pick_reward_from_pool(reward_pool: Array, fallback_reward: String) -> String:
	if reward_pool.is_empty():
		return fallback_reward

	var total_weight := 0
	for reward in reward_pool:
		total_weight += BodyPartDatabase.get_drop_weight(str(reward))

	if total_weight <= 0:
		return fallback_reward

	var roll := randi_range(1, total_weight)
	var current_weight := 0

	for reward in reward_pool:
		var reward_id := str(reward)
		current_weight += BodyPartDatabase.get_drop_weight(reward_id)
		if roll <= current_weight:
			return reward_id

	return fallback_reward


func update_reward_ui() -> void:
	var arm_data: Dictionary = BodyPartDatabase.get_reward_data(selected_arm_reward, BodyPartDatabase.FALLBACK_ARM_REWARD)
	var leg_data: Dictionary = BodyPartDatabase.get_reward_data(selected_leg_reward, BodyPartDatabase.FALLBACK_LEG_REWARD)
	var arm_color: Color = arm_data["color"] as Color
	var leg_color: Color = leg_data["color"] as Color

	arm_label.text = str(arm_data["label"])
	arm_swatch.color = arm_color
	arm_description.text = str(arm_data["description"])
	leg_label.text = str(leg_data["label"])
	leg_swatch_left.color = leg_color
	leg_swatch_right.color = leg_color
	leg_description.text = str(leg_data["description"])


func select_enemy_arm() -> void:
	if nearby_player != null:
		apply_reward_to_player(selected_arm_reward)
		print("Selected ", selected_arm_reward)
	loot_panel.hide()
	queue_free()


func select_enemy_leg() -> void:
	if nearby_player != null:
		apply_reward_to_player(selected_leg_reward)
		print("Selected ", selected_leg_reward)
	loot_panel.hide()
	queue_free()


func apply_reward_to_player(reward_id: String) -> void:
	if nearby_player.has_method("obtain_body_part_reward"):
		nearby_player.call("obtain_body_part_reward", reward_id)
		return

	if reward_id == BodyPartDatabase.ENEMY_ARM_REWARD and nearby_player.has_method("obtain_enemy_arm"):
		nearby_player.call("obtain_enemy_arm")
	elif reward_id == BodyPartDatabase.ENEMY_LEGS_REWARD and nearby_player.has_method("obtain_enemy_leg"):
		nearby_player.call("obtain_enemy_leg")


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_is_nearby = true
		nearby_player = body
		if not loot_panel.visible:
			prompt.show()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_is_nearby = false
		nearby_player = null
		prompt.hide()
		loot_panel.hide()
