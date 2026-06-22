extends Area2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var rare_closed_texture: Texture2D
@export var rare_open_texture: Texture2D
@export var legendary_closed_texture: Texture2D
@export var legendary_open_texture: Texture2D
@export var chest_rarity := ItemDatabase.RARITY_COMMON
@export var loot_pool: Array[String] = []
@export var pickup_spawn_offset := Vector2(42, -8)

@onready var visual: Sprite2D = $Visual
@onready var prompt: Node2D = $Prompt

var nearby_player: Node = null
var was_interact_pressed := false
var is_open := false
var selected_item := ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if loot_pool.is_empty():
		for item_id in ItemDatabase.get_chest_loot_pool():
			loot_pool.append(String(item_id))

	visual.texture = get_closed_texture()
	visual.modulate = get_chest_modulate()
	prompt.hide()


func _process(_delta: float) -> void:
	var is_interact_pressed := Input.is_key_pressed(KEY_E)

	if nearby_player != null and not is_open and is_interact_pressed and not was_interact_pressed:
		open_chest()

	was_interact_pressed = is_interact_pressed


func open_chest() -> void:
	is_open = true
	prompt.hide()
	visual.texture = get_open_texture()

	selected_item = pick_random_item()
	spawn_reward_pickup()


func get_closed_texture() -> Texture2D:
	if chest_rarity == ItemDatabase.RARITY_RARE and rare_closed_texture != null:
		return rare_closed_texture
	if chest_rarity == ItemDatabase.RARITY_LEGENDARY and legendary_closed_texture != null:
		return legendary_closed_texture

	return closed_texture


func get_open_texture() -> Texture2D:
	if chest_rarity == ItemDatabase.RARITY_RARE and rare_open_texture != null:
		return rare_open_texture
	if chest_rarity == ItemDatabase.RARITY_LEGENDARY and legendary_open_texture != null:
		return legendary_open_texture

	return open_texture


func get_chest_modulate() -> Color:
	return Color.WHITE


func pick_random_item() -> String:
	if loot_pool.is_empty():
		return ItemDatabase.WEAPON_SWORD

	return String(loot_pool.pick_random())


func spawn_reward_pickup() -> void:
	var scene_path: String = ItemDatabase.get_item_pickup_scene_path(selected_item)
	if scene_path == "":
		return

	var reward_scene: PackedScene = load(scene_path) as PackedScene
	if reward_scene == null:
		return

	var reward_node := reward_scene.instantiate() as Node2D
	if reward_node == null:
		return

	if has_auto_pickup_property(reward_node):
		reward_node.set("auto_pickup_if_empty", false)
	if has_property(reward_node, "item_rarity"):
		reward_node.set("item_rarity", chest_rarity)

	get_tree().current_scene.add_child(reward_node)
	reward_node.global_position = global_position + pickup_spawn_offset


func has_auto_pickup_property(node: Node) -> bool:
	for property in node.get_property_list():
		if str(property.get("name", "")) == "auto_pickup_if_empty":
			return true

	return false


func has_property(node: Node, property_name: String) -> bool:
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true

	return false


func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return

	nearby_player = body
	if not is_open:
		prompt.show()


func _on_body_exited(body: Node) -> void:
	if body != nearby_player:
		return

	nearby_player = null
	prompt.hide()
