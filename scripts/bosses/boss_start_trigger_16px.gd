extends Area2D

@export var boss_path: NodePath = NodePath("../Gravekeeper")

var has_started_fight := false
var boss: Node = null


func _ready() -> void:
	boss = get_node_or_null(boss_path)
	body_entered.connect(_on_body_entered)


func _physics_process(_delta: float) -> void:
	if has_started_fight:
		return

	for body in get_overlapping_bodies():
		_on_body_entered(body)
		if has_started_fight:
			return


func _on_body_entered(body: Node) -> void:
	if has_started_fight:
		return
	if body == null or body.name != "Player":
		return

	has_started_fight = true
	if boss != null and boss.has_method("start_fight"):
		boss.call("start_fight")
