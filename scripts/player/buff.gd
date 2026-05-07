class_name PlayerBuffs

# 通用构筑
const HP_LEVEL_1 = 0      # 纳气（*1.1生命上限）
const HP_LEVEL_2 = 1      # 固本（*1.3生命上限）
const HP_LEVEL_3 = 2      # 培元（*1.5生命上限）
const SPEED_LEVEL_1 = 3   # 微步（+25移动速度）
const SPEED_LEVEL_2 = 4   # 行风（+25移动速度 +50跳跃高度）
const SPEED_LEVEL_3 = 5   # 登云（+50移动速度 +50跳跃高度）
const DR_LEVEL_1 = 6      # 铜皮（+0.0125减伤）
const DR_LEVEL_2 = 7      # 铁骨（+0.025减伤）
const DR_LEVEL_3 = 8      # 金身（+0.05减伤）
const CRIT_LEVEL_1 = 9    # 入神（+0.025暴击率）
const CRIT_LEVEL_2 = 10   # 会心（+0.05暴击率）
const CRIT_LEVEL_3 = 11   # 惊天（+0.075暴击率）
# 远程攻击通用构筑
const MAGIC_DMG_LEVEL_1 = 12    # 聚星（*1.15远程伤害）
const MAGIC_DMG_LEVEL_2 = 13    # 辉阳（*1.30远程伤害）
const MAGIC_DMG_LEVEL_3 = 14    # 曜日（*1.50远程伤害）
const MAGIC_SPD_LEVEL_1 = 15    # 惊鸿（+0.15施法速度）
const MAGIC_SPD_LEVEL_2 = 16    # 游龙（+0.3施法速度）
const MAGIC_SPD_LEVEL_3 = 17    # 瞬影（+0.5施法速度）
const MAGIC_RANGE_LEVEL_1 = 18  # 燕返（+0.2s子弹时间）
const MAGIC_RANGE_LEVEL_2 = 19  # 追月（+0.35s子弹时间）
const MAGIC_RANGE_LEVEL_3 = 20  # 落日（+0.5s子弹时间）
const MAGIC_PIERCE = 21         # 洞石（+1穿透次数）
# 火元素专属构筑
const FIRE_DOT_LEVEL_1 = 22     # 星火（+5伤害）
const FIRE_DOT_LEVEL_2 = 23     # 业火（+5伤害 +1s持续）
const FIRE_DOT_LEVEL_3 = 24     # 焚天（+10伤害 +2s持续）
const FIRE_EXPLODE = 25         # 爆燃（层数>3引爆 *1.1伤害）
const FIRE_ERUPTION = 26        # 炎爆（范围施加3层灼烧）
# 木元素专属构筑
const WOOD_HEAL = 27            # 恢复
const WOOD_HEAL_LEVEL_1 = 28    # 回春（+0.1%生命上限恢复）
const WOOD_HEAL_LEVEL_2 = 29    # 蕴木（+0.2%生命上限恢复）
const WOOD_HEAL_LEVEL_3 = 30    # 万物（+0.5%生命上限恢复）
const WOOD_CONVERT = 31         # 转换（溢出治疗转增益）
const WOOD_TREANT = 32          # 傀儡（濒死敌人变异为生命树）
const WOOD_TREANT_AURA = 33     # 沐泽（靠近生命树获得的持续增益）
# 石元素专属构筑
const STONE_KB_LEVEL_1 = 34     # 沉沙（+50击退）
const STONE_KB_LEVEL_2 = 35     # 碎岩（+70击退）
const STONE_KB_LEVEL_3 = 36     # 镇渊（+100击退）
const STONE_STUN = 37           # 眩晕（+0.2s眩晕）
const STONE_METEOR = 38         # 陨星（范围内随机目标，范围眩晕）
# 冰元素专属构筑
const ICE_SLOW_LEVEL_1 = 39     # 流霜（+1s持续）
const ICE_SLOW_LEVEL_2 = 40     # 凝冰（+1.5s持续）
const ICE_SLOW_LEVEL_3 = 41     # 绝寒（+2s持续 +2%减速增益）
const ICE_FREEZE = 42           # 冻结（层数>5引爆 +0.5s持续）
const ICE_EXPLORE = 43          # 冰爆（范围冻结）
# 雷元素专属构筑
const LIGHTNING_LEVEL_1 = 44    # 惊雷（*1.1伤害）
const LIGHTNING_LEVEL_2 = 45    # 奔雷（+0.1雷击判定半径 *1.1伤害）
const LIGHTNING_LEVEL_3 = 46    # 闪雷（+0.2雷击判定半径 *1.2伤害）
const LIGHTNING_CHAIN = 47      # 连锁（穿透敌人生成 +1生成数）
const LIGHTNING_DISASTER = 48   # 毁灭（秒杀非boss敌人）
# 环境buff
const BONFIRE = 49              # 篝火（小幅提升各项属性）
const ENVIRONMENT_FIRE = 50     # 炽热荒庭（火属性+50% 冰属性-50% 灼烧概率+15% 不会附加寒冷）
const ENVIRONMENT_WATER = 51    # 沉水渊狱（雷属性+50% 火属性-50% +0.2雷击判定半径 不会附加灼烧）
const ENVIRONMENT_WIND = 52     # 风动高台（部分元素弹道受风向影响（火、石、冰） 移动受到风向影响）
const ENVIRONMENT_GRAVITY = 53  # 重压深室（重力增加 石元素+50% 物理攻击+50% 部分元素弹道受重力影响（火、冰） 眩晕时间+0.5s 击退力+100）
const ENVIRONMENT_DARK = 54     # 幽暗秘阁（暴击率+0.25）
const ENVIRONMENT_WINTER = 55   # 极寒雪冢（冰属性+50% 火属性-25% 灼烧概率-15% 寒冷概率+25% 冰冻时间+1s 玩家远离篝火或生命树8s开始霜冻）
const ENVIRONMENT_FROG = 56     # 迷雾遗墟（木属性+100% +1%生命上限恢复）
const ENVIRONMENT_GRACE = 57    # 灵泽福地（减伤率+1 暴击率+1 所有伤害*2 移动速度*1.2 跳跃高度*1.2）
const ENVIRONMENT_HELL = 58     # 血狱修罗（被攻击就会死亡）
# 近战攻击通用构筑
const MELEE_DMG_LEVEL_1 = 100        # 破甲（*1.1近战伤害）
const MELEE_DMG_LEVEL_2 = 101        # 碎玉（*1.25近战伤害）
const MELEE_DMG_LEVEL_3 = 102        # 裂石（*1.5近战伤害）
const MELEE_SPD_LEVEL_1 = 103        # 疾风（+0.1攻击速度）
const MELEE_SPD_LEVEL_2 = 104        # 掠影（+0.2攻击速度）
const MELEE_SPD_LEVEL_3 = 105        # 闪电（+0.35攻击速度）
const MELEE_LIFESTEAL_LEVEL_1 = 106  # 饮血（2%吸血）
const MELEE_LIFESTEAL_LEVEL_2 = 107  # 嗜血（4%吸血）
const MELEE_LIFESTEAL_LEVEL_3 = 108  # 浴血（6%吸血）
const MELEE_KILL_REFRESH_1 = 109     # 杀意（击杀后-15%冷却，持续3秒）
const MELEE_KILL_REFRESH_2 = 110     # 杀意（击杀后-30%冷却，持续3秒）
const MELEE_KILL_REFRESH_3 = 111     # 杀意（击杀后-50%冷却，持续3秒）
# 总buff数
const BUFFER_COUNT = 112
var buffs: Array[int]

