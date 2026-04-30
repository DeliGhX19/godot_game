extends Node2D

@onready var map_generator: Node2D = $MapGenerator
@onready var enemy_generator: Node2D = $EnemyGenerator
@onready var player: CharacterBody2D = $Player

var profile: PlayerProfile


func _ready() -> void:
	player.initialize(profile)
	initialize_level()


# 初始化关卡
func initialize_level() -> void:
	map_generator.generate_level()
	enemy_generator.generator_enemy(map_generator.get_all_enemy_points())
	player.position = Vector2(128, 128)

# 游戏结束
func game_over() -> void:
	var camp_scene = load("res://scenes/main/camp.tscn")
	var camp_instance = camp_scene.instantiate()
	camp_instance.profile = profile
	
	get_tree().root.add_child(camp_instance)
	queue_free()


func _on_map_generator_next_level() -> void:
	call_deferred("initialize_level")

func _on_player_die() -> void:
	call_deferred("game_over")
