class_name EnemyBuffs

const BURN = 0              # 火焰灼烧（基础：5dmg/s 3s）
const KNOCK_BACK = 1        # 击退（基础：300）
const STUN = 2              # 眩晕（基础：0.5s）
const FREEZE = 3            # 冻结（基础：2s）
const ICE = 4               # 减速（基础：-10%速度） 
const WOOD_TREANT_TAG = 5   # 傀儡标记（0.5s标记 20%生成傀儡）
const ICE_EXPLOSION = 6     # 冰爆
const EXECUTE = 7           # 秒杀
const BUFF_COUNT = 8
var buffs: Array[int]

var p_buffs = GameManager.player.buffs.buffs
var burn_timers: Array
var stun_timer: float
var ice_timers: Array[float]
var freeze_timer: float
var treant_timer: float

signal fire_explore
signal ice_explore
signal knock_back(force: float)


func initialize() -> void:
	buffs.resize(BUFF_COUNT)
	buffs.fill(0)
	
	burn_timers.clear()
	stun_timer = 0
	ice_timers.clear()
	freeze_timer = 0


# 应用buff（主游戏每帧调用）
func apply(stats: EnemyStats, delta:float) -> void:
	for i in range(BUFF_COUNT):
		if buffs[i] == 0: continue
		match i:
			BURN:
				# 爆燃
				if p_buffs[PlayerBuffs.FIRE_EXPLODE] > 0 and buffs[BURN] >= 3:
					fire_explore.emit()
					burn_timers.clear()
					buffs[BURN] = 0
					continue
				# 灼烧扣血
				for j in range(burn_timers.size() - 1, -1, -1):
					# 处理计时器
					var timer = burn_timers[j]
					timer["total"] -= delta
					timer["tick"] -= delta
					# 每隔1s结算1次伤害
					if timer["tick"] <= 0:
						stats.settle_hp(5.0 + p_buffs[PlayerBuffs.FIRE_DOT_LEVEL_1] * 5.0 + p_buffs[PlayerBuffs.FIRE_DOT_LEVEL_2] * 5.0 + p_buffs[PlayerBuffs.FIRE_DOT_LEVEL_3] * 10.0)
						timer["tick"] += 1.0
					# 灼烧结束后移除
					if timer["total"] <= 0:
						burn_timers.remove_at(j)
						buffs[BURN] -= 1
			KNOCK_BACK:
				knock_back.emit(300.0 + 60.0 * p_buffs[PlayerBuffs.STONE_KB_LEVEL_1] + 100.0 * p_buffs[PlayerBuffs.STONE_KB_LEVEL_2] + 160.0 * p_buffs[PlayerBuffs.STONE_KB_LEVEL_3])
				buffs[KNOCK_BACK] = 0
			STUN:
				if stun_timer <= 0:
					stun_timer = 0.5 + 0.2 * p_buffs[PlayerBuffs.STONE_STUN]
				else:
					stun_timer -= delta
					if stun_timer <= 0: buffs[STUN] = 0
			ICE:
				# 冻结 
				if p_buffs[PlayerBuffs.ICE_FREEZE] > 0 and buffs[ICE] >= 5:
					buffs[FREEZE] = 1
					ice_timers.clear()
					buffs[ICE] = 0
					continue
				# 处理计时器
				for j in range(ice_timers.size() - 1, -1, -1):
					ice_timers[j] -= delta
					if ice_timers[j] <= 0:
						ice_timers.remove_at(j)
						buffs[ICE] -= 1
				# 减速
				stats.move_speed *= max(0.1, 1.0 - ice_timers.size() * (0.1 + 0.02 * p_buffs[PlayerBuffs.ICE_SLOW_LEVEL_3]))
			FREEZE:
				ice_timers.clear()
				buffs[ICE] = 0
				if freeze_timer <= 0:
					freeze_timer = 2.0 + 0.5 * p_buffs[PlayerBuffs.ICE_FREEZE]
				else:
					freeze_timer -= delta
					if freeze_timer <= 0: buffs[FREEZE] = 0
			WOOD_TREANT_TAG:
				if treant_timer <= 0:
					treant_timer = 0.5
				else:
					treant_timer -= delta
					if treant_timer <= 0: buffs[WOOD_TREANT_TAG] = 0
			ICE_EXPLOSION:
				if buffs[FREEZE] > 0:
					ice_explore.emit()
					freeze_timer = 0.0
					buffs[FREEZE] = 0
				buffs[ICE_EXPLOSION] = 0
			EXECUTE:
				stats.settle_hp(stats.hp)

# 添加灼烧（上限3层）
func add_burn() -> void:
	if burn_timers.size() >= 3: return
	burn_timers.append({
		"total": 3.0 + p_buffs[PlayerBuffs.FIRE_DOT_LEVEL_2] + 2 * p_buffs[PlayerBuffs.FIRE_DOT_LEVEL_3],
		"tick": 1.0
	})
	buffs[BURN] = burn_timers.size()

# 添加减速（上限5层）
func add_ice() -> void:
	if ice_timers.size() >= 5: return
	ice_timers.append(3.0 + p_buffs[PlayerBuffs.ICE_SLOW_LEVEL_1] + 1.5 * p_buffs[PlayerBuffs.ICE_SLOW_LEVEL_2] + 2.0 * p_buffs[PlayerBuffs.ICE_SLOW_LEVEL_3])
	buffs[ICE] = ice_timers.size()
