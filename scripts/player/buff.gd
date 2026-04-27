class_name PlayerBuffs

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
const BUFFER_COUNT = 12

var buffs: Array[int]


# 初始化（每次进入主游戏时调用）
func initialize() -> void:
	buffs.resize(BUFFER_COUNT)
	for i in range(BUFFER_COUNT):
		buffs[i] = 0

# 应用buff（主游戏每帧调用）
func apply(stats) -> void:
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
