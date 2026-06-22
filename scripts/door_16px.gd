extends StaticBody2D

const OPEN_VISUAL_OFFSET := 28.0
const ROLL_SMASH_DISTANCE := Vector2(28, 60)
const THROWN_BODY_PART_SCENE := preload("res://scenes/scaled/body_parts/ThrownBodyPart_16px.tscn")

var is_open := false
var is_smashed := false
var player_is_nearby := false
var was_interact_pressed := false
var nearby_player: Node = null

@onready var closed_visual: Node2D = $ClosedVisual
@onready var open_visual: Node2D = $OpenVisual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var prompt: Node2D = $Prompt
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	open_visual.z_index = -10
	prompt.hide()
	closed_visual.show()
	open_visual.hide()
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)


func _process(_delta: float) -> void:
	if is_smashed:
		return

	if should_smash_from_roll():
		smash_door()
		return

	var is_interact_pressed := Input.is_key_pressed(KEY_E)

	if player_is_nearby and is_interact_pressed and not was_interact_pressed:
		toggle_door()

	was_interact_pressed = is_interact_pressed


func toggle_door() -> void:
	if is_smashed:
		return

	if is_open:
		close_door()
	else:
		open_door()


func open_door() -> void:
	is_open = true
	update_open_visual_side()
	closed_visual.hide()
	open_visual.show()
	collision_shape.disabled = true
	update_prompt_visibility()


func close_door() -> void:
	if is_doorway_blocked():
		if nearby_player != null and nearby_player.has_method("show_feedback_message"):
			nearby_player.call("show_feedback_message", "Doorway blocked")
		return

	is_open = false
	open_visual.hide()
	closed_visual.show()
	collision_shape.disabled = false
	update_prompt_visibility()


func update_prompt_visibility() -> void:
	if player_is_nearby and not is_smashed:
		prompt.show()
	else:
		prompt.hide()


func take_damage(_amount: int) -> void:
	smash_door()


func blocks_enemy_movement() -> bool:
	return not is_open and not is_smashed


func should_smash_from_roll() -> bool:
	if is_open or is_smashed or nearby_player == null:
		return false
	if not nearby_player.has_method("is_door_smashing_roll"):
		return false
	if not nearby_player.call("is_door_smashing_roll"):
		return false

	var distance_to_door: Vector2 = nearby_player.global_position - collision_shape.global_position
	return absf(distance_to_door.x) <= ROLL_SMASH_DISTANCE.x and absf(distance_to_door.y) <= ROLL_SMASH_DISTANCE.y


func smash_door() -> void:
	if is_smashed:
		return

	is_smashed = true
	is_open = true
	prompt.hide()
	closed_visual.hide()
	open_visual.hide()
	collision_shape.set_deferred("disabled", true)
	interaction_area.set_deferred("monitoring", false)
	call_deferred("spawn_shatter_pieces")


func spawn_shatter_pieces() -> void:
	spawn_shatter_piece(Vector2(-14, -54), Vector2(14, 5), Color(0.78, 0.2, 0.08, 1), Vector2(-90, -90))
	spawn_shatter_piece(Vector2(0, -44), Vector2(12, 5), Color(0.15, 0.09, 0.06, 1), Vector2(70, -80))
	spawn_shatter_piece(Vector2(13, -32), Vector2(18, 4), Color(0.18, 0.1, 0.06, 1), Vector2(110, -65))
	spawn_shatter_piece(Vector2(-9, -24), Vector2(9, 24), Color(0.42, 0.29, 0.19, 1), Vector2(-70, -45))
	spawn_shatter_piece(Vector2(5, -22), Vector2(8, 26), Color(0.29, 0.19, 0.13, 1), Vector2(50, -40))
	spawn_shatter_piece(Vector2(13, -10), Vector2(14, 4), Color(0.15, 0.09, 0.06, 1), Vector2(95, -35))
	spawn_shatter_piece(Vector2(-9, -3), Vector2(15, 5), Color(0.65, 0.18, 0.08, 1), Vector2(-55, -25))


func spawn_shatter_piece(local_offset: Vector2, piece_size: Vector2, piece_color: Color, launch_velocity: Vector2) -> void:
	var piece := THROWN_BODY_PART_SCENE.instantiate()

	get_tree().current_scene.add_child(piece)
	piece.global_position = global_position + local_offset
	piece.setup_death_piece(piece_color, piece_size, launch_velocity)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_is_nearby = true
		nearby_player = body
		update_prompt_visibility()
		if should_smash_from_roll():
			smash_door()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_is_nearby = false
		nearby_player = null
		update_prompt_visibility()


func is_doorway_blocked() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = collision_shape.global_transform
	query.exclude = [get_rid()]
	query.collision_mask = collision_layer
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results := get_world_2d().direct_space_state.intersect_shape(query, 8)

	for result in results:
		var collider := result["collider"] as Node
		if collider != null and collider.name == "Player":
			return true

	return false


func update_open_visual_side() -> void:
	var open_direction := 1.0

	if nearby_player != null and nearby_player.global_position.x > global_position.x:
		open_direction = -1.0

	open_visual.position.x = OPEN_VISUAL_OFFSET * open_direction
	open_visual.scale.x = open_direction
