extends RefCounted
class_name ConsumableSpawnDatabase

const DEFAULT_CONSUMABLE_ID := ItemDatabase.CONSUMABLE_BONE_FLASK

const CONSUMABLE_SPAWN_POOL := [
	ItemDatabase.CONSUMABLE_BONE_FLASK,
	ItemDatabase.CONSUMABLE_BONE_REPAIR_KIT,
	ItemDatabase.CONSUMABLE_SOUL_VIAL,
	ItemDatabase.CONSUMABLE_SWIFT_BONE,
]


static func get_random_consumable_id() -> String:
	if CONSUMABLE_SPAWN_POOL.is_empty():
		return DEFAULT_CONSUMABLE_ID

	return String(CONSUMABLE_SPAWN_POOL.pick_random())


static func get_consumable_scene(consumable_id: String) -> PackedScene:
	var scene_path := ItemDatabase.get_consumable_pickup_scene_path(consumable_id)
	if scene_path == "":
		return null

	return load(scene_path) as PackedScene


static func get_random_consumable_scene() -> PackedScene:
	return get_consumable_scene(get_random_consumable_id())
