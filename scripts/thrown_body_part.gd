extends Area2D

const THROW_HORIZONTAL_SPEED := 520.0
const THROW_UPWARD_SPEED := 180.0
const THROW_GRAVITY := 700.0
const LIFETIME := 1.5
const FALL_GRAVITY := 900.0
const MAX_FALL_SPEED := 600.0
const PICKUP_DELAY := 0.35
const THROWN_ARM_STUN_DURATION := 1.1
const FLYING_STATE := "flying"
const DROPPED_STATE := "dropped"

var direction := Vector2.RIGHT
var flight_velocity := Vector2.ZERO
var damage := 1
var lifetime_left := LIFETIME
var part_color := Color(1, 0.05, 0.05, 1)
var body_part_type := ""
var body_part_id := ""
var carried_item_type := ""
var state := FLYING_STATE
var fall_speed := 0.0
var is_on_ground := false
var pickup_delay_left := 0.0

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	set_meta("body_part_type", body_part_type)
	set_meta("body_part_id", body_part_id)
	set_meta("carried_item_type", carried_item_type)
	if state == DROPPED_STATE:
		visual.color = part_color.darkened(0.25)
	else:
		visual.color = part_color
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if pickup_delay_left > 0.0:
		pickup_delay_left -= delta

	if state == FLYING_STATE:
		flight_velocity.y += THROW_GRAVITY * delta
		global_position += flight_velocity * delta
		rotation = flight_velocity.angle()
		lifetime_left -= delta

		if lifetime_left <= 0.0:
			drop_body_part()
	elif state == DROPPED_STATE and not is_on_ground:
		fall_speed = minf(fall_speed + FALL_GRAVITY * delta, MAX_FALL_SPEED)
		global_position.y += fall_speed * delta


func setup(new_direction: Vector2, new_color: Color, new_damage: int, new_body_part_type: String, new_carried_item_type: String = "", new_body_part_id: String = "") -> void:
	direction = new_direction.normalized()
	flight_velocity = Vector2(direction.x * THROW_HORIZONTAL_SPEED, -THROW_UPWARD_SPEED)
	part_color = new_color
	damage = new_damage
	body_part_type = new_body_part_type
	carried_item_type = new_carried_item_type
	body_part_id = new_body_part_id


func setup_dropped(new_color: Color, new_body_part_type: String, new_carried_item_type: String = "", new_body_part_id: String = "") -> void:
	part_color = new_color
	body_part_type = new_body_part_type
	carried_item_type = new_carried_item_type
	body_part_id = new_body_part_id
	damage = 0
	drop_body_part()


func _on_body_entered(body: Node) -> void:
	handle_collision(body)


func _on_area_entered(area: Area2D) -> void:
	handle_collision(area)


func handle_collision(other: Node) -> void:
	if state == FLYING_STATE:
		if other.has_method("recover_body_part"):
			return

		if other.has_method("take_damage"):
			other.call("take_damage", damage)
		if other.has_method("stun_for_duration"):
			other.call("stun_for_duration", THROWN_ARM_STUN_DURATION)
		elif other.has_method("stun"):
			other.call("stun")

		drop_body_part()
		if other is StaticBody2D and not other.has_method("take_damage"):
			land_body_part()
	elif state == DROPPED_STATE:
		if pickup_delay_left <= 0.0 and other.has_method("recover_body_part") and other.call("recover_body_part", body_part_type, carried_item_type, body_part_id, part_color):
			queue_free()
		elif other is StaticBody2D:
			land_body_part()


func drop_body_part() -> void:
	if state == DROPPED_STATE:
		return

	state = DROPPED_STATE
	fall_speed = 0.0
	is_on_ground = false
	pickup_delay_left = PICKUP_DELAY
	rotation = 0.0

	if visual != null:
		visual.color = part_color.darkened(0.25)


func land_body_part() -> void:
	fall_speed = 0.0
	is_on_ground = true
