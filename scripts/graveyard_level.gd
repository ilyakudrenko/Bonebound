extends Node2D

const TILE_SIZE_FALLBACK := Vector2(16, 16)
const DEFAULT_PLAYER_START_POSITION := Vector2(64, 320)
const ROOM_TYPE_COMBAT := "combat"
const ROOM_TYPE_LOOT := "loot"
const LEVEL_SEQUENCE_TEMPLATES := [
	[ROOM_TYPE_COMBAT, ROOM_TYPE_COMBAT, ROOM_TYPE_LOOT, ROOM_TYPE_COMBAT],
	[ROOM_TYPE_COMBAT, ROOM_TYPE_LOOT, ROOM_TYPE_COMBAT, ROOM_TYPE_COMBAT, ROOM_TYPE_LOOT],
]

@export var room_gap := 0.0

@onready var rooms_parent: Node2D = $Rooms
@onready var player: Node2D = $Player
@onready var gameplay_camera: Camera2D = $GameplayCamera

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	build_level()


func build_level() -> void:
	clear_rooms()

	var room_sequence := get_room_sequence()
	var next_room_left := 0.0
	var player_start_position := player.global_position

	for room_index in range(room_sequence.size()):
		var room_scene: PackedScene = room_sequence[room_index]
		if room_scene == null:
			push_warning("Skipping missing room scene at sequence index: %s" % room_index)
			continue

		var room := room_scene.instantiate() as Node2D
		var test_player_position := get_test_player_position(room)
		var room_bounds := get_room_bounds(room)

		strip_test_nodes(room)
		room.position = Vector2(next_room_left - room_bounds.position.x, 0)

		rooms_parent.add_child(room)

		if room_index == 0:
			player_start_position = room.position + test_player_position

		next_room_left = room.position.x + room_bounds.position.x + room_bounds.size.x + room_gap

	player.global_position = player_start_position
	gameplay_camera.global_position = player.global_position + Vector2(0, -24)


func get_room_sequence() -> Array:
	var sequence := [RoomCatalog.get_start_room()]
	var sequence_template: Array = pick_random_sequence_template()

	for room_type in sequence_template:
		sequence.append(pick_random_room_for_type(room_type))

	sequence.append(RoomCatalog.get_exit_room())

	return sequence


func pick_random_sequence_template() -> Array:
	var template_index := rng.randi_range(0, LEVEL_SEQUENCE_TEMPLATES.size() - 1)
	return LEVEL_SEQUENCE_TEMPLATES[template_index].duplicate()


func pick_random_room_for_type(room_type: String) -> PackedScene:
	if room_type == ROOM_TYPE_COMBAT:
		return pick_random_room(RoomCatalog.get_combat_rooms())
	if room_type == ROOM_TYPE_LOOT:
		return pick_random_room(RoomCatalog.get_loot_rooms())

	push_warning("Unknown graveyard room type: %s" % room_type)
	return null


func pick_random_room(room_pool: Array) -> PackedScene:
	if room_pool.is_empty():
		return null

	return room_pool[rng.randi_range(0, room_pool.size() - 1)]


func clear_rooms() -> void:
	for child in rooms_parent.get_children():
		child.queue_free()


func strip_test_nodes(room: Node2D) -> void:
	remove_child_if_present(room, "Player")
	remove_child_if_present(room, "GameplayCamera")


func remove_child_if_present(parent: Node, child_name: String) -> void:
	var child := parent.get_node_or_null(child_name)

	if child == null:
		return

	parent.remove_child(child)
	child.free()


func get_test_player_position(room: Node2D) -> Vector2:
	var test_player := room.get_node_or_null("Player") as Node2D

	if test_player == null:
		return DEFAULT_PLAYER_START_POSITION

	return test_player.position


func get_room_bounds(room: Node2D) -> Rect2:
	var tile_map := room.get_node_or_null("TileMap") as TileMap

	if tile_map == null:
		return Rect2(Vector2.ZERO, Vector2(640, 360))

	var used_rect := tile_map.get_used_rect()
	var tile_size := TILE_SIZE_FALLBACK

	if tile_map.tile_set != null:
		tile_size = Vector2(tile_map.tile_set.tile_size.x, tile_map.tile_set.tile_size.y)

	return Rect2(
		Vector2(used_rect.position.x, used_rect.position.y) * tile_size,
		Vector2(used_rect.size.x, used_rect.size.y) * tile_size
	)
