extends Node2D

const TEXTURE_SIZE := Vector2(320, 180)
const TILE_PADDING := 3
const BACKGROUND_SCALE := 2.0
const MOON_REGION := Rect2(124, 19, 48, 48)
const MOON_CENTER_OFFSET := Vector2(-12, -47)

const LAYERS := [
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Sky.png"),
		"follow": 1.0,
		"z": 0,
		"repeat": true,
		"offset": Vector2.ZERO,
		"rotation_degrees": 0.0,
		"drift_speed": 0.0,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Cloud 3.png"),
		"follow": 0.9,
		"z": 1,
		"repeat": true,
		"offset": Vector2(0, -94),
		"rotation_degrees": 180.0,
		"drift_speed": -3.0,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Moon.png"),
		"follow": 0.96,
		"z": 2,
		"repeat": false,
		"moon_glow": true,
		"offset": Vector2.ZERO,
		"rotation_degrees": 0.0,
		"drift_speed": 0.0,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Cloud 2.png"),
		"follow": 0.84,
		"z": 3,
		"repeat": true,
		"offset": Vector2(0, -94),
		"rotation_degrees": 180.0,
		"drift_speed": -2.2,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Cloud 1.png"),
		"follow": 0.78,
		"z": 4,
		"repeat": true,
		"offset": Vector2(0, -94),
		"rotation_degrees": 180.0,
		"drift_speed": -1.4,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Mountain/Mountain 2.png"),
		"follow": 0.62,
		"z": 5,
		"repeat": true,
		"offset": Vector2(0, -42),
		"rotation_degrees": 0.0,
		"drift_speed": 0.0,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Mountain/Mountain 1.png"),
		"follow": 0.52,
		"z": 6,
		"repeat": true,
		"offset": Vector2(0, -42),
		"rotation_degrees": 0.0,
		"drift_speed": 0.0,
	},
]

@export var camera_path: NodePath = NodePath("../GameplayCamera")
@export_group("Safety Fill")
@export var sky_fill_color: Color = Color(0.08, 0.32, 0.38, 1.0)
@export var sky_fill_size: Vector2 = Vector2(2200, 1400)
@export_group("Mountain Base Fill")
@export var mountain_base_fill_color: Color = Color.html("#242d39")
@export var mountain_base_fill_size: Vector2 = Vector2(2200, 900)
@export var mountain_base_fill_offset: Vector2 = Vector2(0, 76)
@export_group("Vertical Follow")
@export_range(0.0, 1.0, 0.01) var vertical_follow_strength: float = 1.0
@export_range(0.0, 20.0, 0.1) var vertical_follow_smoothing: float = 10.0
@export_group("Cloud Drift")
@export_range(0.0, 2.0, 0.01) var cloud_drift_multiplier: float = 1.0
@export_group("Moon Glow")
@export_range(0, 12, 1) var moon_glow_layer_count: int = 7
@export_range(0.0, 1.0, 0.01) var moon_glow_scale_step: float = 0.42
@export_range(0.0, 1.0, 0.01) var moon_glow_alpha: float = 0.16
@export var moon_glow_color: Color = Color(0.78, 0.92, 1.0, 1.0)
@export var moon_base_modulate: Color = Color(1.04, 1.08, 1.12, 1.0)

var camera: Camera2D
var sky_fill: ColorRect
var mountain_base_fill: ColorRect
var layer_nodes: Array[Node2D] = []
var base_camera_y: float = 0.0
var smoothed_background_y: float = 0.0
var is_initialized: bool = false
var cloud_drift_time: float = 0.0


func _ready() -> void:
	z_index = -1000
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	camera = get_node_or_null(camera_path) as Camera2D
	create_sky_fill()
	create_mountain_base_fill()
	create_layers()
	call_deferred("initialize_background_position")


func _process(delta: float) -> void:
	if not is_initialized:
		return

	cloud_drift_time += delta
	update_layers(delta)


func initialize_background_position() -> void:
	if camera == null:
		camera = get_node_or_null(camera_path) as Camera2D
	if camera == null:
		return

	base_camera_y = camera.global_position.y
	smoothed_background_y = base_camera_y
	is_initialized = true
	update_layers(0.0, true)


func create_sky_fill() -> void:
	sky_fill = ColorRect.new()
	sky_fill.name = "SafetySkyFill"
	sky_fill.z_index = -100
	sky_fill.color = sky_fill_color
	sky_fill.size = sky_fill_size
	add_child(sky_fill)


func create_mountain_base_fill() -> void:
	mountain_base_fill = ColorRect.new()
	mountain_base_fill.name = "MountainBaseFill"
	mountain_base_fill.z_index = 4
	mountain_base_fill.color = mountain_base_fill_color
	mountain_base_fill.size = mountain_base_fill_size
	add_child(mountain_base_fill)


