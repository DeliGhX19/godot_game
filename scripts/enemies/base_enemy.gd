extends CharacterBody2D
class_name BaseEnemy

var explode_scene = load("res://scenes/player/fire_explosion.tscn")
var floating_number_scene: PackedScene = preload("res://scenes/gui/floating_damage.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var max_hp: float
var move_speed: float
var jump_height: float
var crit_rate: float
var base_damages: Array[float]
var damage_reduction: Array[float]
var i_frame_duration: float

var stats: EnemyStats
var buffs: EnemyBuffs

var is_hurt : bool
var knockback_timer: float


func _ready() -> void:
	initialize_stats()
	
	var data = get_data_dict()
	stats = EnemyStats.new()
	buffs = EnemyBuffs.new()
	
	stats.initialize(data)
	buffs.initialize()
	
	stats.hp_changed.connect(_on_hp_changed)
	buffs.fire_explore.connect(_on_fire_explore)
	buffs.knock_back.connect(_on_knock_back)
	is_hurt = false
	knockback_timer = 0.0

func _physics_process(delta: float) -> void:
	buffs.apply(stats, delta)
	stats.settle(delta)
	
	# 检查是否死亡
	if stats.hp <= 0:
		on_death()
		return
	
	# 处理敌人AI(包括眩晕、击退、硬直)
	is_getting_attack()
	if knockback_timer > 0: knockback_timer -= delta
	if not is_hurt and knockback_timer <= 0 and buffs.buffs[EnemyBuffs.STUN] == 0 and buffs.buffs[EnemyBuffs.FREEZE] == 0:
		handle_ai(delta)
	if not is_hurt and buffs.buffs[EnemyBuffs.STUN] == 0 and buffs.buffs[EnemyBuffs.FREEZE] == 0:
		move_and_slide()
	if buffs.buffs[EnemyBuffs.STUN] == 0 and buffs.buffs[EnemyBuffs.FREEZE] == 0:
		update_animation()
	
	#TODO:处理血条
	#
	
	stats.reset(get_data_dict())


# 初始化敌人数据
func initialize_stats() -> void:
	push_error("initialize_stats()未实现！")

# 获取数据字典
func get_data_dict() -> Dictionary:
	return {
		"max_hp": max_hp,
		"move_speed": move_speed,
		"jump_height": jump_height,
		"crit_rate": crit_rate,
		"base_damages": base_damages,
		"damage_reduction": damage_reduction,
		"i_frame_duration": i_frame_duration
	}

# 敌人AI
func handle_ai(_delta: float) -> void:
	push_error("handle_ai()未实现")

# 硬直处理（不吃硬直的敌人重写该函数）
func is_getting_attack() -> void:
	if not is_hurt:
		var total_receiving = 0
		for i in range(GameManager.TYPE_COUNT):
			total_receiving += stats.receiving_damages[i]
		is_hurt = total_receiving > 0

# 更新动画
func update_animation() -> void:
	push_error("update_animation()未实现")

# 死亡
func on_death() -> void:
	set_physics_process(false)
	sprite.play("death")
	if sprite.is_playing():
		await sprite.animation_finished
	queue_free()


func _on_hp_changed(damage: float, color: Color, is_heavy_hit: bool) -> void:
	var floating_number = floating_number_scene.instantiate()
	add_child(floating_number)
	
	floating_number.global_position = global_position + Vector2(0, -40)
	floating_number.display(damage, color, is_heavy_hit)

func _on_fire_explore() -> void:
	stats.i_frame_timer = 0.0
	var explode_instance = explode_scene.instantiate()
	get_parent().add_child(explode_instance)
	explode_instance.global_position = global_position

func _on_knock_back(force: float) -> void:
	var dir = (global_position - GameManager.player.global_position).normalized()
	velocity = dir * force
	knockback_timer = 0.1
