extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var meta_upgrades: CanvasLayer = $MetaUpgrades
@onready var skeleton_shopkeeper: Area2D = $SkeletonShopkeeper

var profile: PlayerProfile


func _ready() -> void:
	profile.rebuild_stats_from_meta()
	player.initialize(profile)
	meta_upgrades.initialize(profile)


func _on_skeleton_shopkeeper_interact_requested() -> void:
	if meta_upgrades.is_open():
		return
	meta_upgrades.open(profile)


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

# 退出并保存
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			profile.save()
		
			var saves_scene = load("res://scenes/main/select_saves.tscn")
			var saves_scene_instance = saves_scene.instantiate()
			get_tree().root.add_child(saves_scene_instance)
			queue_free()
