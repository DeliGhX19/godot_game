extends CharacterBody2D
class_name BaseEnemy

var max_hp: float
var move_speed: float
var jump_height: float
var crit_rate: float
var damage_reduction: float
var i_frame_duration: float

var stats: EnemyStats
var buffs: EnemyBuffs

# TODO: 调试用，后续改
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	initialize_stats()
	
	var data = get_data_dict()
	stats = EnemyStats.new()
	buffs = EnemyBuffs.new()
	
	stats.initialize(data)
	buffs.initialize()

func _physics_process(delta: float) -> void:
	buffs.apply(stats)
	stats.settle(delta)
	
	# 处理敌人AI
	handle_ai(delta)
	move_and_slide()
	update_animation()
	
	# 检查是否死亡
	if stats.hp <= 0:
		on_death()
		return
	
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
		"damage_reduction": damage_reduction,
		"i_frame_duration": i_frame_duration
	}

# 敌人AI
func handle_ai(_delta: float) -> void:
	push_error("handle_ai()未实现！")

# 更新动画
func update_animation() -> void:
	push_error("update_animation()未实现！")

# 死亡
func on_death() -> void:
	push_error("on_death()未实现！")
