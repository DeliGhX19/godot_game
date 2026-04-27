class_name PlayerStats

var max_hp: float                         # 生命上限
var move_speed: float                     # 移动速度
var jump_height: float                    # 跳跃高度
var crit_rate: float                      # 暴击率
var damage_reduction: float               # 减伤系数

var hp: float                             # 生命值
var damages: Array[float]                 # 造成的伤害（物理/火/木/石/冰/电）
var receiving_damages: Array[float]       # 收到的伤害（物理/火/木/石/冰/电）
var enemies: Array[Array]                 # 攻击的敌人（对应物理/火/木/石/冰/电）

var i_frame_timer: float = 0.0         # 无敌帧计时器
var i_frame_duration: float = 1.0      # 无敌时间


# 初始化（每次进入主游戏时调用）
func initialize(profile: PlayerProfile) ->void:
	max_hp = profile.max_hp
	move_speed = profile.move_speed
	jump_height = profile.jump_height
	crit_rate = profile.crit_rate
	damage_reduction = profile.damage_reduction
	
	hp = max_hp
	damages = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	receiving_damages = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	enemies = [[], [], [], [], [], []]

# 重置（主游戏中每帧调用）
func reset(profile: PlayerProfile) -> void:
	max_hp = profile.max_hp
	move_speed = profile.move_speed
	jump_height = profile.jump_height
	crit_rate = profile.crit_rate
	damage_reduction = profile.damage_reduction
	
	for i in range(6):
		damages[i] = 0.0
		receiving_damages[i] = 0.0
		enemies[i].clear()

# 结算（主游戏中每帧调用）
func settle(delta: float) -> void:
	# 处理无敌帧
	if i_frame_timer > 0: i_frame_timer -= delta
	
	# 玩家攻击敌人
	for i in range(6):
		var is_crit := randf() < crit_rate
		for enemy in enemies[i]:
			enemy.receiving_damages[i] += damages[i] * (1.5 if is_crit else 1.0)
	
	# 结算玩家收到的伤害
	if i_frame_timer <= 0:
		var total_receiving := 0.0
		for i in range(6): total_receiving += receiving_damages[i]
		if total_receiving > 0:
			var fixed_damage_reduction = damage_reduction / (0.5 + damage_reduction)
			hp -= total_receiving * (1.0 - fixed_damage_reduction)
			i_frame_timer = i_frame_duration
