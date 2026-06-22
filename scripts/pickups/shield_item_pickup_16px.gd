extends Area2D

const ITEM_INFO_CARD_SCENE := preload("res://scenes/ui/ItemInfoCard_16px.tscn")

@export var item_type := ItemDatabase.SHIELD_BASIC
@export var item_rarity := ItemDatabase.RARITY_COMMON
@export var auto_pickup_if_empty := true

var nearby_player: Node = null
var was_interact_pressed := false
var can_current_player_pick_up := false
var item_info_card: Control = null

@onready var prompt: Node2D = get_node_or_null("Prompt")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	create_item_info_card()


func _process(_delta: float) -> void:
	var is_interact_pressed := Input.is_key_pressed(KEY_E)

	if nearby_player != null and can_current_player_pick_up and is_interact_pressed and not was_interact_pressed:
		swap_shield_with_player()

	was_interact_pressed = is_interact_pressed


func _on_body_entered(body: Node) -> void:
	if not body.has_method("exchange_shield"):
		return

	can_current_player_pick_up = can_body_pick_up_shield(body)
	if not can_current_player_pick_up:
		nearby_player = body
		show_pickup_ui()
		return

	if body.has_method("get_shield_type") and String(body.call("get_shield_type")) == "" and auto_pickup_if_empty:
		var old_shield_type := String(body.call("exchange_shield", item_type, item_rarity))
		if old_shield_type != "blocked":
			queue_free()
		return

	nearby_player = body
	show_pickup_ui()


func _on_body_exited(body: Node) -> void:
	if body == nearby_player:
		nearby_player = null
		can_current_player_pick_up = false
		hide_pickup_ui()


func swap_shield_with_player() -> void:
	if nearby_player == null:
		return

	var old_shield_rarity := ItemDatabase.RARITY_COMMON
	if nearby_player.has_method("get_shield_rarity"):
		old_shield_rarity = String(nearby_player.call("get_shield_rarity"))

	var old_shield_type := String(nearby_player.call("exchange_shield", item_type, item_rarity))
	if old_shield_type == "blocked":
		return
	if old_shield_type == item_type and old_shield_rarity == item_rarity:
		return

	spawn_old_shield(ItemDatabase.get_shield_pickup_scene_path(old_shield_type), old_shield_rarity)
	queue_free()


func spawn_old_shield(scene_path: String, old_shield_rarity: String) -> void:
	if scene_path == "":
		return

	var old_shield_scene := load(scene_path) as PackedScene
	var old_shield := old_shield_scene.instantiate()
	if has_property(old_shield, "item_rarity"):
		old_shield.set("item_rarity", old_shield_rarity)

	get_tree().current_scene.add_child(old_shield)
	old_shield.global_position = global_position


func create_item_info_card() -> void:
	item_info_card = ITEM_INFO_CARD_SCENE.instantiate() as Control
	if item_info_card == null:
		return

	add_child(item_info_card)
	item_info_card.call("setup_item", item_type, item_rarity)
	item_info_card.hide()


func show_pickup_ui() -> void:
	if item_info_card != null:
		item_info_card.call("set_can_pick_up", can_current_player_pick_up)
		item_info_card.show()


func hide_pickup_ui() -> void:
	if prompt != null:
		prompt.hide()
	if item_info_card != null:
		item_info_card.hide()


func can_body_pick_up_shield(body: Node) -> bool:
	for property in body.get_property_list():
		if str(property.get("name", "")) == "has_left_arm":
			return bool(body.get("has_left_arm"))

	return true


func has_property(target: Object, property_name: String) -> bool:
	for property in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true

	return false
