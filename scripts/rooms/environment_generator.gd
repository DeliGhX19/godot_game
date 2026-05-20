extends CanvasLayer

@onready var post_rect: ColorRect = $ColorRect

var environment_pool: Array[EnvironmentData] = [
	EnvironmentData.new(
		"炽热荒庭",      # 火属性+50% 冰属性-50% 灼烧概率+15% 灼烧额外1%扣血 不会附加寒冷
		"res://scripts/rooms/environment/heat.gdshader",
		25.0,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_FIRE] = 1
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_FIRE] = 1,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_FIRE] = 0,
	),
	EnvironmentData.new(
		"沉水渊狱",      # 雷属性+50% 火属性-50% +0.2雷击判定半径 不会附加灼烧 移动改为游泳
		"res://scripts/rooms/environment/water.gdshader",
		25.0,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WATER] = 1
			GameManager.gravity = 0.6 * ProjectSettings.get_setting("physics/2d/default_gravity")
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_WATER] = 1
			for bonfire in get_tree().get_nodes_in_group("bonfire"):
				bonfire.get_node("AnimatedSprite2D").play("unlit"),
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WATER] = 0
			GameManager.gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			for bonfire in get_tree().get_nodes_in_group("bonfire"):
				bonfire.get_node("AnimatedSprite2D").play("lit"),
	),
	EnvironmentData.new(
		"风动高台",      # 部分元素弹道受风向影响（火、石、冰） 移动受到风向影响
		"res://scripts/rooms/environment/wind.gdshader",
		25.0,
		func():
			var wind_angle = randf() * TAU
			GameManager.wind_angle = wind_angle
			var mat = post_rect.material as ShaderMaterial
			mat.set_shader_parameter("wind_angle", wind_angle)
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WIND] = 1
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_WIND] = 1,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WIND] = 0,
	),
	EnvironmentData.new(
		"重压深室",    # 重力增加 石元素+50% 物理攻击+50% 部分元素弹道受重力影响（火、冰） 眩晕时间+0.5s 击退力+100
		"res://scripts/rooms/environment/gravity.gdshader",
		25.0,
		func():
			GameManager.gravity = 1.2 * ProjectSettings.get_setting("physics/2d/default_gravity")
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_GRAVITY] = 1
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_GRAVITY] = 1,
		func():
			GameManager.gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_GRAVITY] = 0,
	),
	EnvironmentData.new(
		"幽暗秘阁",    # 场景变黑 暴击率+0.25 火、雷可照明
		"",
		20.0,
		func():
			for node in get_tree().get_nodes_in_group("light"):
				node.visible = true
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_DARK] = 1
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_DARK] = 1,
		func():
			for node in get_tree().get_nodes_in_group("light"):
				node.visible = false
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_DARK] = 0,
	),
	EnvironmentData.new(
		"极寒雪冢",    # 冰属性+50% 火属性-25% 灼烧概率-15% 寒冷概率+25% 冰冻时间+1s 玩家远离篝火或生命树8s开始霜冻（2%扣血）
		"res://scripts/rooms/environment/winter.gdshader",
		2000.0,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WINTER] = 1
			GameManager.player.buffs.winter_timer = 8.0
			GameManager.player.buffs.winter_damage_tick = 0.0
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_WINTER] = 1,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WINTER] = 0,
	),
	EnvironmentData.new(
		"迷雾遗墟",    # 木属性+100% 随时间增加浓雾变厚(3分钟)
		"res://scripts/rooms/environment/frog.gdshader",
		20.0,
		func():
			var mat = post_rect.material as ShaderMaterial
			mat.set_shader_parameter("fog_thickness", 0.0)
			var tw = create_tween()
			tw.tween_method(func(value): mat.set_shader_parameter("fog_thickness", value), 0.0, 1.0, 180.0)
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_FROG] = 1
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_FROG] = 1,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_FROG] = 0,
	),
	EnvironmentData.new(
		"灵泽福地",    # 减伤率+1 暴击率+1 所有伤害*2 移动速度*1.2 跳跃高度*1.2
		"res://scripts/rooms/environment/grace.gdshader",
		5.0,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_GRACE] = 1,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_GRACE] = 0,
	),
	EnvironmentData.new(
		"血狱修罗",    # 被攻击就会被秒杀
		"res://scripts/rooms/environment/hell.gdshader",
		5.0,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_HELL] = 1
			for enemy in GameManager.enemies:
				enemy.buffs.buffs[EnemyBuffs.ENVIRONMENT_HELL] = 1,
		func():
			GameManager.player.buffs.buffs[PlayerBuffs.ENVIRONMENT_HELL] = 0,
	),
]
var current_env: EnvironmentData = null


# 生成环境
func generate() -> void:
	# 第一层不会生成环境
	# if GameManager.level == 1: return
	
	unload_current()
	
	# 每隔5关必定生成特殊场景
	if GameManager.level % 5 == 0:
		if randf() <= 0.5: current_env = environment_pool[environment_pool.size() -2] 
		else: current_env = environment_pool[environment_pool.size() -1] 
	# 简单场景（25）、困难场景（20）、特殊场景（5）
	else:
		var total_weight := 0.0
		for env in environment_pool:
			total_weight += env.weight

		var roll := randf() * total_weight
		var accum := 0.0
		for env in environment_pool:
			accum += env.weight
			if roll <= accum:
				current_env = env
				break
		if current_env == null:
			current_env = environment_pool[environment_pool.size() - 1]
	
	load_current()


# 加载当前场景
func load_current() -> void:
	if current_env.shader_path == "":
		post_rect.material.shader = null
	else:
		post_rect.material.shader = load(current_env.shader_path) as Shader
	
	GameManager.env_difficulty = current_env.weight
	current_env.on_load.call()

# 卸载当前环境
func unload_current() -> void:
	if current_env != null:
		current_env.on_unload.call()
	current_env = null
