extends RigidBody2D

signal activated

@export var bridge_path: NodePath
@export var activate_once := true
@export var arm_hit_impulse := 55.0

var is_active := false

@onready var idle_light: ColorRect = $Visual/IdleLight
@onready var active_light: ColorRect = $Visual/ActiveLight
@onready var hit_area: Area2D = $HitArea


func _ready() -> void:
	hit_area.area_entered.connect(_on_hit_area_entered)
	update_visual()


func _on_hit_area_entered(area: Area2D) -> void:
	if not is_arm_body_part(area):
		return

	apply_arm_impact(area)
	stick_arm_to_button(area)

	if is_active and activate_once:
		return

	activate()


func activate() -> void:
	is_active = true
	update_visual()

	var bridge := get_node_or_null(bridge_path)
	if bridge != null and bridge.has_method("activate"):
		bridge.call("activate")

	activated.emit()


func apply_arm_impact(area: Area2D) -> void:
	var impact_direction := (global_position - area.global_position).normalized()
	if impact_direction == Vector2.ZERO:
		impact_direction = Vector2.RIGHT

	apply_impulse(impact_direction * arm_hit_impulse)


func stick_arm_to_button(area: Area2D) -> void:
	if area.has_method("stick_to_node"):
		area.call("stick_to_node", self)


func is_arm_body_part(area: Area2D) -> bool:
	if not area.has_meta("body_part_type"):
		return false

	var body_part_type := String(area.get_meta("body_part_type"))
	return body_part_type.ends_with("_arm")


func update_visual() -> void:
	idle_light.visible = not is_active
	active_light.visible = is_active
