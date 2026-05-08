extends CharacterBody2D
class_name BaseEnemy

var fire_explode_scene = load("res://scenes/player/fire_explosion.tscn")
var wood_treant_scene = load("res://scenes/player/wood_treant.tscn")
var ice_explode_scene = load("res://scenes/player/ice_explosion.tscn")
var floating_number_scene: PackedScene = preload("res://scenes/gui/floating_damage.tscn")
var hp_bar_scene: PackedScene = preload("res://scenes/gui/enemy_hp_bar.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var buff_ui_scene: PackedScene = preload("res://scenes/gui/enemy_buff_ui.tscn")

var max_hp: float
var move_speed: float
var jump_height: float
var crit_rate: float
var base_damages: Array[float]
var damage_reduction: Array[float]
var i_frame_duration: float
var buff_ui

var stats: EnemyStats
var buffs: EnemyBuffs

var is_hurt: bool
var is_super_armor: bool = false
var knockback_timer: float
var meta_currency_reward: int = 1


func _ready() -> void:
	initialize_stats()

	var data = get_data_dict()
	stats = EnemyStats.new()
	buffs = EnemyBuffs.new()

	stats.initialize(data)
	buffs.initialize()

	stats.hp_changed.connect(_on_hp_changed)
	buffs.fire_explore.connect(_on_fire_explore)
	buffs.ice_explore.connect(_on_ice_explore)
	buffs.knock_back.connect(_on_knock_back)
	is_hurt = false
	knockback_timer = 0.0
	var hp_bar = hp_bar_scene.instantiate()
	add_child(hp_bar)
	hp_bar.initialize(self)
	buff_ui = buff_ui_scene.instantiate()
	add_child(buff_ui)

	buff_ui.position = Vector2(-20, -80)
	buff_ui.initialize(self)


func _physics_process(delta: float) -> void:
	buffs.apply(stats, delta)
	stats.settle(delta)
	is_super_armor = has_attack_super_armor()

	# 检查是否死亡
	if stats.hp <= 0:
		on_death()
		return
	
	# 处理敌人AI(包括眩晕、击退、硬直)
	is_getting_attack()
	if knockback_timer > 0:
		knockback_timer -= delta
	if not is_hurt and knockback_timer <= 0 and buffs.buffs[EnemyBuffs.STUN] == 0 and buffs.buffs[EnemyBuffs.FREEZE] == 0:
		handle_ai(delta)
	if buffs.buffs[EnemyBuffs.STUN] == 0 and buffs.buffs[EnemyBuffs.FREEZE] == 0:
		move_and_slide()
		update_animation()
	
	# buff视觉效果
	var final_color = Color.WHITE
	if buffs.buffs[EnemyBuffs.FREEZE] > 0:
		final_color = final_color.lerp(Color(0.3, 0.6, 1.0, 1.0), 0.6)
	if buffs.buffs[EnemyBuffs.ICE] > 0:
		var ice_factor = clampf(buffs.buffs[EnemyBuffs.ICE] / 5.0, 0.05, 0.8)
		final_color = final_color.lerp(Color(0.5, 0.8, 1.0, 1.0), ice_factor)
	if buffs.buffs[EnemyBuffs.BURN] > 0:
		var burn_factor = clampf(buffs.buffs[EnemyBuffs.BURN] / 3.0, 0.1, 0.85)
		final_color = final_color.lerp(Color(1.0, 0.3, 0.0, 1.0), burn_factor)
	if buffs.buffs[EnemyBuffs.STUN] > 0:
		final_color = final_color.lerp(Color(1.0, 0.9, 0.1, 1.0), 0.5)
	modulate = final_color
	
	stats.reset(get_data_dict())


# 初始化敌人数据
func initialize_stats() -> void:
	push_error("initialize_stats()未实现！")

# 获取数据字典
func get_data_dict() -> Dictionary:
	var incr = GameManager.level - 1
	var hp_multi = 1.0 + 0.25 * incr + 0.1 * incr * incr
	var damage_multi = 1.0 + 0.15 * incr + 0.2 * incr * incr
	var other_factor: int = incr / 5.0

	var damages = base_damages.duplicate()
	var dr = damage_reduction.duplicate()
	for i in damages.size():
		damages[i] *= damage_multi
	for i in dr.size():
		dr[i] += min(0.05 * other_factor, 0.5)

	return {
		"max_hp": max_hp * hp_multi,
		"move_speed": move_speed * min(1.0 + 0.25 * other_factor, 3.0),
		"jump_height": jump_height * min(1.0 + 0.2 * other_factor, 2.0),
		"crit_rate": crit_rate + min(0.1 * other_factor, 0.5),
		"base_damages": damages,
		"damage_reduction": dr,
		"i_frame_duration": i_frame_duration
	}

# 敌人AI
func handle_ai(_delta: float) -> void:
	push_error("handle_ai()未实现！")

# 硬直处理（不吃硬直的敌人重写该函数）
func is_getting_attack() -> void:
	if not is_hurt:
		var total_receiving := 0.0
		for i in range(GameManager.TYPE_COUNT):
			total_receiving += stats.receiving_damages[i]
		is_hurt = total_receiving > 0 and not is_super_armor
		if knockback_timer <= 0:
			velocity.x = 0


func has_attack_super_armor() -> bool:
	if get("is_attacking") == null or get("attack_start_frame") == null or get("attack_end_frame") == null:
		return false
	var attacking = bool(get("is_attacking"))
	if not attacking:
		return false
	if sprite.animation != "attack":
		return false
	var start_frame: int = int(get("attack_start_frame"))
	var end_frame: int = int(get("attack_end_frame"))
	return sprite.frame >= max(start_frame - 1, 0) and sprite.frame <= end_frame

# 更新动画
func update_animation() -> void:
	push_error("update_animation()未实现")

# 死亡
func on_death() -> void:
	set_physics_process(false)
	if GameManager.player and GameManager.player.profile:
		GameManager.player.profile.meta_currency += meta_currency_reward
	
	# 触发杀意之迸效果（立即触发，不等动画）
	if GameManager.player and GameManager.player.buffs.buffs[PlayerBuffs.MELEE_KILL_REFRESH_1] > 0:
		var refresh_amount = 0.15 * GameManager.player.buffs.buffs[PlayerBuffs.MELEE_KILL_REFRESH_1]
		GameManager.player.stats.melee_kill_refresh = refresh_amount
		GameManager.player.stats.melee_kill_refresh_timer = 3.0
	elif GameManager.player and GameManager.player.buffs.buffs[PlayerBuffs.MELEE_KILL_REFRESH_2] > 0:
		var refresh_amount = 0.30 * GameManager.player.buffs.buffs[PlayerBuffs.MELEE_KILL_REFRESH_2]
		GameManager.player.stats.melee_kill_refresh = refresh_amount
		GameManager.player.stats.melee_kill_refresh_timer = 3.0
	elif GameManager.player and GameManager.player.buffs.buffs[PlayerBuffs.MELEE_KILL_REFRESH_3] > 0:
		var refresh_amount = 0.50 * GameManager.player.buffs.buffs[PlayerBuffs.MELEE_KILL_REFRESH_3]
		GameManager.player.stats.melee_kill_refresh = refresh_amount
		GameManager.player.stats.melee_kill_refresh_timer = 3.0

	sprite.play("death")
	if sprite.is_playing():
		await sprite.animation_finished
	if buffs.buffs[EnemyBuffs.WOOD_TREANT_TAG] > 0 and randf() <= 0.2:
		var wood_treant = wood_treant_scene.instantiate()
		get_parent().add_child(wood_treant)
		wood_treant.global_position = global_position
	queue_free()


func _on_hp_changed(damage: float, color: Color, is_heavy_hit: bool) -> void:
	var floating_number = floating_number_scene.instantiate()
	add_child(floating_number)

	floating_number.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, -20))
	floating_number.display(damage, color, is_heavy_hit)


func _on_fire_explore() -> void:
	var fire_explode_instance = fire_explode_scene.instantiate()
	get_parent().add_child(fire_explode_instance)
	fire_explode_instance.global_position = global_position


func _on_ice_explore() -> void:
	var ice_explode_instance = ice_explode_scene.instantiate()
	ice_explode_instance.initialize(self)
	get_parent().add_child(ice_explode_instance)
	ice_explode_instance.global_position = global_position


func _on_knock_back(force: float) -> void:
	var dir = (global_position - GameManager.player.global_position).normalized()
	velocity = dir * force
	knockback_timer = 0.1
