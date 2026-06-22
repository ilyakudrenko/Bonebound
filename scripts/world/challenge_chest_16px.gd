extends Area2D

const STATE_READY := "ready"
const STATE_ACTIVE := "active"
const STATE_COMPLETE := "complete"
const STATE_FAILED := "failed"
const STATE_OPENED := "opened"

const LEGENDARY_REWARD_RARITY := ItemDatabase.RARITY_LEGENDARY

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var challenge_id := ""
@export var loot_pool: Array[String] = []
@export var pickup_spawn_offset := Vector2(42, -8)

@onready var visual: Sprite2D = $Visual
@onready var prompt: Node2D = $Prompt
@onready var challenge_panel: Node2D = $ChallengePanel
@onready var title_label: Label = $ChallengePanel/TitleLabel
@onready var description_label: Label = $ChallengePanel/DescriptionLabel
@onready var progress_label: Label = $ChallengePanel/ProgressLabel
@onready var action_label: Label = $ChallengePanel/ActionLabel

var nearby_player: Node = null
var was_interact_pressed := false
var state := STATE_READY
var progress := 0
var required_progress := 1
var selected_item := ""


func _ready() -> void:
	add_to_group("challenge_chests")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if challenge_id == "":
		challenge_id = get_random_challenge_id()
	if loot_pool.is_empty():
		for item_id in ItemDatabase.get_chest_loot_pool():
			loot_pool.append(String(item_id))

	var challenge_data: Dictionary = get_challenge_data()
	required_progress = int(challenge_data.get("required_progress", 1))
	visual.texture = closed_texture
	prompt.hide()
	challenge_panel.hide()


func _process(_delta: float) -> void:
	var is_interact_pressed: bool = Input.is_key_pressed(KEY_E)

	if nearby_player != null and is_interact_pressed and not was_interact_pressed:
		handle_interaction()

	was_interact_pressed = is_interact_pressed


func handle_interaction() -> void:
	if state == STATE_OPENED:
		return

	if state == STATE_COMPLETE:
		open_chest()
		return

	if state == STATE_ACTIVE:
		update_challenge_panel()
		challenge_panel.show()
		return

	if has_other_active_challenge():
		show_blocked_panel()
		return

	start_challenge()


func start_challenge() -> void:
	progress = 0

	if challenge_id == ChallengeDatabase.CHALLENGE_SACRIFICE_LEFT_ARM:
		try_complete_left_arm_sacrifice()
		return

	state = STATE_ACTIVE
	update_challenge_panel()
	challenge_panel.show()


func try_complete_left_arm_sacrifice() -> void:
	if nearby_player == null or not nearby_player.has_method("sacrifice_left_arm_for_challenge"):
		state = STATE_FAILED
		update_challenge_panel("Player cannot sacrifice left arm.")
		challenge_panel.show()
		return

	var sacrifice_succeeded: bool = bool(nearby_player.call("sacrifice_left_arm_for_challenge"))
	if not sacrifice_succeeded:
		state = STATE_FAILED
		update_challenge_panel("You need a left arm for this offering.")
		challenge_panel.show()
		return

	progress = required_progress
	state = STATE_COMPLETE
	open_chest()


func open_chest() -> void:
	state = STATE_OPENED
	prompt.hide()
	challenge_panel.hide()
	visual.texture = open_texture

	selected_item = pick_random_item()
	spawn_reward_pickup()


func notify_enemy_killed_by_player(player: Node) -> void:
	if player == null:
		return
	if state != STATE_ACTIVE:
		return
	if challenge_id != ChallengeDatabase.CHALLENGE_KILL_TWO_NO_DAMAGE:
		return

	progress += 1
	if progress >= required_progress:
		complete_challenge()
	else:
		update_challenge_panel()


func notify_enemy_killed_by_body_part(player: Node) -> void:
	if player == null:
		return
	if state != STATE_ACTIVE:
		return
	if challenge_id != ChallengeDatabase.CHALLENGE_BODY_PART_KILL:
		return

	progress += 1
	complete_challenge()


