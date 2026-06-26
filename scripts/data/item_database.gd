extends RefCounted
class_name ItemDatabase

const WEAPON_SWORD := "sword"
const WEAPON_AXE := "axe"
const WEAPON_RAPIER := "rapier"
const WEAPON_BONE_CLEAVER := "bone_cleaver"
const WEAPON_SOUL_HARVESTER := "soul_harvester"

const SHIELD_BASIC := "shield"
const SHIELD_BONE_MIRROR := "bone_mirror"
const SHIELD_SPIKED := "spiked_shield"

const CONSUMABLE_BONE_FLASK := "bone_flask"
const CONSUMABLE_BONE_REPAIR_KIT := "bone_repair_kit"
const CONSUMABLE_SOUL_VIAL := "soul_vial"
const CONSUMABLE_SWIFT_BONE := "swift_bone"

const SPECIAL_EXIT_KEY := "exit_key"

const WEIGHT_LIGHT := "light"
const WEIGHT_MEDIUM := "medium"
const WEIGHT_HEAVY := "heavy"

const RARITY_COMMON := "common"
const RARITY_RARE := "rare"
const RARITY_LEGENDARY := "legendary"

const RARITY_LABELS := {
	RARITY_COMMON: "Common",
	RARITY_RARE: "Rare",
	RARITY_LEGENDARY: "Legendary",
}

const RARITY_COLORS := {
	RARITY_COMMON: Color(0.88, 0.88, 0.92, 1),
	RARITY_RARE: Color(0.35, 0.62, 1.0, 1),
	RARITY_LEGENDARY: Color(1.0, 0.72, 0.22, 1),
}

