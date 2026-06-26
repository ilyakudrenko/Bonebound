extends Node
class_name RunStats

var is_running: bool = false
var level_runtime: float = 0.0
var total_kills: int = 0
var secrets: int = 0
var player_died: bool = false
var level_completed: bool = false


func _ready() -> void:
	add_to_group("run_stats")
	start_run()


func _process(delta: float) -> void:
	if is_running:
		level_runtime += delta


func start_run() -> void:
	is_running = true
	level_runtime = 0.0
	total_kills = 0
	secrets = 0
	player_died = false
	level_completed = false


func register_kill(amount: int = 1) -> void:
	if amount <= 0 or not is_running:
		return

	total_kills += amount


func register_secret(amount: int = 1) -> void:
	if amount <= 0 or not is_running:
		return

	secrets += amount


func finish_run(did_complete_level: bool) -> void:
	if not is_running:
		return

	is_running = false
	level_completed = did_complete_level
	player_died = not did_complete_level


func get_formatted_runtime() -> String:
	var total_seconds: int = int(floor(level_runtime))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	var hundredths: int = int(floor((level_runtime - float(total_seconds)) * 100.0))

	return "%02d:%02d.%02d" % [minutes, seconds, hundredths]