func notify_player_took_damage(player: Node) -> void:
	if player == null:
		return
	if state != STATE_ACTIVE:
		return
	if challenge_id != ChallengeDatabase.CHALLENGE_KILL_TWO_NO_DAMAGE:
		return

	state = STATE_FAILED
	progress = 0
	update_challenge_panel("Challenge failed. Press E to retry.")


func complete_challenge() -> void:
	state = STATE_COMPLETE
	progress = required_progress
	update_challenge_panel("Complete! Return and press E for reward.")
	challenge_panel.show()


func has_active_challenge() -> bool:
	return state == STATE_ACTIVE


func has_other_active_challenge() -> bool:
	for challenge_chest in get_tree().get_nodes_in_group("challenge_chests"):
		if challenge_chest == self:
			continue
		if challenge_chest.has_method("has_active_challenge") and bool(challenge_chest.call("has_active_challenge")):
			return true

	return false


func show_blocked_panel() -> void:
	var challenge_data: Dictionary = get_challenge_data()
	title_label.text = String(challenge_data.get("title", "Challenge Chest"))
	description_label.text = "Another challenge is already active."
	progress_label.text = ""
	action_label.text = "Finish or fail the current challenge first."
	challenge_panel.show()


func update_challenge_panel(status_text: String = "") -> void:
	var challenge_data: Dictionary = get_challenge_data()
	title_label.text = String(challenge_data.get("title", "Challenge Chest"))
	description_label.text = String(challenge_data.get("description", "Complete the challenge."))

	if status_text != "":
		progress_label.text = status_text
	elif state == STATE_ACTIVE:
		progress_label.text = "Progress: " + str(progress) + "/" + str(required_progress)
	elif state == STATE_FAILED:
		progress_label.text = "Challenge failed. Press E to retry."
	elif state == STATE_COMPLETE:
		progress_label.text = "Complete! Press E to claim reward."
	else:
		progress_label.text = "Reward: random Legendary item."

	if state == STATE_READY or state == STATE_FAILED:
		action_label.text = "Press E to start."
	elif state == STATE_ACTIVE:
		action_label.text = "Challenge active."
	elif state == STATE_COMPLETE:
		action_label.text = "Press E to open."
	else:
		action_label.text = ""


func pick_random_item() -> String:
	if loot_pool.is_empty():
		return ItemDatabase.WEAPON_SWORD

	return String(loot_pool.pick_random())


func spawn_reward_pickup() -> void:
	var scene_path: String = ItemDatabase.get_item_pickup_scene_path(selected_item)
	if scene_path == "":
		return

	var reward_scene: PackedScene = load(scene_path) as PackedScene
	if reward_scene == null:
		return

	var reward_node: Node2D = reward_scene.instantiate() as Node2D
	if reward_node == null:
		return

	if has_property(reward_node, "auto_pickup_if_empty"):
		reward_node.set("auto_pickup_if_empty", false)
	if has_property(reward_node, "item_rarity"):
		reward_node.set("item_rarity", LEGENDARY_REWARD_RARITY)

	get_tree().current_scene.add_child(reward_node)
	reward_node.global_position = global_position + pickup_spawn_offset


func get_random_challenge_id() -> String:
	var challenge_ids: Array[String] = ChallengeDatabase.get_challenge_ids()
	return String(challenge_ids.pick_random())


func get_challenge_data() -> Dictionary:
	return ChallengeDatabase.get_challenge_data(challenge_id)


func has_property(node: Node, property_name: String) -> bool:
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true

	return false


func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return

	nearby_player = body
	if state != STATE_OPENED:
		prompt.show()
		update_challenge_panel()


func _on_body_exited(body: Node) -> void:
	if body != nearby_player:
		return

	nearby_player = null
	prompt.hide()
	challenge_panel.hide()