const ITEM_RARITY_MODIFIERS := {
	WEAPON_SWORD: {
		RARITY_COMMON: {
			"damage_multiplier": 1.0,
			"attack_speed_multiplier": 1.0,
			"description": "Fast and reliable weapon.",
		},
		RARITY_RARE: {
			"damage_multiplier": 1.1,
			"attack_speed_multiplier": 1.1,
			"description": "+10% damage. +10% attack speed.",
		},
		RARITY_LEGENDARY: {
			"damage_multiplier": 1.15,
			"attack_speed_multiplier": 1.15,
			"battle_rhythm_hits_required": 3,
			"battle_rhythm_critical_multiplier": 2.0,
			"description": "+15% damage. +15% attack speed. Battle Rhythm: every 3 consecutive hits without taking damage makes the next attack critical.",
		},
	},
	WEAPON_AXE: {
		RARITY_COMMON: {
			"damage_multiplier": 1.0,
			"stun_duration_multiplier": 1.0,
			"description": "Heavy Weapon. Stuns enemies on hit. Requires Strong Arm.",
		},
		RARITY_RARE: {
			"damage_multiplier": 1.1,
			"stun_duration_multiplier": 1.25,
			"description": "+10% damage. Heavy Impact: +25% stun duration. Requires Strong Arm.",
		},
		RARITY_LEGENDARY: {
			"damage_multiplier": 1.15,
			"stun_duration_multiplier": 1.5,
			"shockwave_damage_multiplier": 0.5,
			"shockwave_radius": 48.0,
			"description": "+15% damage. Heavy Impact: +50% stun duration. Shockwave: hitting a stunned enemy deals area damage. Requires Strong Arm.",
		},
	},
	WEAPON_RAPIER: {
		RARITY_COMMON: {
			"damage_multiplier": 1.0,
			"critical_multiplier": 2.0,
			"description": "Riposte Strike: attacks after rolls or hooks crit for 200%.",
		},
		RARITY_RARE: {
			"damage_multiplier": 1.1,
			"critical_multiplier": 2.3,
			"description": "+10% weapon damage. Riposte crits deal 230% damage.",
		},
		RARITY_LEGENDARY: {
			"damage_multiplier": 1.15,
			"critical_multiplier": 2.3,
			"duelist_momentum_duration": 2.0,
			"duelist_momentum_speed_multiplier": 1.2,
			"duelist_momentum_roll_multiplier": 1.2,
			"description": "+15% weapon damage. Riposte crits deal 230%. Riposte hits grant Duelist Momentum for 2s: +20% movement speed and +20% roll distance.",
		},
	},
	WEAPON_BONE_CLEAVER: {
		RARITY_COMMON: {
			"damage_multiplier": 1.0,
			"execution_damage_multiplier": 1.5,
			"description": "Execution Strike: +50% damage vs stunned enemies.",
		},
		RARITY_RARE: {
			"damage_multiplier": 1.1,
			"execution_damage_multiplier": 1.5,
			"description": "+10% damage. Execution Strike: +50% damage vs stunned enemies.",
		},
		RARITY_LEGENDARY: {
			"damage_multiplier": 1.15,
			"execution_damage_multiplier": 1.5,
			"execution_kill_heal": 1,
			"description": "+15% damage. Execution Strike: +50% damage vs stunned enemies. Execution Kill: killing a stunned enemy restores 1 HP.",
		},
	},
	WEAPON_SOUL_HARVESTER: {
		RARITY_COMMON: {
			"damage_multiplier": 1.0,
			"soul_max_stacks": 5,
			"soul_damage_bonus_per_stack": 0.05,
			"description": "Soul Harvest: +5% damage per Soul Stack. Max Stacks: 5. Taking damage removes all stacks.",
		},
		RARITY_RARE: {
			"damage_multiplier": 1.0,
			"soul_max_stacks": 6,
			"soul_damage_bonus_per_stack": 0.05,
			"description": "Soul Harvest: +5% damage per Soul Stack. Max Stacks: 6. Taking damage removes all stacks.",
		},
		RARITY_LEGENDARY: {
			"damage_multiplier": 1.0,
			"soul_max_stacks": 6,
			"soul_damage_bonus_per_stack": 0.05,
			"soul_max_stack_kill_heal": 1,
			"description": "Soul Harvest: +5% damage per Soul Stack. Max Stacks: 6. At max stacks, kills restore 1 HP. Taking damage removes all stacks.",
		},
	},
	SHIELD_BASIC: {
		RARITY_COMMON: {
			"parry_window_multiplier": 1.0,
			"cooldown_multiplier": 1.0,
			"description": "Parry Melee Attacks.",
		},
		RARITY_RARE: {
			"parry_window_multiplier": 1.15,
			"cooldown_multiplier": 0.9,
			"description": "+15% parry window. -10% shield cooldown.",
		},
		RARITY_LEGENDARY: {
			"parry_window_multiplier": 1.2,
			"cooldown_multiplier": 0.85,
			"perfect_parry_damage_multiplier": 1.1,
			"perfect_parry_damage_duration": 3.0,
			"description": "+20% parry window. -15% shield cooldown. Perfect Parry: successful parries grant +10% damage for 3s.",
		},
	},
	SHIELD_SPIKED: {
		RARITY_COMMON: {
			"counter_damage": 1,
			"parry_window_multiplier": 1.0,
			"description": "Counter Damage: 1. Successful parries deal damage.",
		},
		RARITY_RARE: {
			"counter_damage": 2,
			"parry_window_multiplier": 1.1,
			"description": "Counter Damage: 2. +10% parry window.",
		},
		RARITY_LEGENDARY: {
			"counter_damage": 2,
			"parry_window_multiplier": 1.15,
			"counter_kill_resets_cooldown": true,
			"description": "Counter Damage: 2. +15% parry window. Counter Kill: resets shield cooldown.",
		},
	},
	SHIELD_BONE_MIRROR: {
		RARITY_COMMON: {
			"parry_window_multiplier": 1.0,
			"reflected_projectile_damage_multiplier": 1.0,
			"description": "Reflect Projectiles. Successful projectile parries reflect enemy projectiles.",
		},
		RARITY_RARE: {
			"parry_window_multiplier": 1.1,
			"reflected_projectile_damage_multiplier": 1.2,
			"description": "Reflect Projectiles. Reflected projectile damage +20%. +10% parry window.",
		},
		RARITY_LEGENDARY: {
			"parry_window_multiplier": 1.15,
			"reflected_projectile_damage_multiplier": 1.25,
			"reflected_projectile_kill_cooldown_reduction": 1.0,
			"description": "Reflect Projectiles. Reflected projectile damage +25%. Projectile Kill: -1s shield cooldown. +15% parry window.",
		},
	},
}

