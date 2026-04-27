class_name EnemyBuffs

const FIRE_VULNERABILITY = 0    # 易燃：火属性受击翻倍
const BUFF_COUNT = 1

var buffs: Array[int]


# 初始化（每次预载时调用）
func initialize() -> void:
	buffs.resize(BUFF_COUNT)
	for i in range(BUFF_COUNT):
		buffs[i] = 0

# 应用buff（主游戏每帧调用）
func apply(stats: EnemyStats) -> void:
	for i in range(BUFF_COUNT):
		if buffs[i] == 0: continue
		match i:
			FIRE_VULNERABILITY:
				stats.receiving_damages[1] *= 2
