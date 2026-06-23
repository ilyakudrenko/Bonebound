extends Control

const DEFAULT_ITEM_ICON_TEXTURE := preload("res://assets/weapons_And_Shields/fantasy_weapons_pack1_noglow.png")

@onready var icon: TextureRect = $Card/VBox/Row/Icon
@onready var item_label: Label = $Card/VBox/Row/ItemLabel
@onready var rarity_label: Label = $Card/VBox/RarityLabel
@onready var description: Label = $Card/VBox/Description
@onready var action_label: Label = $PressBadge/Label


func setup_item(item_id: String, rarity: String = ItemDatabase.RARITY_COMMON, show_rarity: bool = true) -> void:
	var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
	var icon_region: Rect2 = item_data.get("icon_region", Rect2(0, 0, 32, 32)) as Rect2
	var icon_source: Texture2D = DEFAULT_ITEM_ICON_TEXTURE
	var icon_source_path := String(item_data.get("icon_texture", ""))
	if icon_source_path != "":
		var loaded_icon_source := load(icon_source_path) as Texture2D
		if loaded_icon_source != null:
			icon_source = loaded_icon_source

	var icon_texture := AtlasTexture.new()
	icon_texture.atlas = icon_source
	icon_texture.region = icon_region

	icon.texture = icon_texture
	item_label.text = str(item_data.get("label", "Unknown Item"))
	rarity_label.visible = show_rarity
	if show_rarity:
		rarity_label.text = ItemDatabase.get_rarity_label(rarity)
		rarity_label.add_theme_color_override("font_color", ItemDatabase.get_rarity_color(rarity))

	var base_description := str(item_data.get("description", "No description yet."))
	var rarity_description := ItemDatabase.get_item_rarity_description(item_id, rarity)
	if show_rarity and rarity_description != "":
		description.text = base_description + "\n" + rarity_description
	else:
		description.text = base_description


func set_can_pick_up(can_pick_up: bool) -> void:
	if can_pick_up:
		action_label.text = "Press E"
		return

	action_label.text = "Can't pick up"
