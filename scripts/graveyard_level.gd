extends Node2D

const TILE_SIZE_FALLBACK := Vector2(16, 16)
const DEFAULT_PLAYER_START_POSITION := Vector2(64, 320)
const LEVEL_NAME := "graveyard"
const EXIT_DOOR_MODE_CHALLENGE := "challenge"
const EXIT_DOOR_MODE_KEY := "key"

@export var room_gap := 0.0
@export_range(0.0, 1.0, 0.01) var key_exit_mode_chance: float = 0.5

@onready var rooms_parent: Node2D = $Rooms
@onready var player: Node2D = $Player
@onready var gameplay_camera: Camera2D = $GameplayCamera
@onready var run_stats: RunStats = $RunStats
@onready var death_run_summary_ui: CanvasLayer = $DeathRunSummaryUI

var rng := RandomNumberGenerator.new()
var exit_door_mode: String = EXIT_DOOR_MODE_CHALLENGE


func _ready() -> void:
	rng.randomize()
	exit_door_mode = pick_exit_door_mode()
	setup_run_stats_ui()
	build_level()


func setup_run_stats_ui() -> void:
	if death_run_summary_ui.has_method("setup"):
		death_run_summary_ui.call("setup", run_stats)

	if player.has_signal("enemy_killed"):
		player.connect("enemy_killed", Callable(self, "_on_player_enemy_killed"))
	if player.has_signal("player_died"):
		player.connect("player_died", Callable(self, "_on_player_died"))


func _on_player_enemy_killed() -> void:
	run_stats.register_kill()


func _on_player_died() -> void:
	if death_run_summary_ui.has_method("show_death_summary"):
		death_run_summary_ui.call("show_death_summary")


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
		configure_room_exit_doors(room)

		if room_index == 0:
			player_start_position = room.position + test_player_position

		next_room_left = room.position.x + room_bounds.position.x + room_bounds.size.x + room_gap

	player.global_position = player_start_position
	gameplay_camera.global_position = player.global_position + Vector2(0, -24)


func get_room_sequence() -> Array:
	var sequence: Array = []
	var sequence_template: Array = pick_random_sequence_template()
	sequence_template = prepare_sequence_template_for_exit_mode(sequence_template)

	for room_type in sequence_template:
		sequence.append(pick_random_room_for_type(room_type))

	return sequence


func pick_random_sequence_template() -> Array:
	var sequence_templates := RoomSequenceCatalog.get_sequences_for_level(LEVEL_NAME)
	if sequence_templates.is_empty():
		push_warning("No level sequences found for level: %s" % LEVEL_NAME)
		return []

	var eligible_templates := get_eligible_sequence_templates(sequence_templates)
	var template_index := rng.randi_range(0, eligible_templates.size() - 1)
	return eligible_templates[template_index].duplicate()


func get_eligible_sequence_templates(sequence_templates: Array) -> Array:
	if exit_door_mode != EXIT_DOOR_MODE_KEY:
		return sequence_templates

	var key_templates: Array = []
	for raw_sequence_template in sequence_templates:
		var sequence_template: Array = raw_sequence_template as Array
		if sequence_template.has(RoomCatalog.ROOM_TYPE_KEY):
			key_templates.append(sequence_template)

	if key_templates.is_empty():
		return sequence_templates

	return key_templates


func prepare_sequence_template_for_exit_mode(sequence_template: Array) -> Array:
	var prepared_sequence: Array = []
	var has_key_room := false

	for raw_room_type in sequence_template:
		var room_type := String(raw_room_type)
		if room_type == RoomCatalog.ROOM_TYPE_KEY:
			if exit_door_mode == EXIT_DOOR_MODE_KEY:
				prepared_sequence.append(room_type)
				has_key_room = true
			continue

		if exit_door_mode == EXIT_DOOR_MODE_KEY and room_type == RoomCatalog.ROOM_TYPE_EXIT and not has_key_room:
			prepared_sequence.append(RoomCatalog.ROOM_TYPE_KEY)
			has_key_room = true

		prepared_sequence.append(room_type)

	if exit_door_mode == EXIT_DOOR_MODE_KEY and not has_key_room:
		prepared_sequence.append(RoomCatalog.ROOM_TYPE_KEY)

	return prepared_sequence


func pick_exit_door_mode() -> String:
	if rng.randf() < key_exit_mode_chance:
		return EXIT_DOOR_MODE_KEY

	return EXIT_DOOR_MODE_CHALLENGE


func pick_random_room_for_type(room_type: String) -> PackedScene:
	return pick_random_room(RoomCatalog.get_rooms_for_type(room_type))


func pick_random_room(room_pool: Array) -> PackedScene:
	if room_pool.is_empty():
		return null

	return room_pool[rng.randi_range(0, room_pool.size() - 1)]


func clear_rooms() -> void:
	for child in rooms_parent.get_children():
		child.queue_free()


func configure_room_exit_doors(room: Node) -> void:
	for child in room.get_children():
		if child.has_method("set_lock_mode"):
			child.call("set_lock_mode", exit_door_mode)

		configure_room_exit_doors(child)


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
