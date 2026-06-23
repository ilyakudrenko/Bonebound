extends RefCounted
class_name RoomSequenceCatalog

const SEQUENCES_FOLDER := "res://scenes/rooms/room_sequences/"
const FILE_PREFIX := "level"
const LEVEL_GRAVEYARD := "graveyard"

const ROOM_TYPE_ALIASES := {
	"start": RoomCatalog.ROOM_TYPE_START,
	"combat": RoomCatalog.ROOM_TYPE_COMBAT,
	"loot": RoomCatalog.ROOM_TYPE_LOOT,
	"puzzle": RoomCatalog.ROOM_TYPE_PUZZLE,
	"exit": RoomCatalog.ROOM_TYPE_EXIT,
	"end": RoomCatalog.ROOM_TYPE_EXIT,
}

const FALLBACK_GRAVEYARD_SEQUENCES := [
	[
		RoomCatalog.ROOM_TYPE_START,
		RoomCatalog.ROOM_TYPE_COMBAT,
		RoomCatalog.ROOM_TYPE_COMBAT,
		RoomCatalog.ROOM_TYPE_LOOT,
		RoomCatalog.ROOM_TYPE_COMBAT,
		RoomCatalog.ROOM_TYPE_EXIT,
	],
	[
		RoomCatalog.ROOM_TYPE_START,
		RoomCatalog.ROOM_TYPE_COMBAT,
		RoomCatalog.ROOM_TYPE_LOOT,
		RoomCatalog.ROOM_TYPE_COMBAT,
		RoomCatalog.ROOM_TYPE_COMBAT,
		RoomCatalog.ROOM_TYPE_LOOT,
		RoomCatalog.ROOM_TYPE_EXIT,
	],
]


static func get_sequences_for_level(level_name: String) -> Array:
	var sequences := discover_sequences_for_level(level_name)
	if not sequences.is_empty():
		return sequences

	if level_name.to_lower() == LEVEL_GRAVEYARD:
		return FALLBACK_GRAVEYARD_SEQUENCES.duplicate(true)

	return []


static func discover_sequences_for_level(level_name: String) -> Array:
	var sequence_records := []
	var files := DirAccess.get_files_at(SEQUENCES_FOLDER)

	for file_name in files:
		if not file_name.ends_with(".txt"):
			continue
		if not is_sequence_file_for_level(file_name, level_name):
			continue

		var sequence := parse_sequence_file(SEQUENCES_FOLDER + file_name)
		if sequence.is_empty():
			push_warning("Ignored empty or invalid level sequence file: %s" % file_name)
			continue

		sequence_records.append({
			"id": get_sequence_id_from_file_name(file_name),
			"path": SEQUENCES_FOLDER + file_name,
			"sequence": sequence,
		})

	sequence_records.sort_custom(sort_sequence_records_by_id)

	var sequences := []
	for record in sequence_records:
		sequences.append(record["sequence"])

	return sequences


static func is_sequence_file_for_level(file_name: String, level_name: String) -> bool:
	var file_base_name := file_name.get_basename()
	var name_parts := file_base_name.to_lower().split("_", false)

	if name_parts.size() < 3:
		return false
	if name_parts[0] != FILE_PREFIX:
		return false

	return String(name_parts[1]) == level_name.to_lower()


static func parse_sequence_file(file_path: String) -> Array:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_warning("Could not read level sequence file: %s" % file_path)
		return []

	var raw_text := file.get_as_text()
	var tokens := tokenize_sequence_text(raw_text)
	var sequence := []

	for token in tokens:
		var room_type := normalize_room_type(token)
		if room_type == "":
			push_warning("Unknown room type '%s' in sequence file: %s" % [token, file_path])
			continue

		sequence.append(room_type)

	return sequence


static func tokenize_sequence_text(raw_text: String) -> PackedStringArray:
	var normalized := raw_text.to_lower()
	normalized = normalized.replace("->", " ")
	normalized = normalized.replace(",", " ")
	normalized = normalized.replace(";", " ")
	normalized = normalized.replace("\n", " ")
	normalized = normalized.replace("\t", " ")

	return normalized.split(" ", false)


static func normalize_room_type(raw_token: String) -> String:
	var token := raw_token.strip_edges().trim_prefix("_").trim_suffix("_")
	if token == "":
		return ""
	if not ROOM_TYPE_ALIASES.has(token):
		return ""

	return String(ROOM_TYPE_ALIASES[token])


static func get_sequence_id_from_file_name(file_name: String) -> int:
	var file_base_name := file_name.get_basename()
	var name_parts := file_base_name.to_lower().split("_", false)

	if name_parts.size() < 3:
		return 0

	var sequence_id_text := String(name_parts[2])
	if sequence_id_text.is_valid_int():
		return int(sequence_id_text)

	return 0


static func sort_sequence_records_by_id(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))

	if a_id == b_id:
		return String(a.get("path", "")) < String(b.get("path", ""))

	return a_id < b_id
