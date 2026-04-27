extends Node2D

signal start_game


func _on_target_reach_target() -> void:
	start_game.emit()
