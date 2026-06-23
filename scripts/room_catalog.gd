extends RefCounted
class_name RoomCatalog

const ROOMS_FOLDER := "res://scenes/rooms/"
const ROOM_PREFIX := "room"
const ROOM_TYPE_START := "start"
const ROOM_TYPE_EXIT := "exit"
const ROOM_TYPE_COMBAT := "combat"
const ROOM_TYPE_LOOT := "loot"
const ROOM_TYPE_PUZZLE := "puzzle"
const VALID_ROOM_TYPES := [
	ROOM_TYPE_START,
	ROOM_TYPE_EXIT,
	ROOM_TYPE_COMBAT,
	ROOM_TYPE_LOOT,
	ROOM_TYPE_PUZZLE,
]


static func get_start_room() -> PackedScene:
	return get_first_room_for_type(ROOM_TYPE_START)


static func get_combat_rooms() -> Array:
	return get_rooms_for_type(ROOM_TYPE_COMBAT)


static func get_loot_rooms() -> Array:
	return get_rooms_for_type(ROOM_TYPE_LOOT)


static func get_puzzle_rooms() -> Array:
	return get_rooms_for_type(ROOM_TYPE_PUZZLE)


static func get_exit_room() -> PackedScene:
	return get_first_room_for_type(ROOM_TYPE_EXIT)


static func get_rooms_for_type(room_type: String) -> Array:
	var room_records := get_room_records_for_type(room_type)
	var rooms := []

	for record in room_records:
		var room_scene := load(String(record["path"])) as PackedScene
		if room_scene != null:
			rooms.append(room_scene)

	return rooms


static func get_first_room_for_type(room_type: String) -> PackedScene:
	var room_records := get_room_records_for_type(room_type)

	if room_records.is_empty():
		push_warning("No room found for type: %s" % room_type)
		return null

	return load(String(room_records[0]["path"])) as PackedScene


static func get_room_records_for_type(room_type: String) -> Array:
	var room_records := discover_room_records()
	var matching_records := []
	var used_room_ids := {}

	for record in room_records:
		if String(record["type"]) != room_type:
			continue

		var room_id := int(record["id"])
		if used_room_ids.has(room_id):
			push_warning("Duplicate %s room ID %s ignored: %s" % [room_type, room_id, String(record["path"])])
			continue

		used_room_ids[room_id] = true
		matching_records.append(record)

	matching_records.sort_custom(sort_room_records_by_id)
	return matching_records


static func discover_room_records() -> Array:
	var room_records := []
	var files := DirAccess.get_files_at(ROOMS_FOLDER)

	for file_name in files:
		if not file_name.ends_with(".tscn"):
			continue

		var room_record := parse_room_file(file_name)
		if room_record.is_empty():
			continue

		room_records.append(room_record)

	return room_records


static func parse_room_file(file_name: String) -> Dictionary:
	var file_base_name := file_name.get_basename()
	var name_parts := file_base_name.to_lower().split("_", false)

	if name_parts.size() < 2:
		return {}
	if name_parts[0] != ROOM_PREFIX:
		return {}

	var room_type := String(name_parts[1])
	if not VALID_ROOM_TYPES.has(room_type):
		return {}

	return {
		"type": room_type,
		"id": get_room_id_from_name_parts(name_parts),
		"path": ROOMS_FOLDER + file_name,
	}


static func get_room_id_from_name_parts(name_parts: PackedStringArray) -> int:
	if name_parts.size() < 3:
		return 0

	var room_id_text := String(name_parts[2])
	if room_id_text.is_valid_int():
		return int(room_id_text)

	return 0


static func sort_room_records_by_id(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))

	if a_id == b_id:
		return String(a.get("path", "")) < String(b.get("path", ""))

	return a_id < b_id
