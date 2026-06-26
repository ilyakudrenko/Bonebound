extends Area2D

@export var secret_value: int = 1
@export var discovery_message: String = "Secret found"

var was_discovered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if was_discovered:
		return
	if not is_player(body):
		return

	var run_stats: RunStats = get_tree().get_first_node_in_group("run_stats") as RunStats
	if run_stats == null:
		push_warning("Secret discovered, but no RunStats node was found.")
		return

	was_discovered = true
	run_stats.register_secret(secret_value)
	if body.has_method("show_feedback_message"):
		body.call("show_feedback_message", discovery_message)
	set_deferred("monitoring", false)
	call_deferred("queue_free")


func is_player(body: Node) -> bool:
	return body.has_method("die") and body.has_method("get_level_enemy_kills")
