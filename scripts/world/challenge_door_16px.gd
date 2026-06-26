extends "res://scripts/door_16px.gd"

const LOCK_MODE_CHALLENGE := "challenge"
const LOCK_MODE_KEY := "key"

@export_enum("challenge", "key") var lock_mode: String = LOCK_MODE_CHALLENGE
@export var minimum_required_enemy_kills := 5
@export var maximum_required_enemy_kills := 7
@export var challenge_title := "Challenge Door"
@export var challenge_description := "Defeat enemies to unlock this door."
@export var key_title := "Key Door"
@export var key_description := "Find the exit key to unlock this door."

@onready var challenge_panel: Node2D = $ChallengePanel
@onready var title_label: Label = $ChallengePanel/TitleLabel
@onready var description_label: Label = $ChallengePanel/DescriptionLabel
@onready var progress_label: Label = $ChallengePanel/ProgressLabel
@onready var action_label: Label = $ChallengePanel/ActionLabel

var required_enemy_kills: int = 5


func _ready() -> void:
	super()
	required_enemy_kills = pick_required_enemy_kills()
	challenge_panel.hide()
	update_challenge_panel()


func toggle_door() -> void:
	if is_open:
		return

	update_challenge_panel()
	challenge_panel.show()

	if not is_challenge_complete():
		if nearby_player != null and nearby_player.has_method("show_feedback_message"):
			nearby_player.call("show_feedback_message", "Door locked")
		return

	if lock_mode == LOCK_MODE_KEY and not consume_player_exit_key():
		if nearby_player != null and nearby_player.has_method("show_feedback_message"):
			nearby_player.call("show_feedback_message", "Need key")
		return

	open_door()


func open_door() -> void:
	super()
	challenge_panel.hide()


func close_door() -> void:
	return


func update_prompt_visibility() -> void:
	if player_is_nearby and not is_open:
		prompt.show()
		update_challenge_panel()
		challenge_panel.show()
	else:
		prompt.hide()
		challenge_panel.hide()


func is_challenge_complete() -> bool:
	if lock_mode == LOCK_MODE_KEY:
		return player_has_exit_key()

	return get_player_kill_count() >= required_enemy_kills


func set_lock_mode(new_lock_mode: String) -> void:
	if new_lock_mode == LOCK_MODE_KEY:
		lock_mode = LOCK_MODE_KEY
	else:
		lock_mode = LOCK_MODE_CHALLENGE

	if is_node_ready():
		update_challenge_panel()


func pick_required_enemy_kills() -> int:
	var minimum_kills := mini(minimum_required_enemy_kills, maximum_required_enemy_kills)
	var maximum_kills := maxi(minimum_required_enemy_kills, maximum_required_enemy_kills)

	return randi_range(minimum_kills, maximum_kills)


func get_player_kill_count() -> int:
	if nearby_player == null:
		return 0
	if nearby_player.has_method("get_level_enemy_kills"):
		return int(nearby_player.call("get_level_enemy_kills"))

	var kill_count_value: Variant = nearby_player.get("level_enemy_kills")
	if kill_count_value == null:
		return 0

	return int(kill_count_value)


func update_challenge_panel() -> void:
	if lock_mode == LOCK_MODE_KEY:
		update_key_panel()
		return

	var kill_count := get_player_kill_count()
	var shown_kill_count := mini(kill_count, required_enemy_kills)

	title_label.text = challenge_title
	description_label.text = challenge_description
	progress_label.text = "Kills: " + str(shown_kill_count) + "/" + str(required_enemy_kills)

	if is_challenge_complete():
		action_label.text = "Complete. Press E to open."
	else:
		action_label.text = "Locked."


func update_key_panel() -> void:
	title_label.text = key_title
	description_label.text = key_description

	if player_has_exit_key():
		progress_label.text = "Key: Found"
		action_label.text = "Complete. Press E to open."
	else:
		progress_label.text = "Key: Missing"
		action_label.text = "Locked."


func player_has_exit_key() -> bool:
	if nearby_player == null:
		return false
	if nearby_player.has_method("has_level_exit_key"):
		return bool(nearby_player.call("has_level_exit_key"))

	var key_value: Variant = nearby_player.get("has_exit_key")
	if key_value == null:
		return false

	return bool(key_value)


func consume_player_exit_key() -> bool:
	if nearby_player == null:
		return false
	if nearby_player.has_method("consume_exit_key"):
		return bool(nearby_player.call("consume_exit_key"))

	return false


func take_damage(_amount: int) -> void:
	return


func should_smash_from_roll() -> bool:
	return false


func smash_door() -> void:
	return
