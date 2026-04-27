extends Area2D

signal reach_target


func _on_body_entered(_body: Node2D) -> void:
	reach_target.emit()
