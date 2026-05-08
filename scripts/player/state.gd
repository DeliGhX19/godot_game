class_name PlayerStats

class DamagePacket:
	var value: float = 0   # 伤害
	var type: int = 0      # 类别（物理/火/木/石/冰/电）
const PHYSIC_ATTACK = 0                   # 近战
const FLYING_SWORD = 1                    # 飞剑
const FIRE_MAGIC = 2                      # 火魔法
const FIRE_EXPLOSION = 3                  # 爆燃
const FIRE_ERUPTION = 4                   # 炎爆
const WOOD_MAGIC = 5                      # 木魔法
const STONE_MAGIC = 6                     # 石魔法
const STONE_METEOR = 7                    # 陨星
const ICE_MAGIC = 8                       # 冰魔法
const ICE_EXPLOSION = 9                   # 冰爆
const LIGHTNING_MAGIC = 10                # 雷魔法
const LIGHTNING_SPLASH = 11               # 雷魔法溅射
const CHAIN_LIGHTNING = 12                # 连锁雷
const DAMAGE_SOURCE_COUNT = 13            # 所有伤害来源

var max_hp: float                         # 生命上限
var move_speed: float                     # 移动速度
var jump_height: float                    # 跳跃高度
var crit_rate: float                      # 暴击率
var damage_reduction: float               # 减伤系数

var hp: float                             # 生命值
var receiving_damages: Array[float]       # 收到的伤害
var damages: Array[DamagePacket]          # 造成的伤害
var enemies: Array[Array]                 # 攻击的敌人

var i_frame_timer: float = 0.0            # 无敌帧计时器
var i_frame_duration: float = 1.0         # 无敌时间

var magic_attack_speed: float             # 远程攻击速度
var magic_pierce_extra: int               # 远程攻击增加的穿透次数
var magic_range_extra: float              # 远程攻击增加的持续时间

var melee_attack_speed: float = 1.0       # 近战攻击速度
var lifesteal: float = 0.0                # 吸血比例
var melee_kill_refresh: float = 0.0       # 杀意之迸：冷却减少比例
var melee_kill_refresh_timer: float = 0.0 # 杀意持续计时器

var flying_sword_count: int = 0
var flying_sword_damage: float = 0.0
var flying_sword_detect_radius: float = 220.0
var flying_sword_attack_radius: float = 40.0
var flying_sword_orbit_radius: float = 48.0
var flying_sword_orbit_speed: float = 2.0
var flying_sword_move_speed: float = 520.0
var flying_sword_attack_cooldown: float = 0.6

var slide_timer: float = 0.0              # 闪避计时器（便于Buff处理）

signal hp_changed(damage: float, color: Color, is_heavy_hit: bool)
signal enemy_killed


# 初始化（每次进入主游戏时调用）
func initialize(profile: PlayerProfile) ->void:
	profile.rebuild_stats_from_meta()
	max_hp = profile.max_hp
	move_speed = profile.move_speed
	jump_height = profile.jump_height
	crit_rate = profile.crit_rate
	damage_reduction = profile.damage_reduction
	
	hp = max_hp
	receiving_damages.resize(GameManager.TYPE_COUNT)
	receiving_damages.fill(0.0)
	damages.resize(DAMAGE_SOURCE_COUNT)
	enemies.resize(DAMAGE_SOURCE_COUNT)
	for i in range(DAMAGE_SOURCE_COUNT):
		damages[i] = DamagePacket.new()
		enemies[i] = []
	
	magic_attack_speed = 1.0
	magic_pierce_extra = 0
	magic_range_extra = 0
	
	melee_attack_speed = 1.0
	lifesteal = 0.0
	melee_kill_refresh = 0.0
	melee_kill_refresh_timer = 0.0

	flying_sword_count = 0
	flying_sword_damage = 0.0
	flying_sword_detect_radius = 220.0
	flying_sword_attack_radius = 40.0
	flying_sword_orbit_radius = 48.0
	flying_sword_orbit_speed = 2.0
	flying_sword_move_speed = 520.0
	flying_sword_attack_cooldown = 0.6

# 重置（主游戏中每帧调用）
func reset(profile: PlayerProfile) -> void:
	profile.rebuild_stats_from_meta()
	max_hp = profile.max_hp
	move_speed = profile.move_speed
	jump_height = profile.jump_height
	crit_rate = profile.crit_rate
	damage_reduction = profile.damage_reduction
	
	for i in range(GameManager.TYPE_COUNT): 
		receiving_damages[i] = 0.0
	for i in range(DAMAGE_SOURCE_COUNT):
		damages[i].value = 0.0
		enemies[i].clear()
		
	magic_attack_speed = 1.0
	magic_pierce_extra = 0
	magic_range_extra = 0
	
	melee_attack_speed = 1.0
	lifesteal = 0.0

	flying_sword_count = 0
	flying_sword_damage = 0.0
	flying_sword_detect_radius = 220.0
	flying_sword_attack_radius = 40.0
	flying_sword_orbit_radius = 48.0
	flying_sword_orbit_speed = 2.0
	flying_sword_move_speed = 520.0
	flying_sword_attack_cooldown = 0.6

# 结算（主游戏中每帧调用）
func settle(delta: float) -> void:
	# 处理无敌帧
	if i_frame_timer > 0: i_frame_timer -= delta
	
	# 处理杀意之迸计时器
	if melee_kill_refresh_timer > 0:
		melee_kill_refresh_timer -= delta
		if melee_kill_refresh_timer <= 0:
			melee_kill_refresh = 0.0
	
	# 玩家攻击敌人
	var melee_damage_dealt := 0.0
	for i in range(DAMAGE_SOURCE_COUNT):
		var type = damages[i].type
		var is_crit := randf() < crit_rate
		for enemy in enemies[i]:
			var damage_dealt = damages[i].value * (1.5 if is_crit else 1.0)
			enemy.stats.receiving_damages[type] += damage_dealt
			if i == PHYSIC_ATTACK:
				melee_damage_dealt += damage_dealt
	
	# 吸血处理（仅近战伤害）
	if lifesteal > 0 and melee_damage_dealt > 0:
		settle_hp(-melee_damage_dealt * lifesteal)
	
	# 结算玩家收到的伤害
	if i_frame_timer <= 0:
		var total_receiving := 0.0
		for i in range(GameManager.TYPE_COUNT): 
			total_receiving += receiving_damages[i]
		if total_receiving > 0:
			var fixed_damage_reduction = damage_reduction / (0.5 + damage_reduction)
			settle_hp(total_receiving * (1.0 - fixed_damage_reduction))
			i_frame_timer = i_frame_duration


# 伤害结算
func settle_hp(damage: float) -> void:
	hp -= damage
	
	var display_color = Color.RED if damage > 0 else Color.GREEN
	var is_heavy_hit = (damage > 0) and (abs(damage) >= max_hp * 0.3) 
	hp_changed.emit(abs(damage), display_color, is_heavy_hit)