const WEAPONS := {
	WEAPON_SWORD: {
		"label": "Sword",
		"description": "Reliable light weapon. Fast, simple, and easy to use.",
		"pickup_scene": "res://scenes/scaled/pickups/SwordPickup_16px.tscn",
		"icon_region": Rect2(0, 0, 32, 32),
		"weight": WEIGHT_LIGHT,
		"damage": 1,
		"startup": 0.08,
		"active": 0.08,
		"recovery": 0.22,
		"move_multiplier": 0.45,
		"hitbox_size": Vector2(36, 24),
		"hitbox_offset": Vector2(26, -27),
		"startup_color": Color(0.85, 0.87, 0.92, 1),
		"active_color": Color(1, 1, 1, 1),
		"recovery_color": Color(0.55, 0.58, 0.64, 1),
		"visual_rect": Rect2(12, -30, 26, 4),
	},
	WEAPON_AXE: {
		"label": "Axe",
		"description": "Heavy weapon. Slow attack, high damage, stuns on hit.",
		"pickup_scene": "res://scenes/scaled/pickups/AxePickup_16px.tscn",
		"icon_region": Rect2(32, 0, 32, 32),
		"weight": WEIGHT_HEAVY,
		"damage": 3,
		"startup": 0.18,
		"active": 0.12,
		"recovery": 0.75,
		"move_multiplier": 0.22,
		"hitbox_size": Vector2(42, 30),
		"hitbox_offset": Vector2(29, -27),
		"startup_color": Color(0.62, 0.45, 0.25, 1),
		"active_color": Color(0.95, 0.75, 0.38, 1),
		"recovery_color": Color(0.35, 0.25, 0.16, 1),
			"visual_rect": Rect2(11, -36, 30, 16),
			"stun_on_hit": true,
			"stun_duration": 1.0,
		},
	WEAPON_RAPIER: {
		"label": "Grave Rapier",
		"description": "Fast light weapon. Attacks after rolls or hooks can crit.",
		"pickup_scene": "res://scenes/scaled/pickups/RapierPickup_16px.tscn",
		"icon_region": Rect2(96, 128, 32, 32),
		"weight": WEIGHT_LIGHT,
		"damage": 1,
		"startup": 0.04,
		"active": 0.06,
		"recovery": 0.12,
		"move_multiplier": 0.8,
		"hitbox_size": Vector2(46, 14),
		"hitbox_offset": Vector2(32, -27),
		"startup_color": Color(0.95, 0.82, 0.55, 1),
		"active_color": Color(1.0, 0.95, 0.68, 1),
		"critical_active_color": Color(1.0, 0.35, 0.9, 1),
		"recovery_color": Color(0.55, 0.42, 0.65, 1),
		"visual_rect": Rect2(12, -30, 32, 3),
		"riposte_window": 0.75,
		"critical_multiplier": 2,
	},
	WEAPON_BONE_CLEAVER: {
		"label": "Bone Cleaver",
		"description": "Heavy execution weapon. Deals bonus damage to stunned enemies.",
		"pickup_scene": "res://scenes/scaled/pickups/BoneCleaverPickup_16px.tscn",
		"icon_region": Rect2(0, 128, 32, 32),
			"weight": WEIGHT_HEAVY,
			"damage": 4,
			"startup": 0.26,
		"active": 0.1,
		"recovery": 0.95,
		"move_multiplier": 0.16,
		"hitbox_size": Vector2(40, 28),
		"hitbox_offset": Vector2(28, -27),
		"startup_color": Color(0.62, 0.52, 0.72, 1),
		"active_color": Color(0.92, 0.86, 1.0, 1),
		"recovery_color": Color(0.36, 0.28, 0.42, 1),
		"visual_rect": Rect2(10, -38, 32, 20),
		"stagger_duration": 0.25,
	},
	WEAPON_SOUL_HARVESTER: {
		"label": "Soul Harvester",
		"description": "Medium scythe. Gains Soul Stacks from kills until you take damage.",
		"pickup_scene": "res://scenes/scaled/pickups/SoulHarvesterPickup_16px.tscn",
		"icon_region": Rect2(0, 32, 32, 32),
		"weight": WEIGHT_MEDIUM,
		"damage": 3,
		"startup": 0.1,
		"active": 0.1,
		"recovery": 0.34,
		"move_multiplier": 0.36,
		"hitbox_size": Vector2(48, 24),
		"hitbox_offset": Vector2(32, -28),
		"startup_color": Color(0.36, 0.2, 0.68, 1),
		"active_color": Color(0.25, 0.78, 1.0, 1),
		"recovery_color": Color(0.18, 0.12, 0.35, 1),
		"visual_rect": Rect2(10, -34, 36, 12),
		"stagger_duration": 0.2,
		"soul_max_stacks": 5,
		"soul_damage_bonus_per_stack": 0.05,
	},
}

