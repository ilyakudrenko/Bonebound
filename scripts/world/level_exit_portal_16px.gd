extends Area2D

@export var prompt_text: String = "Leave"
@export var completion_message: String = "Level complete"
@export_file("*.tscn") var next_scene_path: String = "res://scenes/levels/level_graveyard/Graveyard_Boss.tscn"
@export var player_enter_duration: float = 0.7
@export var exit_walk_offset: Vector2 = Vector2(72, 0)
@export var camera_stop_marker_path: NodePath = NodePath("CameraStopMarker")
@export var camera_stop_offset_x: float = -178.0
@export_group("Portal Glow")
@export_range(0.0, 1.0, 0.01) var back_glow_min_alpha: float = 0.16
@export_range(0.0, 1.0, 0.01) var back_glow_max_alpha: float = 0.3
@export_range(0.0, 1.0, 0.01) var mid_glow_min_alpha: float = 0.26
@export_range(0.0, 1.0, 0.01) var mid_glow_max_alpha: float = 0.46
@export_range(0.0, 1.0, 0.01) var core_glow_min_alpha: float = 0.58
@export_range(0.0, 1.0, 0.01) var core_glow_max_alpha: float = 0.86
@export_range(0.0, 12.0, 0.1) var glow_pulse_speed: float = 5.0

@onready var prompt: Node2D = $Prompt
@onready var prompt_label: Label = $Prompt/PromptLabel
@onready var camera_stop_marker: Node2D = get_node_or_null(camera_stop_marker_path) as Node2D
@onready var light_haze_back: CanvasItem = get_node_or_null("Visual/LightHazeBack") as CanvasItem
@onready var light_haze_mid: CanvasItem = get_node_or_null("Visual/LightHazeMid") as CanvasItem
@onready var light_haze_core: CanvasItem = get_node_or_null("Visual/LightHazeCore") as CanvasItem

var nearby_player: Node2D = null
var gameplay_camera: Camera2D = null
var is_exiting: bool = false
var pulse_time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.text = prompt_text
	prompt.hide()
	find_gameplay_camera()
	apply_camera_end_limit()


func _process(delta: float) -> void:
	pulse_portal(delta)


func pulse_portal(delta: float) -> void:
	pulse_time += delta
	var pulse: float = (sin(pulse_time * glow_pulse_speed) + 1.0) * 0.5
	pulse_light_layer(light_haze_back, back_glow_min_alpha, back_glow_max_alpha, pulse)
	pulse_light_layer(light_haze_mid, mid_glow_min_alpha, mid_glow_max_alpha, pulse)
	pulse_light_layer(light_haze_core, core_glow_min_alpha, core_glow_max_alpha, pulse)


func pulse_light_layer(layer: CanvasItem, minimum_alpha: float, maximum_alpha: float, pulse: float) -> void:
	if layer == null:
		return

	layer.modulate.a = lerpf(minimum_alpha, maximum_alpha, pulse)


func start_exit() -> void:
	if is_exiting or nearby_player == null:
		return

	is_exiting = true
	prompt.hide()
	if nearby_player.has_method("show_feedback_message"):
		nearby_player.call("show_feedback_message", completion_message)

	if nearby_player is CharacterBody2D:
		(nearby_player as CharacterBody2D).velocity = Vector2.ZERO
	nearby_player.set_physics_process(false)
	set_camera_frozen(true)

	var tween: Tween = create_tween()
	tween.tween_property(nearby_player, "global_position", global_position + exit_walk_offset, player_enter_duration)
	tween.parallel().tween_property(nearby_player, "modulate:a", 0.0, player_enter_duration)
	await tween.finished

	show_level_complete_summary()


func show_level_complete_summary() -> void:
	var summary_ui: Node = get_tree().get_first_node_in_group("run_summary_ui")
	if summary_ui != null and summary_ui.has_method("show_level_complete_summary"):
		summary_ui.call("show_level_complete_summary", next_scene_path)


func find_gameplay_camera() -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return

	gameplay_camera = current_scene.find_child("GameplayCamera", true, false) as Camera2D


func apply_camera_end_limit() -> void:
	if gameplay_camera == null:
		find_gameplay_camera()
	if gameplay_camera == null:
		return

	var right_limit: float = get_camera_stop_x()
	if gameplay_camera.has_method("set_right_position_limit"):
		gameplay_camera.call("set_right_position_limit", right_limit)
	else:
		gameplay_camera.limit_right = int(right_limit)


func get_camera_stop_x() -> float:
	if camera_stop_marker != null:
		return camera_stop_marker.global_position.x

	return global_position.x + camera_stop_offset_x


func set_camera_frozen(is_frozen: bool) -> void:
	if gameplay_camera == null:
		find_gameplay_camera()
	if gameplay_camera == null:
		return

	gameplay_camera.set_process(not is_frozen)


func _on_body_entered(body: Node2D) -> void:
	if not is_player(body):
		return

	nearby_player = body
	start_exit()


func _on_body_exited(body: Node2D) -> void:
	if body != nearby_player or is_exiting:
		return

	nearby_player = null
	prompt.hide()


func is_player(body: Node) -> bool:
	return body.has_method("die") and body.has_method("get_level_enemy_kills")
