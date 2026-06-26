extends CanvasLayer

@export var show_delay: float = 1.75
@export var fade_duration: float = 0.35
@export var level_transition_read_time: float = 3.0

var run_stats: RunStats = null
var is_summary_visible: bool = false
var is_loading_next_scene: bool = false
var loading_time: float = 0.0

@onready var root: Control = $Root
@onready var death_panel: PanelContainer = $Root/Panel
@onready var title_label: Label = $Root/Panel/Content/Title
@onready var subtitle_label: Label = $Root/Panel/Content/Subtitle
@onready var runtime_value: Label = $Root/Panel/Content/Stats/RuntimeRow/RuntimeValue
@onready var kills_value: Label = $Root/Panel/Content/Stats/KillsRow/KillsValue
@onready var secrets_value: Label = $Root/Panel/Content/Stats/SecretsRow/SecretsValue
@onready var restart_button: Button = $Root/Panel/Content/RestartButton
@onready var loading_screen: Control = $Root/LoadingScreen
@onready var loading_title_label: Label = $Root/LoadingScreen/Content/Title
@onready var loading_subtitle_label: Label = $Root/LoadingScreen/Content/Subtitle
@onready var loading_runtime_value: Label = $Root/LoadingScreen/Content/Stats/RuntimeRow/RuntimeValue
@onready var loading_kills_value: Label = $Root/LoadingScreen/Content/Stats/KillsRow/KillsValue
@onready var loading_secrets_value: Label = $Root/LoadingScreen/Content/Stats/SecretsRow/SecretsValue
@onready var loading_label: Label = $Root/LoadingScreen/Content/LoadingLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("run_summary_ui")
	root.hide()
	root.modulate.a = 0.0
	restart_button.pressed.connect(restart_level)


func _process(_delta: float) -> void:
	if is_summary_visible and not is_loading_next_scene and Input.is_key_pressed(KEY_R):
		restart_level()

	if is_loading_next_scene:
		loading_time += _delta
		update_loading_label()


func setup(new_run_stats: RunStats) -> void:
	run_stats = new_run_stats


func show_death_summary() -> void:
	show_run_summary(false)


func show_level_complete_summary(next_scene_path: String = "") -> void:
	show_run_summary(true, next_scene_path)


func show_run_summary(did_complete_level: bool, next_scene_path: String = "") -> void:
	if run_stats == null:
		return
	if is_summary_visible:
		return

	run_stats.finish_run(did_complete_level)
	await get_tree().create_timer(show_delay).timeout

	update_summary_title(did_complete_level)
	update_stats_text()
	update_summary_actions(did_complete_level)
	root.show()
	is_summary_visible = true

	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 1.0, fade_duration)
	await tween.finished

	if did_complete_level:
		await transition_to_next_scene(next_scene_path)
	else:
		get_tree().paused = true
		restart_button.grab_focus()


func update_stats_text() -> void:
	runtime_value.text = run_stats.get_formatted_runtime()
	kills_value.text = str(run_stats.total_kills)
	secrets_value.text = str(run_stats.secrets)
	loading_runtime_value.text = run_stats.get_formatted_runtime()
	loading_kills_value.text = str(run_stats.total_kills)
	loading_secrets_value.text = str(run_stats.secrets)


func update_summary_title(did_complete_level: bool) -> void:
	if did_complete_level:
		title_label.text = "GRAVEYARD CLEARED"
		title_label.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0, 1.0))
		subtitle_label.text = "Run summary"
		loading_title_label.text = "GRAVEYARD CLEARED"
		loading_subtitle_label.text = "Run summary"
	else:
		title_label.text = "YOU DIED"
		title_label.add_theme_color_override("font_color", Color(0.95, 0.2, 0.16, 1.0))
		subtitle_label.text = "Run summary"
		restart_button.text = "Restart  (R)"


func update_summary_actions(did_complete_level: bool) -> void:
	if did_complete_level:
		death_panel.hide()
		loading_screen.show()
		restart_button.hide()
		loading_label.show()
		loading_time = 0.0
		update_loading_label()
	else:
		is_loading_next_scene = false
		death_panel.show()
		loading_screen.hide()
		loading_label.hide()
		restart_button.show()


func update_loading_label() -> void:
	var dot_count := (floori(loading_time * 2.0) % 3) + 1
	var dots := "."
	match dot_count:
		2:
			dots = ".."
		3:
			dots = "..."

	loading_label.text = "Loading boss arena%s" % dots


func transition_to_next_scene(next_scene_path: String) -> void:
	is_loading_next_scene = true
	await get_tree().create_timer(level_transition_read_time).timeout
	get_tree().paused = false

	if next_scene_path == "":
		push_warning("No next scene configured for level complete summary.")
		return

	var error := get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		push_warning("Could not load next scene: %s" % next_scene_path)


func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
