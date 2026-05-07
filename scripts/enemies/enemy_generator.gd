extends Node2D

var enemy_template_dir: String = "res://scenes/enemies/"
var enemy_count: int = 5
var max_enemies: int = 15
var enemy_templates: Array[PackedScene] = []


# 生成关卡敌人
func generate(points: Array[Marker2D]) -> void:
	max_enemies += GameManager.level % 5

	clear_previous_enenmy()
	load_enemy_templates()
	
	points.shuffle()
	var spawn_limit = min(max_enemies, points.size())
	for i in range(spawn_limit):
		# 随机选择敌人生成点和敌人
		var point = points[i]
		var enemy_instance = enemy_templates.pick_random().instantiate()
		
		# 在敌人生成点放置敌人
		add_child(enemy_instance)
		enemy_instance.global_position = point.global_position
		GameManager.enemies.append(enemy_instance)

# 清理关卡敌人
func clear_previous_enenmy() -> void:
	for enemy in GameManager.enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	GameManager.enemies.clear()

# 预加载所有敌人模板
func load_enemy_templates() -> void:
	enemy_templates.clear()
	for i in range(enemy_count):
		enemy_templates.append(load(enemy_template_dir + "enemy_%02d.tscn" % i))
