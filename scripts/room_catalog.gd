extends RefCounted
class_name RoomCatalog

const START_ROOM := preload("res://scenes/rooms/Room_Start.tscn")
const EXIT_ROOM := preload("res://scenes/rooms/Room_Exit.tscn")

const COMBAT_ROOMS := [
	preload("res://scenes/rooms/Room_Combat_1.tscn"),
	preload("res://scenes/rooms/Room_Combat_2.tscn"),
	preload("res://scenes/rooms/Room_Combat_3.tscn"),
	preload("res://scenes/rooms/Room_Combat_4.tscn"),
	preload("res://scenes/rooms/Room_Combat_5.tscn"),
]

const LOOT_ROOMS := [
	preload("res://scenes/rooms/Room_Loot_1.tscn"),
	preload("res://scenes/rooms/Room_Loot_2.tscn"),
]


static func get_start_room() -> PackedScene:
	return START_ROOM


static func get_combat_rooms() -> Array:
	return COMBAT_ROOMS.duplicate()


static func get_loot_rooms() -> Array:
	return LOOT_ROOMS.duplicate()


static func get_exit_room() -> PackedScene:
	return EXIT_ROOM