const SHIELDS := {
	SHIELD_BASIC: {
		"label": "Shield",
		"description": "Basic off-hand shield. Timed parries stun melee attackers.",
		"pickup_scene": "res://scenes/scaled/pickups/ShieldPickup_16px.tscn",
		"icon_region": Rect2(288, 64, 32, 32),
		"throw_damage_bonus": 1,
		"block_color": Color(0.14, 0.62, 0.78, 1),
		"parry_color": Color(0.75, 0.95, 1, 1),
	},
	SHIELD_BONE_MIRROR: {
		"label": "Bone Mirror",
		"description": "Reflective shield. Timed parries can turn projectiles back.",
		"pickup_scene": "res://scenes/scaled/pickups/BoneMirrorPickup_16px.tscn",
		"icon_region": Rect2(288, 128, 32, 32),
		"throw_damage_bonus": 1,
		"block_color": Color(0.38, 0.22, 0.72, 1),
		"parry_color": Color(0.85, 0.55, 1.0, 1),
		"reflect_size": Vector2(38, 48),
		"reflect_offset": Vector2(18, -25),
	},
	SHIELD_SPIKED: {
		"label": "Spiked Shield",
		"description": "Aggressive shield. Successful melee parries deal counter damage.",
		"pickup_scene": "res://scenes/scaled/pickups/SpikedShieldPickup_16px.tscn",
		"icon_region": Rect2(288, 32, 32, 32),
		"throw_damage_bonus": 1,
		"block_color": Color(0.08, 0.34, 0.72, 1),
		"parry_color": Color(0.35, 0.82, 1.0, 1),
		"counter_damage": 1,
	},
}

const CONSUMABLES := {
	CONSUMABLE_BONE_FLASK: {
		"label": "Bone Flask",
		"description": "Restore 25 HP.",
		"pickup_scene": "res://scenes/scaled/pickups/BoneFlaskPickup_16px.tscn",
		"icon_texture": "res://assets/16x16 RPG Item Pack/items_sheet.png",
		"icon_region": Rect2(80, 48, 16, 16),
		"heal_amount": 25,
	},
	CONSUMABLE_BONE_REPAIR_KIT: {
		"label": "Bone Repair Kit",
		"description": "Restore all missing body parts.",
		"pickup_scene": "res://scenes/scaled/pickups/BoneRepairKitPickup_16px.tscn",
		"icon_texture": "res://assets/16x16 RPG Item Pack/items_sheet.png",
		"icon_region": Rect2(112, 48, 16, 16),
	},
	CONSUMABLE_SOUL_VIAL: {
		"label": "Soul Vial",
		"description": "Gain 3 Soul Stacks.",
		"pickup_scene": "res://scenes/scaled/pickups/SoulVialPickup_16px.tscn",
		"icon_texture": "res://assets/16x16 RPG Item Pack/items_sheet.png",
		"icon_region": Rect2(80, 64, 16, 16),
		"soul_stacks": 3,
	},
	CONSUMABLE_SWIFT_BONE: {
		"label": "Swift Bone",
		"description": "+20% movement speed. +20% roll distance. Duration: 20s.",
		"pickup_scene": "res://scenes/scaled/pickups/SwiftBonePickup_16px.tscn",
		"icon_texture": "res://assets/16x16 RPG Item Pack/items_sheet.png",
		"icon_region": Rect2(96, 64, 16, 16),
		"speed_multiplier": 1.2,
		"roll_multiplier": 1.2,
		"duration": 20.0,
	},
}

const SPECIAL_ITEMS := {
	SPECIAL_EXIT_KEY: {
		"label": "Exit Key",
		"description": "A key for a locked challenge door.",
		"pickup_scene": "res://scenes/scaled/pickups/ExitKeyPickup_16px.tscn",
		"icon_texture": "res://assets/16x16 RPG Item Pack/items_sheet.png",
		"icon_region": Rect2(80, 128, 16, 16),
	},
}


