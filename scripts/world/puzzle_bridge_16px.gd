extends StaticBody2D

@export var starts_active := false

var is_active := false

@onready var visual: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	set_active(starts_active)


func activate() -> void:
	set_active(true)


func deactivate() -> void:
	set_active(false)


func set_active(active: bool) -> void:
	is_active = active
	visual.visible = is_active
	collision_shape.set_deferred("disabled", not is_active)
