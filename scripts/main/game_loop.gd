extends Node2D

@onready var map_generator: Node2D = $MapGenerator
@onready var bonus_generator: Node2D = $BonusGenerator
@onready var enemy_generator: Node2D = $EnemyGenerator
@onready var player: CharacterBody2D = $Player
var ui_scene: PackedScene = preload("res://scenes/gui/ui_root.tscn")

var profile: PlayerProfile


func _ready() -> void:
	player.initialize(profile)
	GameManager.player = player
	GameManager.reward_manager = RewardManager.new()
	
	var ui = ui_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.initialize(player)
	
	initialize_level()


# 初始化关卡
func initialize_level() -> void:
	map_generator.generate_level()
	bonus_generator.generator_bonus(map_generator.get_all_bonus_points())
	enemy_generator.generator_enemy(map_generator.get_all_enemy_points())
	player.position = Vector2(128, 128)

# 游戏结束
func game_over() -> void:
	# 先清理所有 UI（CanvasLayer）
	for child in get_tree().root.get_children():
		if child is CanvasLayer:
			child.queue_free()
	
	var camp_scene = load("res://scenes/main/camp.tscn")
	var camp_instance = camp_scene.instantiate()
	camp_instance.profile = profile
	
	get_tree().root.add_child(camp_instance)
	queue_free()


func _on_map_generator_next_level() -> void:
	call_deferred("initialize_level")

func _on_player_die() -> void:
	call_deferred("game_over")



# debug(按下J选择奖励)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_J:
			get_tree().get_first_node_in_group("rewards_gui").open_reward_gui("ultimate")
