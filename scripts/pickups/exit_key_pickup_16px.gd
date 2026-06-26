extends Area2D

const ITEM_INFO_CARD_SCENE := preload("res://scenes/ui/ItemInfoCard_16px.tscn")

@export var item_type := ItemDatabase.SPECIAL_EXIT_KEY

var nearby_player: Node = null
var was_interact_pressed := false
var can_current_player_pick_up := false
var item_info_card: Control = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	create_item_info_card()


func _process(_delta: float) -> void:
	var is_interact_pressed := Input.is_key_pressed(KEY_E)

	if nearby_player != null:
		can_current_player_pick_up = can_body_pick_up_key(nearby_player)
		update_pickup_ui_state()

	if nearby_player != null and can_current_player_pick_up and is_interact_pressed and not was_interact_pressed:
		pick_up_key()

	was_interact_pressed = is_interact_pressed


func _on_body_entered(body: Node) -> void:
	if not body.has_method("pickup_exit_key"):
		return

	nearby_player = body
	can_current_player_pick_up = can_body_pick_up_key(body)
	show_pickup_ui()


func _on_body_exited(body: Node) -> void:
	if body == nearby_player:
		nearby_player = null
		can_current_player_pick_up = false
		hide_pickup_ui()


func pick_up_key() -> void:
	if nearby_player == null:
		return

	if bool(nearby_player.call("pickup_exit_key")):
		queue_free()


func can_body_pick_up_key(body: Node) -> bool:
	if body.has_method("has_level_exit_key"):
		return not bool(body.call("has_level_exit_key"))

	return true


func create_item_info_card() -> void:
	item_info_card = ITEM_INFO_CARD_SCENE.instantiate() as Control
	if item_info_card == null:
		return

	add_child(item_info_card)
	item_info_card.call("setup_item", item_type, ItemDatabase.RARITY_COMMON, false)
	item_info_card.hide()


func show_pickup_ui() -> void:
	if item_info_card != null:
		update_pickup_ui_state()
		item_info_card.show()


func hide_pickup_ui() -> void:
	if item_info_card != null:
		item_info_card.hide()


func update_pickup_ui_state() -> void:
	if item_info_card != null:
		item_info_card.call("set_can_pick_up", can_current_player_pick_up)
