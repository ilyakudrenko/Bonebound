extends RefCounted
class_name ChallengeDatabase

const CHALLENGE_KILL_TWO_NO_DAMAGE := "kill_two_no_damage"
const CHALLENGE_BODY_PART_KILL := "body_part_kill"
const CHALLENGE_SACRIFICE_LEFT_ARM := "sacrifice_left_arm"

const CHALLENGES := {
	CHALLENGE_KILL_TWO_NO_DAMAGE: {
		"title": "No-Hit Hunt",
		"description": "Kill 2 enemies without taking damage.",
		"required_progress": 2,
	},
	CHALLENGE_BODY_PART_KILL: {
		"title": "Bone Throw Trial",
		"description": "Kill 1 enemy using a thrown body part.",
		"required_progress": 1,
	},
	CHALLENGE_SACRIFICE_LEFT_ARM: {
		"title": "Left-Hand Offering",
		"description": "Sacrifice your left arm to claim the reward.",
		"required_progress": 1,
	},
}


static func get_challenge_ids() -> Array[String]:
	var challenge_ids: Array[String] = []
	for challenge_id in CHALLENGES.keys():
		challenge_ids.append(String(challenge_id))

	return challenge_ids


static func get_challenge_data(challenge_id: String) -> Dictionary:
	if CHALLENGES.has(challenge_id):
		return CHALLENGES[challenge_id] as Dictionary

	return CHALLENGES[CHALLENGE_KILL_TWO_NO_DAMAGE] as Dictionary
