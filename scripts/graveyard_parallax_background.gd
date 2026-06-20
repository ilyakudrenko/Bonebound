extends Node2D

const TEXTURE_SIZE := Vector2(320, 180)
const TILE_PADDING := 3
const BACKGROUND_SCALE := 2.0

const LAYERS := [
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Sky.png"),
		"follow": 1.0,
		"z": 0,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Moon.png"),
		"follow": 0.96,
		"z": 1,
		"repeat": false,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Cloud 3.png"),
		"follow": 0.9,
		"z": 2,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Cloud 2.png"),
		"follow": 0.84,
		"z": 3,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Cloud 1.png"),
		"follow": 0.78,
		"z": 4,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Background/Background.png"),
		"follow": 0.72,
		"z": 5,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Mountain/Mountain 2.png"),
		"follow": 0.62,
		"z": 6,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Mountain/Mountain 1.png"),
		"follow": 0.52,
		"z": 7,
		"repeat": true,
	},
	{
		"texture": preload("res://assets/Graveyard [16x16]/Parallax Background/Mountain/Mountain.png"),
		"follow": 0.42,
		"z": 8,
		"repeat": true,
	},
]

@export var camera_path: NodePath = NodePath("../GameplayCamera")

var camera: Camera2D
var layer_nodes: Array[Node2D] = []


func _ready() -> void:
	z_index = -1000
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	camera = get_node_or_null(camera_path) as Camera2D
	create_layers()
	update_layers()


func _process(_delta: float) -> void:
	update_layers()


func create_layers() -> void:
	for layer_data in LAYERS:
		var layer := Node2D.new()
		layer.z_index = layer_data["z"]
		layer.set_meta("follow", layer_data["follow"])
		layer.set_meta("repeat", layer_data["repeat"])
		add_child(layer)
		layer_nodes.append(layer)

		for tile_index in range(get_tile_count(layer_data["repeat"])):
			var sprite := Sprite2D.new()
			sprite.texture = layer_data["texture"]
			sprite.centered = true
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.scale = Vector2.ONE * BACKGROUND_SCALE
			layer.add_child(sprite)


func update_layers() -> void:
	if camera == null:
		return

	for layer in layer_nodes:
		var follow := float(layer.get_meta("follow"))
		layer.global_position = Vector2(camera.global_position.x * follow, camera.global_position.y)
		update_layer_tiles(layer)


func update_layer_tiles(layer: Node2D) -> void:
	var scaled_texture_width := TEXTURE_SIZE.x * BACKGROUND_SCALE
	var center_x := camera.global_position.x - layer.global_position.x
	var first_tile_index := floori(center_x / scaled_texture_width) - TILE_PADDING
	var tile_index := first_tile_index
	var should_repeat := bool(layer.get_meta("repeat"))

	for child in layer.get_children():
		if child is Sprite2D:
			if should_repeat:
				child.position = Vector2((tile_index * scaled_texture_width) + (scaled_texture_width * 0.5), 0)
			else:
				child.position = Vector2(center_x, 0)
			tile_index += 1


func get_tile_count(should_repeat: bool) -> int:
	if not should_repeat:
		return 1

	return (TILE_PADDING * 2) + 3
