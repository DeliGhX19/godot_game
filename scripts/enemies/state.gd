class_name EnemyStats

var max_hp: float                         # 生命上限
var move_speed: float                     # 移动速度
var jump_height: float                    # 跳跃高度
var crit_rate: float                      # 暴击率
var damage_reduction: Array[float]        # 减伤系数

var hp: float                             # 生命值
var base_damages: Array[float]            # 造成的伤害（物理/火/木/石/冰/电）
var receiving_damages: Array[float]       # 收到的伤害（物理/火/木/石/冰/电）
var player: PlayerStats                   # 是否攻击到玩家

var i_frame_timer: float = 0.0            # 无敌帧计时器
var i_frame_duration: float               # 无敌时间

signal hp_changed(damage: float, color: Color, is_heavy_hit: bool)


# 初始化（每次预载时调用）
func initialize(data: Dictionary) ->void:
	max_hp = data["max_hp"]
	move_speed = data["move_speed"]
	jump_height = data["jump_height"]
	crit_rate = data["crit_rate"]
	damage_reduction = data["damage_reduction"]
	i_frame_duration = data["i_frame_duration"]
	base_damages = data["base_damages"]
	
	hp = max_hp
	receiving_damages.resize(GameManager.TYPE_COUNT)
	receiving_damages.fill(0.0)

# 重置（主游戏中每帧调用）
func reset(data: Dictionary) -> void:
	max_hp = data["max_hp"]
	move_speed = data["move_speed"]
	jump_height = data["jump_height"]
	crit_rate = data["crit_rate"]
	damage_reduction = data["damage_reduction"]
	base_damages = data["base_damages"]
	
	player = null
	for i in range(GameManager.TYPE_COUNT): 
		receiving_damages[i] = 0.0

# 结算（主游戏中每帧调用）
func settle(delta: float) -> void:
	# 处理无敌帧
	if i_frame_timer > 0: i_frame_timer -= delta
	
	# 敌人攻击玩家
	if player:
		var is_crit := randf() < crit_rate
		for i in range(GameManager.TYPE_COUNT):
			player.receiving_damages[i] += base_damages[i] * (1.5 if is_crit else 1.0)
	
	# 结算敌人收到的伤害
	if i_frame_timer <= 0:
		for i in range(GameManager.TYPE_COUNT):
			if receiving_damages[i] > 0:
				settle_hp(receiving_damages[i] * (1.0 - damage_reduction[i]))
				i_frame_timer = i_frame_duration


# 伤害结算
func settle_hp(damage: float) -> void:
	hp -= damage
	
	var display_color = Color.RED if damage > 0 else Color.GREEN
	var is_heavy_hit = (damage > 0) and (abs(damage) >= max_hp * 0.3) 
	hp_changed.emit(abs(damage), display_color, is_heavy_hit)
