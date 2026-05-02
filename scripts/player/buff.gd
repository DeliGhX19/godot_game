class_name PlayerBuffs

# 通用构筑
const HP_LEVEL_1 = 0      # 纳气（*1.1生命上限）
const HP_LEVEL_2 = 1      # 固本（*1.3生命上限）
const HP_LEVEL_3 = 2      # 培元（*1.5生命上限）
const SPEED_LEVEL_1 = 3   # 微步（+20移动速度）
const SPEED_LEVEL_2 = 4   # 行风（+25移动速度 +15跳跃高度）
const SPEED_LEVEL_3 = 5   # 登云（+30移动速度 +25跳跃高度）
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
const MAGIC_RANGE_LEVEL_3 = 20  # 落日（+0.5s飞弹时间）
const MAGIC_PIERCE = 21         # 洞石（+1穿透次数）
# 火元素专属构筑
const FIRE_DOT_LEVEL_1 = 22     # 星火（+5伤害）
const FIRE_DOT_LEVEL_2 = 23     # 业火（+5伤害 +1s持续）
const FIRE_DOT_LEVEL_3 = 24     # 焚天（+10伤害 +2s持续）
const FIRE_EXPLODE = 25         # 爆燃（层数>3引爆 *1.1伤害）
# 木元素专属构筑
const WOOD_HEAL = 26            # 恢复
const WOOD_HEAL_LEVEL_1 = 27    # 回春（+0.1%生命上限恢复）
const WOOD_HEAL_LEVEL_2 = 28    # 蕴木（+0.2%生命上限恢复）
const WOOD_HEAL_LEVEL_3 = 29    # 万物（+0.5%生命上限恢复）
const WOOD_CONVERT = 30         # 转换（溢出治疗转增益）
# 石元素专属构筑
const STONE_KB_LEVEL_1 = 31     # 沉沙（+60击退）
const STONE_KB_LEVEL_2 = 32     # 碎岩（+100击退）
const STONE_KB_LEVEL_3 = 33     # 镇渊（+150击退）
const STONE_STUN = 34           # 眩晕（+0.2s眩晕）
# 冰元素专属构筑
const ICE_SLOW_LEVEL_1 = 35     # 流霜（+1s持续）
const ICE_SLOW_LEVEL_2 = 36     # 凝冰（+1.5s持续）
const ICE_SLOW_LEVEL_3 = 37     # 绝寒（+2s持续 +2%减速增益）
const ICE_FREEZE = 38           # 冻结（层数>5引爆 +0.5s持续）
# 雷元素专属构筑
const LIGHTNING_LEVEL_1 = 39    # 惊雷（*1.1伤害）
const LIGHTNING_LEVEL_2 = 40    # 奔雷（+0.1雷击判定半径 *1.1伤害）
const LIGHTNING_LEVEL_3 = 41    # 闪雷（+0.2雷击判定半径 *1.2伤害）
const LIGHTNING_CHAIN = 42      # 连锁（穿透敌人生成 +1生成数）
# 近战攻击通用构筑
const MELEE_DMG_LEVEL_1 = 100   # 破甲（*1.1近战伤害）
const MELEE_DMG_LEVEL_2 = 101   # 碎玉（*1.25近战伤害）
const MELEE_DMG_LEVEL_3 = 102   # 裂石（*1.5近战伤害）
const MELEE_SPD_LEVEL_1 = 103   # 疾风（+0.1攻击速度）
const MELEE_SPD_LEVEL_2 = 104   # 掠影（+0.2攻击速度）
const MELEE_SPD_LEVEL_3 = 105   # 闪电（+0.35攻击速度）
const MELEE_LIFESTEAL_LEVEL_1 = 106  # 饮血（2%吸血）
const MELEE_LIFESTEAL_LEVEL_2 = 107  # 嗜血（4%吸血）
const MELEE_LIFESTEAL_LEVEL_3 = 108  # 浴血（6%吸血）
const MELEE_KILL_REFRESH_1 = 109     # 杀意（击杀后-15%冷却，持续3秒）
const MELEE_KILL_REFRESH_2 = 110     # 杀意（击杀后-30%冷却，持续3秒）
const MELEE_KILL_REFRESH_3 = 111     # 杀意（击杀后-50%冷却，持续3秒）
#总buff数
const BUFFER_COUNT = 112
var buffs: Array[int]

var wood_convert_timer: float


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
				stats.move_speed += 20 * buffs[i]
			SPEED_LEVEL_2:
				stats.move_speed += 25 * buffs[i]
				stats.jump_height += 15 * buffs[i]
			SPEED_LEVEL_3:
				stats.move_speed += 30 * buffs[i]
				stats.jump_height += 25 * buffs[i]
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
						stats.damages[j].vaule *= (1.0 + 0.1 * buffs[WOOD_CONVERT])
					stats.move_speed *= (1.0 + 0.05 * buffs[WOOD_CONVERT])
					stats.jump_height *= (1.0 + 0.05 * buffs[WOOD_CONVERT])
					stats.damage_reduction += 0.005 * buffs[WOOD_CONVERT]
			LIGHTNING_LEVEL_1:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.1
			LIGHTNING_LEVEL_2:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.1
			LIGHTNING_LEVEL_3:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.2
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
			
