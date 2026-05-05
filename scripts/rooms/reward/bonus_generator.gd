extends Node2D

var bonus_scene: PackedScene = load("res://scenes/rooms/reward/bonus.tscn")
var max_bonus: int = 3
var bonus_nodes: Array[Node2D] = []


# 生成奖励
func generator_bonus(points: Array[Marker2D]) -> void:
	clear_previous_bonus()
	
	points.shuffle()
	var spawn_limit = min(max_bonus, points.size())
	var ultimate_spawned : bool = false
	for i in range(spawn_limit):
		# 随机选取点位
		var point = points[i]
		var bonus_instance = bonus_scene.instantiate()
		
		# 设置奖励级别（60%basic 30%advanced 10%且至多1个ultimate）
		var roll = randf()
		var tier : int = 0
		if roll < 0.1 and not ultimate_spawned:
			tier = 2               # ultimate
			ultimate_spawned = true 
		elif roll < 0.4: tier = 1   # advanced
		else: tier = 0              # basic
		
		add_child(bonus_instance)
		bonus_instance.global_position = point.global_position
		bonus_instance.initialize(tier)
		bonus_nodes.append(bonus_instance)

# 清理关卡奖励
func clear_previous_bonus() -> void:
	for bonus in bonus_nodes:
		if is_instance_valid(bonus):
			bonus.queue_free()
	bonus_nodes.clear()
