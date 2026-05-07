class_name EnemyBuffs

const BURN = 0                # 火焰灼烧（基础：5dmg/s 3s）
const KNOCK_BACK = 1          # 击退（基础：300）
const STUN = 2                # 眩晕（基础：0.5s）
const FREEZE = 3              # 冻结（基础：2s）
const ICE = 4                 # 减速（基础：-10%速度） 
const WOOD_TREANT_TAG = 5     # 傀儡标记（0.5s标记 20%生成傀儡）
const ICE_EXPLOSION = 6       # 冰爆
const EXECUTE = 7             # 秒杀
const ENVIRONMENT_FIRE = 8      # 灼热荒庭（火属性+50% 冰属性-50% 灼伤额外1%扣血）
const ENVIRONMENT_WATER = 9    # 沉水渊狱（雷属性+50% 火属性-50%）
const ENVIRONMENT_WIND = 10     # 风动高台（移动受到风向影响）
const ENVIRONMENT_GRAVITY = 11  # 重压深室（重力增加 物理攻击+50% 石元素+50%）
const ENVIRONMENT_DARK = 12     # 幽暗秘阁（暴击率+0.25）
const ENVIRONMENT_WINTER = 13   # 极寒雪冢（冰属性+50% 火属性-25%）
const ENVIRONMENT_FROG = 14     # 迷雾遗墟（木属性+100%）
const ENVIRONMENT_HELL = 15     # 血狱修罗（被攻击就会死亡）
const BUFF_COUNT = 16
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
						if buffs[ENVIRONMENT_FIRE]:
							stats.settle_hp(0.01 * stats.max_hp)
						timer["tick"] += 1.0
					# 灼烧结束后移除
					if timer["total"] <= 0:
						burn_timers.remove_at(j)
						buffs[BURN] -= 1
			KNOCK_BACK:
				var knock_val = 150.0 + 50.0 * p_buffs[PlayerBuffs.STONE_KB_LEVEL_1] + 70.0 * p_buffs[PlayerBuffs.STONE_KB_LEVEL_2] + 100.0 * p_buffs[PlayerBuffs.STONE_KB_LEVEL_3]
				if  buffs[ENVIRONMENT_GRAVITY]: knock_val += 100.0
				knock_back.emit(knock_val)
				buffs[KNOCK_BACK] = 0
			STUN:
				if stun_timer <= 0:
					stun_timer = 0.5 + 0.2 * p_buffs[PlayerBuffs.STONE_STUN]
					if buffs[ENVIRONMENT_GRAVITY]: stun_timer += 0.5
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
					if buffs[ENVIRONMENT_WINTER] > 0: freeze_timer += 1.0
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
			ENVIRONMENT_FIRE:
				stats.base_damages[GameManager.TYPE_FIRE] *= 1.5
				stats.base_damages[GameManager.TYPE_ICE] *= 0.5
			ENVIRONMENT_WATER:
				stats.base_damages[GameManager.TYPE_LIGHTNING] *= 1.5
				stats.base_damages[GameManager.TYPE_FIRE] *= 0.5
			ENVIRONMENT_WIND:
				stats.move_speed += cos(GameManager.wind_angle) * 100
			ENVIRONMENT_GRAVITY:
				stats.base_damages[GameManager.TYPE_STONE] *= 1.5
				stats.base_damages[GameManager.TYPE_PHYSIC] *= 1.5
			ENVIRONMENT_DARK:
				stats.crit_rate += 0.25
			ENVIRONMENT_WINTER:
				stats.base_damages[GameManager.TYPE_ICE] *= 1.5
				stats.base_damages[GameManager.TYPE_FIRE] *= 0.75
			ENVIRONMENT_FROG:
				stats.base_damages[GameManager.TYPE_WOOD] *= 2
			ENVIRONMENT_HELL:
				for j in range(GameManager.TYPE_COUNT):
					if stats.receiving_damages[j] > 0:
						stats.settle_hp(stats.hp)
						continue

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
