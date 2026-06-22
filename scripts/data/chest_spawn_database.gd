extends RefCounted
class_name ChestSpawnDatabase

const COMMON_CHEST_WEIGHT := 65
const RARE_CHEST_WEIGHT := 25
const LEGENDARY_CHEST_WEIGHT := 10

const DEFAULT_CHEST_SCENE := preload("res://scenes/scaled/world/LootChest_16px.tscn")

const CHEST_SPAWN_TABLE := [
	{
		"label": "Common Chest",
		"weight": COMMON_CHEST_WEIGHT,
		"rarity": ItemDatabase.RARITY_COMMON,
		"scene": DEFAULT_CHEST_SCENE,
	},
	{
		"label": "Rare Chest",
		"weight": RARE_CHEST_WEIGHT,
		"rarity": ItemDatabase.RARITY_RARE,
		"scene": DEFAULT_CHEST_SCENE,
	},
	{
		"label": "Legendary Chest",
		"weight": LEGENDARY_CHEST_WEIGHT,
		"rarity": ItemDatabase.RARITY_LEGENDARY,
		"scene": DEFAULT_CHEST_SCENE,
	},
]
