extends Node2D

@onready var player: CharacterBody2D = $Player

var profile: PlayerProfile


func _ready() -> void:
	profile.rebuild_stats_from_meta()
	player.initialize(profile)


# 开始游戏
func start_game() -> void:
	profile.rebuild_stats_from_meta()
	var game_loop_scene = load("res://scenes/main/game_loop.tscn")
	var game_loop_instance = game_loop_scene.instantiate()
	game_loop_instance.profile = profile
	
	get_tree().root.add_child(game_loop_instance)
	queue_free()


func _on_rest_room_start_game() -> void:
	call_deferred("start_game")
