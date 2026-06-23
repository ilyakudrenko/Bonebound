extends Node2D

@export var anchor_path: NodePath
@export var button_path: NodePath
@export var rope_line_path: NodePath

@onready var anchor := get_node(anchor_path) as Node2D
@onready var button := get_node(button_path) as Node2D
@onready var rope_line := get_node(rope_line_path) as Line2D


func _process(_delta: float) -> void:
	rope_line.points = PackedVector2Array([
		to_local(anchor.global_position),
		to_local(button.global_position)
	])
