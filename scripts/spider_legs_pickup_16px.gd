extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.has_method("obtain_spider_legs"):
		body.call("obtain_spider_legs")
		queue_free()
