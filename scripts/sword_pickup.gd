extends Area2D

const AXE_PICKUP_SCENE_PATH := "res://scenes/AxePickup.tscn"

var nearby_player: Node = null
var was_interact_pressed := false

@onready var prompt: Node2D = get_node_or_null("Prompt")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	var is_interact_pressed := Input.is_key_pressed(KEY_E)

	if nearby_player != null and is_interact_pressed and not was_interact_pressed:
		swap_weapon_with_player()

	was_interact_pressed = is_interact_pressed


func _on_body_entered(body: Node) -> void:
	if not body.has_method("exchange_main_weapon"):
		return

	if body.has_method("has_main_weapon") and body.call("has_main_weapon"):
		nearby_player = body
		show_prompt()
		return

	var old_weapon_type: String = body.call("exchange_main_weapon", "sword")
	if old_weapon_type != "blocked":
		queue_free()


func _on_body_exited(body: Node) -> void:
	if body == nearby_player:
		nearby_player = null
		hide_prompt()


func swap_weapon_with_player() -> void:
	if nearby_player == null:
		return

	var old_weapon_type: String = nearby_player.call("exchange_main_weapon", "sword")
	if old_weapon_type == "blocked":
		return
	if old_weapon_type == "sword":
		return

	if old_weapon_type == "axe":
		spawn_old_weapon(AXE_PICKUP_SCENE_PATH)

	queue_free()


func spawn_old_weapon(scene_path: String) -> void:
	var old_weapon_scene := load(scene_path) as PackedScene
	var old_weapon := old_weapon_scene.instantiate()

	get_tree().current_scene.add_child(old_weapon)
	old_weapon.global_position = global_position


func show_prompt() -> void:
	if prompt != null:
		prompt.show()


func hide_prompt() -> void:
	if prompt != null:
		prompt.hide()
