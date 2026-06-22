extends RefCounted
class_name EnemySpawnDatabase

const REGULAR_ENEMY_WEIGHT := 50
const SHIELD_ENEMY_WEIGHT := 30
const BONE_LOBBER_WEIGHT := 20

const DEFAULT_ENEMY_SCENE := preload("res://scenes/scaled/enemies/DummyEnemy_16px.tscn")

const ENEMY_SPAWN_TABLE := [
	{
		"label": "Regular Enemy",
		"weight": REGULAR_ENEMY_WEIGHT,
		"scene": DEFAULT_ENEMY_SCENE,
	},
	{
		"label": "Shield Enemy",
		"weight": SHIELD_ENEMY_WEIGHT,
		"scene": preload("res://scenes/scaled/enemies/ShieldEnemy_16px.tscn"),
	},
	{
		"label": "Bone Lobber",
		"weight": BONE_LOBBER_WEIGHT,
		"scene": preload("res://scenes/scaled/enemies/BoneLobber_16px.tscn"),
	},
]