static func get_weapon_data(weapon_id: String) -> Dictionary:
	return WEAPONS.get(weapon_id, {}) as Dictionary


static func get_weapon_value(weapon_id: String, key: String, fallback: Variant) -> Variant:
	return get_weapon_data(weapon_id).get(key, fallback)


static func get_item_rarity_modifier(item_id: String, rarity: String) -> Dictionary:
	var item_modifiers := ITEM_RARITY_MODIFIERS.get(item_id, {}) as Dictionary
	return item_modifiers.get(rarity, item_modifiers.get(RARITY_COMMON, {})) as Dictionary


static func get_item_rarity_value(item_id: String, rarity: String, key: String, fallback: Variant) -> Variant:
	return get_item_rarity_modifier(item_id, rarity).get(key, fallback)


static func get_item_rarity_description(item_id: String, rarity: String) -> String:
	return String(get_item_rarity_value(item_id, rarity, "description", ""))


static func get_weapon_pickup_scene_path(weapon_id: String) -> String:
	return String(get_weapon_value(weapon_id, "pickup_scene", ""))


static func get_shield_data(shield_id: String) -> Dictionary:
	return SHIELDS.get(shield_id, {}) as Dictionary


static func get_shield_value(shield_id: String, key: String, fallback: Variant) -> Variant:
	return get_shield_data(shield_id).get(key, fallback)


static func get_shield_pickup_scene_path(shield_id: String) -> String:
	return String(get_shield_value(shield_id, "pickup_scene", ""))


static func get_consumable_data(consumable_id: String) -> Dictionary:
	return CONSUMABLES.get(consumable_id, {}) as Dictionary


static func get_consumable_value(consumable_id: String, key: String, fallback: Variant) -> Variant:
	return get_consumable_data(consumable_id).get(key, fallback)


static func get_consumable_pickup_scene_path(consumable_id: String) -> String:
	return String(get_consumable_value(consumable_id, "pickup_scene", ""))


static func get_special_item_data(item_id: String) -> Dictionary:
	return SPECIAL_ITEMS.get(item_id, {}) as Dictionary


static func get_special_item_value(item_id: String, key: String, fallback: Variant) -> Variant:
	return get_special_item_data(item_id).get(key, fallback)


static func get_special_item_pickup_scene_path(item_id: String) -> String:
	return String(get_special_item_value(item_id, "pickup_scene", ""))


static func is_weapon(item_id: String) -> bool:
	return WEAPONS.has(item_id)


static func is_shield(item_id: String) -> bool:
	return SHIELDS.has(item_id)


static func is_consumable(item_id: String) -> bool:
	return CONSUMABLES.has(item_id)


static func is_special_item(item_id: String) -> bool:
	return SPECIAL_ITEMS.has(item_id)


static func get_item_data(item_id: String) -> Dictionary:
	if is_weapon(item_id):
		return get_weapon_data(item_id)
	if is_shield(item_id):
		return get_shield_data(item_id)
	if is_consumable(item_id):
		return get_consumable_data(item_id)
	if is_special_item(item_id):
		return get_special_item_data(item_id)
	return {}


static func get_item_pickup_scene_path(item_id: String) -> String:
	if is_weapon(item_id):
		return get_weapon_pickup_scene_path(item_id)
	if is_shield(item_id):
		return get_shield_pickup_scene_path(item_id)
	if is_consumable(item_id):
		return get_consumable_pickup_scene_path(item_id)
	if is_special_item(item_id):
		return get_special_item_pickup_scene_path(item_id)
	return ""


static func get_chest_loot_pool() -> Array:
	var loot_pool: Array[String] = []

	for weapon_id in WEAPONS.keys():
		loot_pool.append(String(weapon_id))
	for shield_id in SHIELDS.keys():
		loot_pool.append(String(shield_id))

	return loot_pool


static func get_rarity_label(rarity: String) -> String:
	return String(RARITY_LABELS.get(rarity, RARITY_LABELS[RARITY_COMMON]))


static func get_rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity, RARITY_COLORS[RARITY_COMMON]) as Color
