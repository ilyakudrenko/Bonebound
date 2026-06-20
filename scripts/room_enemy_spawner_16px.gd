extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/scaled_objects/DummyEnemy_16px.tscn")
@export var spawn_enemies_on_ready := true


func _ready() -> void:
	if spawn_enemies_on_ready:
		spawn_enemies()


func spawn_enemies() -> void:
	var spawn_points := get_node_or_null("Markers/EnemySpawnPoints")
	if spawn_points == null:
		return

	var enemies_parent := get_or_create_enemies_parent()

	for child in spawn_points.get_children():
		if child is Marker2D:
			spawn_enemy_at(child.global_position, enemies_parent)


func spawn_enemy_at(spawn_position: Vector2, enemies_parent: Node) -> void:
	if enemy_scene == null:
		return

	var enemy := enemy_scene.instantiate()
	enemies_parent.add_child(enemy)
	enemy.global_position = spawn_position


func get_or_create_enemies_parent() -> Node:
	var enemies_parent := get_node_or_null("Enemies")
	if enemies_parent != null:
		return enemies_parent

	enemies_parent = Node.new()
	enemies_parent.name = "Enemies"
	add_child(enemies_parent)
	return enemies_parent
