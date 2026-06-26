extends Node2D

@export var enemy_scene: PackedScene = EnemySpawnDatabase.DEFAULT_ENEMY_SCENE
@export var spawn_enemies_on_ready := true
@export var use_weighted_enemy_spawns := true
@export var chest_scene: PackedScene = ChestSpawnDatabase.DEFAULT_CHEST_SCENE
@export var spawn_chests_on_ready := true
@export var use_weighted_chest_spawns := true
@export var spawn_consumables_on_ready := true
@export var challenge_chest_scene: PackedScene = preload("res://scenes/scaled/world/ChallengeChest_16px.tscn")
@export_range(0.0, 1.0, 0.01) var challenge_chest_spawn_chance := 0.4
@export var spawn_challenge_chests_on_ready := true


func _ready() -> void:
	if spawn_enemies_on_ready:
		spawn_enemies()
	if spawn_chests_on_ready:
		spawn_chests()
	if spawn_consumables_on_ready:
		spawn_consumables()
	if spawn_challenge_chests_on_ready:
		spawn_challenge_chests()


func spawn_enemies() -> void:
	var spawn_points := get_spawn_point_markers("EnemySpawnPoints", "EnemySpawn")
	if spawn_points.is_empty():
		return

	var enemies_parent := get_or_create_enemies_parent()

	for spawn_point in spawn_points:
		spawn_enemy_at(spawn_point.global_position, enemies_parent)


func spawn_enemy_at(spawn_position: Vector2, enemies_parent: Node) -> void:
	var selected_enemy_scene: PackedScene = get_random_enemy_scene()
	if selected_enemy_scene == null:
		return

	var enemy := selected_enemy_scene.instantiate()
	enemies_parent.add_child(enemy)
	enemy.global_position = spawn_position


func spawn_chests() -> void:
	var spawn_points := get_spawn_point_markers("ChestSpawnPoints", "ChestSpawn")
	if spawn_points.is_empty():
		return

	var chests_parent := get_or_create_chests_parent()

	for spawn_point in spawn_points:
		spawn_chest_at(spawn_point.global_position, chests_parent)


func spawn_chest_at(spawn_position: Vector2, chests_parent: Node) -> void:
	var selected_chest_data: Dictionary = get_random_chest_data()
	var selected_chest_scene: PackedScene = selected_chest_data["scene"] as PackedScene
	if selected_chest_scene == null:
		return

	var chest := selected_chest_scene.instantiate()
	if has_property(chest, "chest_rarity"):
		chest.set("chest_rarity", String(selected_chest_data["rarity"]))

	chests_parent.add_child(chest)
	chest.global_position = spawn_position


func spawn_consumables() -> void:
	var spawn_points := get_spawn_point_markers("ConsumableSpawnPoints", "ConsumableSpawn")
	if spawn_points.is_empty():
		return

	var consumables_parent := get_or_create_consumables_parent()

	for spawn_point in spawn_points:
		spawn_consumable_at(spawn_point.global_position, consumables_parent)


func spawn_consumable_at(spawn_position: Vector2, consumables_parent: Node) -> void:
	var selected_consumable_scene: PackedScene = ConsumableSpawnDatabase.get_random_consumable_scene()
	if selected_consumable_scene == null:
		return

	var consumable := selected_consumable_scene.instantiate()
	consumables_parent.add_child(consumable)
	consumable.global_position = spawn_position


func spawn_challenge_chests() -> void:
	var spawn_points := get_challenge_chest_spawn_points()
	if spawn_points.is_empty():
		return

	var chests_parent := get_or_create_chests_parent()

	for spawn_point in spawn_points:
		try_spawn_challenge_chest_at(spawn_point.global_position, chests_parent)


func get_challenge_chest_spawn_points() -> Array[Marker2D]:
	var markers: Array[Marker2D] = []
	var added_markers: Dictionary = {}

	append_spawn_points_from_folder(markers, added_markers, "Markers/ChallengeChestSpawnPoints")
	append_spawn_points_from_folder(markers, added_markers, "ChallengeChestSpawnPoints")
	append_direct_spawn_points(markers, added_markers, self, "ChallengeChestSpawn")

	var marker_root := get_node_or_null("Markers")
	if marker_root != null:
		append_direct_spawn_points(markers, added_markers, marker_root, "ChallengeChestSpawn")

	return markers


