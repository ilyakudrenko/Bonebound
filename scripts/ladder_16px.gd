extends Node2D


func _on_climb_area_body_entered(body: Node2D) -> void:
	if body.has_method("enter_ladder_area"):
		body.call("enter_ladder_area")


func _on_climb_area_body_exited(body: Node2D) -> void:
	if body.has_method("exit_ladder_area"):
		body.call("exit_ladder_area")
