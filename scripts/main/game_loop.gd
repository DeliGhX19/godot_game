extends Node2D

@onready var map_generator: Node2D = $MapGenerator
@onready var bonus_generator: Node2D = $BonusGenerator
@onready var enemy_generator: Node2D = $EnemyGenerator
@onready var environment_generator: CanvasLayer = $EnvironmentGenerator
@onready var player: CharacterBody2D = $Player
@onready var ui: CanvasLayer = $UIRoot

var profile: PlayerProfile         # 玩家存档


func _ready() -> void:
	profile.rebuild_stats_from_meta()
	player.initialize(profile)
	ui.initialize(player)

	GameManager.player = player
	GameManager.reward_manager = RewardManager.new()
	GameManager.level = 0

	initialize_level()


# 初始化关卡
func initialize_level() -> void:
	GameManager.level += 1
	
	map_generator.generate_level()
	enemy_generator.generate(map_generator.get_all_enemy_points())
	environment_generator.generate()
	bonus_generator.generate(map_generator.get_all_bonus_points())
	
	player.position = Vector2(128, 128)
	if environment_generator.current_env != null:
		ui.show_environment_title(environment_generator.current_env.name)

# 游戏结束
func game_over() -> void:
	var camp_scene = load("res://scenes/main/camp.tscn")
	var camp_instance = camp_scene.instantiate()
	profile.rebuild_stats_from_meta()
	camp_instance.profile = profile
	profile.save()

	get_tree().root.add_child(camp_instance)
	queue_free()


func _on_map_generator_next_level() -> void:
	call_deferred("initialize_level")


func _on_player_die() -> void:
	call_deferred("game_over")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# 调试用作弊指令
		if event.keycode == KEY_J:
			get_tree().get_first_node_in_group("rewards_gui").open_reward_gui("ultimate")
