extends Area2D

const ITEM_INFO_CARD_SCENE := preload("res://scenes/ui/ItemInfoCard_16px.tscn")

@export var item_type := ItemDatabase.CONSUMABLE_BONE_FLASK

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
		can_current_player_pick_up = can_body_use_consumable(nearby_player)
		update_pickup_ui_state()

	if nearby_player != null and can_current_player_pick_up and is_interact_pressed and not was_interact_pressed:
		use_consumable()

	was_interact_pressed = is_interact_pressed


func _on_body_entered(body: Node) -> void:
	if not can_body_use_consumables(body):
		return

	nearby_player = body
	can_current_player_pick_up = can_body_use_consumable(body)
	show_pickup_ui()


func _on_body_exited(body: Node) -> void:
	if body == nearby_player:
		nearby_player = null
		can_current_player_pick_up = false
		hide_pickup_ui()


func use_consumable() -> void:
	if nearby_player == null:
		return

	if item_type == ItemDatabase.CONSUMABLE_BONE_FLASK:
		var heal_amount := int(ItemDatabase.get_consumable_value(item_type, "heal_amount", 0))
		nearby_player.call("restore_health", heal_amount, "Bone Flask")
		queue_free()
	elif item_type == ItemDatabase.CONSUMABLE_BONE_REPAIR_KIT:
		if nearby_player.has_method("repair_missing_body_parts") and bool(nearby_player.call("repair_missing_body_parts")):
			queue_free()
	elif item_type == ItemDatabase.CONSUMABLE_SOUL_VIAL:
		var soul_stacks := int(ItemDatabase.get_consumable_value(item_type, "soul_stacks", 0))
		if nearby_player.has_method("add_soul_harvester_stacks") and bool(nearby_player.call("add_soul_harvester_stacks", soul_stacks)):
			queue_free()
	elif item_type == ItemDatabase.CONSUMABLE_SWIFT_BONE:
		if nearby_player.has_method("activate_swift_bone"):
			var duration := float(ItemDatabase.get_consumable_value(item_type, "duration", 20.0))
			nearby_player.call("activate_swift_bone", duration)
			queue_free()


func can_body_use_consumables(body: Node) -> bool:
	if body.has_method("restore_health"):
		return true
	if body.has_method("repair_missing_body_parts"):
		return true
	if body.has_method("add_soul_harvester_stacks"):
		return true
	if body.has_method("activate_swift_bone"):
		return true

	return false


func can_body_use_consumable(body: Node) -> bool:
	if item_type == ItemDatabase.CONSUMABLE_BONE_REPAIR_KIT:
		if body.has_method("has_missing_body_parts"):
			return bool(body.call("has_missing_body_parts"))
		return false
	if item_type == ItemDatabase.CONSUMABLE_SOUL_VIAL:
		if body.has_method("can_use_soul_vial"):
			return bool(body.call("can_use_soul_vial"))
		return false

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
