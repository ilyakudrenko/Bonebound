extends Node2D

@onready var prompt: Node2D = $Prompt
@onready var interaction_area: Area2D = $InteractionArea
@onready var loot_panel: Control = $LootUI/LootPanel

var player_is_nearby := false
var was_interact_pressed := false
var was_arm_select_pressed := false
var was_leg_select_pressed := false
var nearby_player: Node = null


func _ready() -> void:
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
	loot_panel.show()


func select_enemy_arm() -> void:
	if nearby_player != null and nearby_player.has_method("obtain_enemy_arm"):
		nearby_player.call("obtain_enemy_arm")
		print("Selected enemy arm")
	loot_panel.hide()
	queue_free()


func select_enemy_leg() -> void:
	if nearby_player != null and nearby_player.has_method("obtain_enemy_leg"):
		nearby_player.call("obtain_enemy_leg")
		print("Selected enemy leg")
	loot_panel.hide()
	queue_free()


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
