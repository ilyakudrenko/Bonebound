extends Area2D

const ITEM_INFO_CARD_SCENE := preload("res://scenes/ui/ItemInfoCard_16px.tscn")

@export var item_type := ItemDatabase.WEAPON_SWORD
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
		swap_weapon_with_player()

	was_interact_pressed = is_interact_pressed


func _on_body_entered(body: Node) -> void:
	if not body.has_method("exchange_main_weapon"):
		return

	if body.has_method("can_use_main_weapon") and not bool(body.call("can_use_main_weapon", item_type)):
		nearby_player = body
		can_current_player_pick_up = false
		show_pickup_ui()
		return

	can_current_player_pick_up = true
	if body.has_method("has_main_weapon") and bool(body.call("has_main_weapon")):
		nearby_player = body
		show_pickup_ui()
		return

	if not auto_pickup_if_empty:
		nearby_player = body
		show_pickup_ui()
		return

	var old_weapon_type := String(body.call("exchange_main_weapon", item_type, item_rarity))
	if old_weapon_type != "blocked":
		queue_free()


func _on_body_exited(body: Node) -> void:
	if body == nearby_player:
		nearby_player = null
		can_current_player_pick_up = false
		hide_pickup_ui()


func swap_weapon_with_player() -> void:
	if nearby_player == null:
		return

	var old_weapon_rarity := ItemDatabase.RARITY_COMMON
	if nearby_player.has_method("get_main_weapon_rarity"):
		old_weapon_rarity = String(nearby_player.call("get_main_weapon_rarity"))

	var old_weapon_type := String(nearby_player.call("exchange_main_weapon", item_type, item_rarity))
	if old_weapon_type == "blocked":
		return
	if old_weapon_type == item_type and old_weapon_rarity == item_rarity:
		return

	spawn_old_weapon(ItemDatabase.get_weapon_pickup_scene_path(old_weapon_type), old_weapon_rarity)
	queue_free()


func spawn_old_weapon(scene_path: String, old_weapon_rarity: String) -> void:
	if scene_path == "":
		return

	var old_weapon_scene := load(scene_path) as PackedScene
	var old_weapon := old_weapon_scene.instantiate()
	if has_property(old_weapon, "item_rarity"):
		old_weapon.set("item_rarity", old_weapon_rarity)

	get_tree().current_scene.add_child(old_weapon)
	old_weapon.global_position = global_position


func has_property(node: Node, property_name: String) -> bool:
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true

	return false


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
