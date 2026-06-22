extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.has_method("obtain_harpoon_arms"):
		body.call("obtain_harpoon_arms")
		queue_free()