func get_spawn_point_markers(folder_name: String, marker_name_prefix: String) -> Array[Marker2D]:
	var markers: Array[Marker2D] = []
	var added_markers: Dictionary = {}

	append_spawn_points_from_folder(markers, added_markers, "Markers/" + folder_name)
	append_spawn_points_from_folder(markers, added_markers, folder_name)
	append_direct_spawn_points(markers, added_markers, self, marker_name_prefix)

	var marker_root := get_node_or_null("Markers")
	if marker_root != null:
		append_direct_spawn_points(markers, added_markers, marker_root, marker_name_prefix)

	return markers


func append_spawn_points_from_folder(markers: Array[Marker2D], added_markers: Dictionary, folder_path: String) -> void:
	var folder := get_node_or_null(folder_path)
	if folder == null:
		return

	for child in folder.get_children():
		append_spawn_point(markers, added_markers, child)


func append_direct_spawn_points(markers: Array[Marker2D], added_markers: Dictionary, parent: Node, marker_name_prefix: String) -> void:
	for child in parent.get_children():
		if child.name.begins_with(marker_name_prefix):
			append_spawn_point(markers, added_markers, child)


func append_spawn_point(markers: Array[Marker2D], added_markers: Dictionary, node: Node) -> void:
	if not node is Marker2D:
		return

	var marker := node as Marker2D
	var marker_id: int = marker.get_instance_id()
	if added_markers.has(marker_id):
		return

	added_markers[marker_id] = true
	markers.append(marker)


func try_spawn_challenge_chest_at(spawn_position: Vector2, chests_parent: Node) -> void:
	if challenge_chest_scene == null:
		return
	if randf() > challenge_chest_spawn_chance:
		return

	var challenge_chest := challenge_chest_scene.instantiate()
	chests_parent.add_child(challenge_chest)
	challenge_chest.global_position = spawn_position


func get_random_enemy_scene() -> PackedScene:
	if not use_weighted_enemy_spawns:
		return enemy_scene

	var total_weight := 0
	for raw_enemy_data in EnemySpawnDatabase.ENEMY_SPAWN_TABLE:
		var enemy_data: Dictionary = raw_enemy_data as Dictionary
		total_weight += int(enemy_data["weight"])

	if total_weight <= 0:
		return enemy_scene

	var roll := randi_range(1, total_weight)
	var current_weight := 0

	for raw_enemy_data in EnemySpawnDatabase.ENEMY_SPAWN_TABLE:
		var enemy_data: Dictionary = raw_enemy_data as Dictionary
		current_weight += int(enemy_data["weight"])
		if roll <= current_weight:
			return enemy_data["scene"] as PackedScene

	return enemy_scene


func get_random_chest_data() -> Dictionary:
	if not use_weighted_chest_spawns:
		return {
			"label": "Common Chest",
			"weight": 1,
			"rarity": ItemDatabase.RARITY_COMMON,
			"scene": chest_scene,
		}

	var total_weight := 0
	for raw_chest_data in ChestSpawnDatabase.CHEST_SPAWN_TABLE:
		var chest_data: Dictionary = raw_chest_data as Dictionary
		total_weight += int(chest_data["weight"])

	if total_weight <= 0:
		return {
			"label": "Common Chest",
			"weight": 1,
			"rarity": ItemDatabase.RARITY_COMMON,
			"scene": chest_scene,
		}

	var roll := randi_range(1, total_weight)
	var current_weight := 0

	for raw_chest_data in ChestSpawnDatabase.CHEST_SPAWN_TABLE:
		var chest_data: Dictionary = raw_chest_data as Dictionary
		current_weight += int(chest_data["weight"])
		if roll <= current_weight:
			return chest_data

	return {
		"label": "Common Chest",
		"weight": 1,
		"rarity": ItemDatabase.RARITY_COMMON,
		"scene": chest_scene,
	}


func get_or_create_enemies_parent() -> Node:
	var enemies_parent := get_node_or_null("Enemies")
	if enemies_parent != null:
		return enemies_parent

	enemies_parent = Node.new()
	enemies_parent.name = "Enemies"
	add_child(enemies_parent)
	return enemies_parent


func get_or_create_chests_parent() -> Node:
	var chests_parent := get_node_or_null("Chests")
	if chests_parent != null:
		return chests_parent

	chests_parent = Node.new()
	chests_parent.name = "Chests"
	add_child(chests_parent)
	return chests_parent


func get_or_create_consumables_parent() -> Node:
	var consumables_parent := get_node_or_null("Consumables")
	if consumables_parent != null:
		return consumables_parent

	consumables_parent = Node.new()
	consumables_parent.name = "Consumables"
	add_child(consumables_parent)
	return consumables_parent


func has_property(node: Node, property_name: String) -> bool:
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true

	return false
