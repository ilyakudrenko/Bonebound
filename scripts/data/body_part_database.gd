extends RefCounted
class_name BodyPartDatabase

const COMMON_DROP_WEIGHT := 60
const UNCOMMON_DROP_WEIGHT := 30
const RARE_DROP_WEIGHT := 10

const BODY_PART_LEFT_ARM := "left_arm"
const BODY_PART_RIGHT_ARM := "right_arm"
const BODY_PART_LEFT_LEG := "left_leg"
const BODY_PART_RIGHT_LEG := "right_leg"
const BODY_PART_HEAD := "head"
const BODY_PART_GENERIC_LEG := "leg"

const ENEMY_ARM_REWARD := "enemy_arm"
const BOOMERANG_ARMS_REWARD := "boomerang_arms"
const HARPOON_ARMS_REWARD := "harpoon_arms"
const ENEMY_LEGS_REWARD := "enemy_legs"
const STOMP_LEGS_REWARD := "stomp_legs"
const SPIDER_LEGS_REWARD := "spider_legs"

const FALLBACK_ARM_REWARD := ENEMY_ARM_REWARD
const FALLBACK_LEG_REWARD := ENEMY_LEGS_REWARD

const BASIC_ENEMY_ARM_REWARDS := [ENEMY_ARM_REWARD, BOOMERANG_ARMS_REWARD]
const BASIC_ENEMY_LEG_REWARDS := [ENEMY_LEGS_REWARD, STOMP_LEGS_REWARD]
const SHIELD_ENEMY_ARM_REWARDS := [ENEMY_ARM_REWARD, HARPOON_ARMS_REWARD]
const SHIELD_ENEMY_LEG_REWARDS := [ENEMY_LEGS_REWARD, STOMP_LEGS_REWARD]
const BONE_LOBBER_ARM_REWARDS := [ENEMY_ARM_REWARD, BOOMERANG_ARMS_REWARD, HARPOON_ARMS_REWARD]
const BONE_LOBBER_LEG_REWARDS := [ENEMY_LEGS_REWARD, SPIDER_LEGS_REWARD]

const REWARDS := {
	ENEMY_ARM_REWARD: {
		"label": "Enemy Arm",
		"description": "Strong arm. Required for heavy weapons.",
		"rarity": "Common",
		"drop_weight": COMMON_DROP_WEIGHT,
		"color": Color(1, 0.35, 0.75, 1),
	},
	BOOMERANG_ARMS_REWARD: {
		"label": "Boomerang Arm",
		"description": "Thrown arm returns to you. Longer throw cooldown.",
		"rarity": "Uncommon",
		"drop_weight": UNCOMMON_DROP_WEIGHT,
		"color": Color(0.95, 0.55, 0.1, 1),
	},
	HARPOON_ARMS_REWARD: {
		"label": "Harpoon Arm",
		"description": "Hooks enemies, pulls them close, then stuns them.",
		"rarity": "Rare",
		"drop_weight": RARE_DROP_WEIGHT,
		"color": Color(0.72, 0.72, 0.78, 1),
	},
	ENEMY_LEGS_REWARD: {
		"label": "Enemy Legs",
		"description": "Allows one extra jump while airborne.",
		"rarity": "Common",
		"drop_weight": COMMON_DROP_WEIGHT,
		"color": Color(0.45, 0.85, 1, 1),
	},
	STOMP_LEGS_REWARD: {
		"label": "Stomp Legs",
		"description": "Press S in air to slam down and stun nearby enemies.",
		"rarity": "Uncommon",
		"drop_weight": UNCOMMON_DROP_WEIGHT,
		"color": Color(0.65, 0.35, 1, 1),
	},
	SPIDER_LEGS_REWARD: {
		"label": "Spider Legs",
		"description": "Hold Space near a wall to climb upward for a short burst.",
		"rarity": "Rare",
		"drop_weight": RARE_DROP_WEIGHT,
		"color": Color(0.18, 0.95, 0.65, 1),
	},
}


static func get_reward_data(reward_id: String, fallback_reward_id: String) -> Dictionary:
	return REWARDS.get(reward_id, REWARDS[fallback_reward_id])


static func get_drop_weight(reward_id: String) -> int:
	var reward_data: Dictionary = REWARDS.get(reward_id, {})
	if reward_data.is_empty():
		return 0

	return int(reward_data.get("drop_weight", 0))