var wood_convert_timer: float
var wood_treant_aura_timer: float
var winter_timer: float
var winter_damage_tick: float


func initialize() -> void:
	buffs.resize(BUFFER_COUNT)
	buffs.fill(0)
	
	wood_convert_timer = 0


# 应用buff（主游戏每帧调用）
func apply(stats: PlayerStats, delta: float) -> void:
	# 处理buff
	for i in range(BUFFER_COUNT):
		if buffs[i] == 0: continue
		match i:
			HP_LEVEL_1:
				stats.max_hp *= pow(1.1, buffs[i])
			HP_LEVEL_2:
				stats.max_hp *= pow(1.3, buffs[i])
			HP_LEVEL_3:
				stats.max_hp *= pow(1.5, buffs[i])
			SPEED_LEVEL_1:
				stats.move_speed += 25 * buffs[i]
			SPEED_LEVEL_2:
				stats.move_speed += 25 * buffs[i]
				stats.jump_height += 50 * buffs[i]
			SPEED_LEVEL_3:
				stats.move_speed += 50 * buffs[i]
				stats.jump_height += 50 * buffs[i]
			DR_LEVEL_1:
				stats.damage_reduction += 0.0125 * buffs[i]
			DR_LEVEL_2:
				stats.damage_reduction += 0.025 * buffs[i]
			DR_LEVEL_3:
				stats.damage_reduction += 0.05 * buffs[i]
			CRIT_LEVEL_1:
				stats.crit_rate += 0.025 * buffs[i]
			CRIT_LEVEL_2:
				stats.crit_rate += 0.05 * buffs[i]
			CRIT_LEVEL_3:
				stats.crit_rate += 0.075 * buffs[i]
			MAGIC_DMG_LEVEL_1:
				for j in range(PlayerStats.FIRE_MAGIC, PlayerStats.DAMAGE_SOURCE_COUNT): 
					stats.damages[j].value *= pow(1.15, buffs[i])
			MAGIC_DMG_LEVEL_2:
				for j in range(PlayerStats.FIRE_MAGIC, PlayerStats.DAMAGE_SOURCE_COUNT): 
					stats.damages[j].value *= pow(1.30, buffs[i])
			MAGIC_DMG_LEVEL_3:
				for j in range(PlayerStats.FIRE_MAGIC, PlayerStats.DAMAGE_SOURCE_COUNT): 
					stats.damages[j].value *= pow(1.50, buffs[i])
			MAGIC_SPD_LEVEL_1:
				stats.magic_attack_speed += 0.15 * buffs[i]
			MAGIC_SPD_LEVEL_2:
				stats.magic_attack_speed += 0.3 * buffs[i]
			MAGIC_SPD_LEVEL_3:
				stats.magic_attack_speed += 0.5 * buffs[i]
			MAGIC_RANGE_LEVEL_1:
				stats.magic_range_extra += 0.2 * buffs[i]
			MAGIC_RANGE_LEVEL_2:
				stats.magic_range_extra += 0.35 * buffs[i]
			MAGIC_RANGE_LEVEL_3:
				stats.magic_range_extra += 0.5 * buffs[i]
			MAGIC_PIERCE:
				stats.magic_pierce_extra += 1 * buffs[i]
			FIRE_EXPLODE:
				stats.damages[PlayerStats.FIRE_EXPLOSION].value *= pow(1.1, buffs[FIRE_EXPLODE])
			WOOD_HEAL:
				# 恢复血量
				var heal_ratio = 0.005 + 0.001 * buffs[WOOD_HEAL_LEVEL_1] + 0.002 * buffs[WOOD_HEAL_LEVEL_2] + 0.005 * buffs[WOOD_HEAL_LEVEL_3]
				if buffs[ENVIRONMENT_FROG] > 0: heal_ratio += 0.01
				var heal_amount = heal_ratio * stats.max_hp
				var missing_hp = stats.max_hp - stats.hp
				var actual_heal = min(heal_amount, missing_hp)
				stats.settle_hp(-actual_heal)
				# 处理增益
				if stats.hp >= stats.max_hp and buffs[WOOD_CONVERT] > 0:
					wood_convert_timer = 3.0
				buffs[WOOD_HEAL] = 0
			WOOD_CONVERT:
				if wood_convert_timer > 0:
					wood_convert_timer -= delta
					for j in range(PlayerStats.DAMAGE_SOURCE_COUNT): 
						stats.damages[j].value *= (1.0 + 0.1 * buffs[WOOD_CONVERT])
					stats.move_speed *= (1.0 + 0.05 * buffs[WOOD_CONVERT])
					stats.jump_height *= (1.0 + 0.05 * buffs[WOOD_CONVERT])
					stats.crit_rate += 0.01 * buffs[WOOD_CONVERT]
					stats.damage_reduction += 0.005 * buffs[WOOD_CONVERT]
			WOOD_TREANT_AURA:
				for j in range(PlayerStats.DAMAGE_SOURCE_COUNT): 
					stats.damages[j].value *= 1.2
				stats.move_speed *= 1.1
				stats.jump_height *= 1.1
				stats.crit_rate += 0.15
				stats.damage_reduction += 0.1
				if wood_treant_aura_timer <= 0:
					wood_treant_aura_timer = 5.0
					var missing_hp = stats.max_hp - stats.hp
					var actual_heal = min(0.01 * stats.max_hp, missing_hp)
					stats.settle_hp(-actual_heal)
				else: wood_treant_aura_timer -= delta
			LIGHTNING_LEVEL_1:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.1
			LIGHTNING_LEVEL_2:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.1
			LIGHTNING_LEVEL_3:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.2
			BONFIRE:
				for j in range(PlayerStats.DAMAGE_SOURCE_COUNT): 
					stats.damages[j].value *= 1.05
				stats.move_speed *= 1.05
				stats.crit_rate += 0.05
				stats.damage_reduction += 0.025
			ENVIRONMENT_FIRE:
				stats.damages[PlayerStats.FIRE_MAGIC].value *= 1.5
				stats.damages[PlayerStats.FIRE_EXPLOSION].value *= 1.5
				stats.damages[PlayerStats.FIRE_ERUPTION].value *= 1.5
				stats.damages[PlayerStats.ICE_MAGIC].value *= 0.5
				stats.damages[PlayerStats.ICE_EXPLOSION].value *= 0.5
			ENVIRONMENT_WATER:
				stats.damages[PlayerStats.LIGHTNING_MAGIC].value *= 1.5
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.5
				stats.damages[PlayerStats.CHAIN_LIGHTNING].value *= 1.5
				stats.damages[PlayerStats.FIRE_MAGIC].value *= 0.5
				stats.damages[PlayerStats.FIRE_EXPLOSION].value *= 0.5
				stats.damages[PlayerStats.FIRE_ERUPTION].value *= 0.5
			ENVIRONMENT_GRAVITY:
				stats.damages[PlayerStats.STONE_MAGIC].value *= 1.5
				stats.damages[PlayerStats.STONE_METEOR].value *= 1.5
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= 1.5
			ENVIRONMENT_DARK:
				stats.crit_rate += 0.25
			ENVIRONMENT_WINTER:
				stats.damages[PlayerStats.ICE_MAGIC].value *= 1.5
				stats.damages[PlayerStats.ICE_EXPLOSION].value *= 1.5
				stats.damages[PlayerStats.FIRE_MAGIC].value *= 0.75
				stats.damages[PlayerStats.FIRE_EXPLOSION].value *= 0.75
				stats.damages[PlayerStats.FIRE_ERUPTION].value *= 0.75
				if buffs[BONFIRE] + buffs[WOOD_TREANT_AURA] > 0: 
					winter_timer = 8.0
					winter_damage_tick = 0.0
				else:
					if winter_timer > 0: winter_timer -= delta
					else:
						winter_damage_tick -= delta
						if winter_damage_tick <= 0:
							stats.settle_hp(0.02 * stats.max_hp)
							winter_damage_tick += 1.0
			ENVIRONMENT_FROG:
				stats.damages[PlayerStats.WOOD_MAGIC].value *= 2
			ENVIRONMENT_GRACE:
				for j in range(PlayerStats.DAMAGE_SOURCE_COUNT):
					stats.damages[j].value *= 2
				stats.crit_rate += 1
				stats.damage_reduction += 1
				stats.move_speed *= 1.2
				stats.jump_height *= 1.2
			ENVIRONMENT_HELL:
				for j in range(GameManager.TYPE_COUNT):
					if stats.receiving_damages[j] > 0:
						stats.settle_hp(stats.hp)
						continue
			MELEE_DMG_LEVEL_1:
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= pow(1.1, buffs[i])
			MELEE_DMG_LEVEL_2:
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= pow(1.25, buffs[i])
			MELEE_DMG_LEVEL_3:
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= pow(1.5, buffs[i])
			MELEE_SPD_LEVEL_1:
				stats.melee_attack_speed += 0.1 * buffs[i]
			MELEE_SPD_LEVEL_2:
				stats.melee_attack_speed += 0.2 * buffs[i]
			MELEE_SPD_LEVEL_3:
				stats.melee_attack_speed += 0.35 * buffs[i]
			MELEE_LIFESTEAL_LEVEL_1:
				stats.lifesteal += 0.02 * buffs[i]
			MELEE_LIFESTEAL_LEVEL_2:
				stats.lifesteal += 0.04 * buffs[i]
			MELEE_LIFESTEAL_LEVEL_3:
				stats.lifesteal += 0.06 * buffs[i]

# 添加生命加成buff
func add_hp_buff(level: int, stats: PlayerStats) -> void:
	if level == 1:
		buffs[HP_LEVEL_1] += 1
		stats.settle_hp(-min(0.1 * stats.hp, 1.1 * stats.max_hp - stats.hp))
	elif level == 2:
		buffs[HP_LEVEL_2] += 1
		stats.settle_hp(-min(0.3 * stats.hp, 1.3 * stats.max_hp - stats.hp))
	elif level == 3:
		buffs[HP_LEVEL_3] += 1
		stats.settle_hp(-min(0.5 * stats.hp, 1.5 * stats.max_hp - stats.hp))