func create_layers() -> void:
	for layer_data in LAYERS:
		var layer := Node2D.new()
		layer.z_index = layer_data["z"]
		layer.set_meta("follow", layer_data["follow"])
		layer.set_meta("repeat", layer_data["repeat"])
		layer.set_meta("offset", layer_data["offset"])
		layer.set_meta("drift_speed", layer_data["drift_speed"])
		add_child(layer)
		layer_nodes.append(layer)

		for tile_index in range(get_tile_count(layer_data["repeat"])):
			var sprite := Sprite2D.new()
			sprite.texture = layer_data["texture"]
			sprite.centered = true
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.scale = Vector2.ONE * BACKGROUND_SCALE
			sprite.rotation_degrees = float(layer_data["rotation_degrees"])
			layer.add_child(sprite)
			if bool(layer_data.get("moon_glow", false)):
				sprite.modulate = moon_base_modulate
				add_moon_glow(layer, sprite)


func add_moon_glow(layer: Node2D, moon_sprite: Sprite2D) -> void:
	for glow_index in range(moon_glow_layer_count):
		var glow_sprite := Sprite2D.new()
		var glow_strength := float(moon_glow_layer_count - glow_index) / float(moon_glow_layer_count)
		var glow_scale := BACKGROUND_SCALE * (1.0 + (float(glow_index + 1) * moon_glow_scale_step))

		glow_sprite.name = "MoonGlow%s" % (glow_index + 1)
		glow_sprite.texture = moon_sprite.texture
		glow_sprite.region_enabled = true
		glow_sprite.region_rect = MOON_REGION
		glow_sprite.centered = true
		glow_sprite.z_index = moon_sprite.z_index - 1
		glow_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		glow_sprite.scale = Vector2.ONE * glow_scale
		glow_sprite.set_meta("is_moon_glow", true)
		glow_sprite.modulate = Color(
			moon_glow_color.r,
			moon_glow_color.g,
			moon_glow_color.b,
			moon_glow_alpha * glow_strength
		)
		glow_sprite.material = create_local_additive_material()
		layer.add_child(glow_sprite)


func create_local_additive_material() -> CanvasItemMaterial:
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	return material


func update_layers(delta: float, snap_vertical: bool = false) -> void:
	if camera == null:
		return

	var target_background_y := base_camera_y + ((camera.global_position.y - base_camera_y) * vertical_follow_strength)
	if snap_vertical or vertical_follow_smoothing <= 0.0:
		smoothed_background_y = target_background_y
	else:
		var follow_amount := 1.0 - exp(-vertical_follow_smoothing * delta)
		smoothed_background_y = lerpf(smoothed_background_y, target_background_y, follow_amount)

	update_sky_fill()
	update_mountain_base_fill()

	for layer in layer_nodes:
		var follow := float(layer.get_meta("follow"))
		layer.global_position = Vector2(camera.global_position.x * follow, smoothed_background_y)
		update_layer_tiles(layer)


func update_sky_fill() -> void:
	if sky_fill == null:
		return

	sky_fill.color = sky_fill_color
	sky_fill.size = sky_fill_size
	sky_fill.global_position = camera.global_position - (sky_fill_size * 0.5)


func update_mountain_base_fill() -> void:
	if mountain_base_fill == null:
		return

	mountain_base_fill.color = mountain_base_fill_color
	mountain_base_fill.size = mountain_base_fill_size
	mountain_base_fill.global_position = camera.global_position + mountain_base_fill_offset - Vector2(mountain_base_fill_size.x * 0.5, 0)


func update_layer_tiles(layer: Node2D) -> void:
	var scaled_texture_width := TEXTURE_SIZE.x * BACKGROUND_SCALE
	var center_x := camera.global_position.x - layer.global_position.x
	var first_tile_index := floori(center_x / scaled_texture_width) - TILE_PADDING
	var tile_index := first_tile_index
	var should_repeat := bool(layer.get_meta("repeat"))
	var layer_offset := layer.get_meta("offset") as Vector2
	var drift_offset := fposmod(
		float(layer.get_meta("drift_speed")) * cloud_drift_multiplier * cloud_drift_time,
		scaled_texture_width
	)

	for child in layer.get_children():
		if child is Sprite2D:
			if bool(child.get_meta("is_moon_glow", false)):
				continue

			if should_repeat:
				child.position = Vector2((tile_index * scaled_texture_width) + (scaled_texture_width * 0.5) + drift_offset, 0) + layer_offset
			else:
				child.position = Vector2(center_x, 0) + layer_offset
				update_moon_glow_positions(layer, child.position)
			tile_index += 1


func update_moon_glow_positions(layer: Node2D, moon_position: Vector2) -> void:
	var glow_position := moon_position + (MOON_CENTER_OFFSET * BACKGROUND_SCALE)
	for child in layer.get_children():
		if child is Sprite2D and bool(child.get_meta("is_moon_glow", false)):
			child.position = glow_position


func get_tile_count(should_repeat: bool) -> int:
	if not should_repeat:
		return 1

	return (TILE_PADDING * 2) + 3
