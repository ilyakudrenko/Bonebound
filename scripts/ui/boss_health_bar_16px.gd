extends CanvasLayer

const HEALTH_BAR_INSET := 3.0

@onready var root: Control = $Root
@onready var boss_name_label: Label = $Root/BossNameLabel
@onready var health_back: ColorRect = $Root/HealthBack
@onready var health_bar: ColorRect = $Root/HealthBack/HealthBar

var tracked_boss: Node = null


func _ready() -> void:
	hide_bar()


func setup(boss: Node) -> void:
	tracked_boss = boss
	if tracked_boss == null:
		hide_bar()
		return

	if tracked_boss.has_method("get_boss_display_name"):
		boss_name_label.text = str(tracked_boss.call("get_boss_display_name"))

	if not tracked_boss.is_connected("health_changed", Callable(self, "_on_boss_health_changed")):
		tracked_boss.connect("health_changed", Callable(self, "_on_boss_health_changed"))
	if not tracked_boss.is_connected("defeated", Callable(self, "_on_boss_defeated")):
		tracked_boss.connect("defeated", Callable(self, "_on_boss_defeated"))

	show_bar()
	if tracked_boss.has_method("get_health"):
		_on_boss_health_changed(int(tracked_boss.call("get_health")), int(tracked_boss.call("get_max_health")))


func show_bar() -> void:
	root.show()


func hide_bar() -> void:
	root.hide()


func _on_boss_health_changed(current_health: int, max_health: int) -> void:
	var health_ratio := 0.0
	if max_health > 0:
		health_ratio = clampf(float(current_health) / float(max_health), 0.0, 1.0)

	var max_bar_width := maxf(health_back.size.x - (HEALTH_BAR_INSET * 2.0), 0.0)
	health_bar.size.x = max_bar_width * health_ratio


func _on_boss_defeated() -> void:
	hide_bar()
