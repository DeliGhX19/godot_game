class_name RewardManager

# 基础池
var basic_pool: Array[Reward] = [
	Reward.new("纳气", "*1.1角色最大生命值上限", 150, func(player): player.buffs.add_hp_buff(1, player.stats)),
	Reward.new("微步", "+25移动速度", 150, func(player): player.buffs.buffs[PlayerBuffs.SPEED_LEVEL_1] += 1),
	Reward.new("铜皮", "+0.0125减伤", 150, func(player): player.buffs.buffs[PlayerBuffs.DR_LEVEL_1] += 1),
	Reward.new("入神", "+0.025暴击率", 150, func(player): player.buffs.buffs[PlayerBuffs.CRIT_LEVEL_1] += 1),
	Reward.new("聚星", "*1.15远程伤害", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_DMG_LEVEL_1] += 1),
	Reward.new("惊鸿", "+0.15施法速度", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_SPD_LEVEL_1] += 1),
	Reward.new("燕返", "+0.2攻击距离", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_RANGE_LEVEL_1] += 1),
	Reward.new("洞石", "+1穿透次数", 10, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_PIERCE] += 1),
	Reward.new("星火", "火元素：+5灼烧伤害", 100, func(player): player.buffs.buffs[PlayerBuffs.FIRE_DOT_LEVEL_1] += 1),
	Reward.new("回春", "木元素：+0.1%生命上限恢复", 100, func(player): player.buffs.buffs[PlayerBuffs.WOOD_HEAL_LEVEL_1] += 1),
	Reward.new("沉沙", "石元素：+50击退", 100, func(player): player.buffs.buffs[PlayerBuffs.STONE_KB_LEVEL_1] += 1),
	Reward.new("流霜", "冰元素：+1s寒冷持续时间", 100, func(player): player.buffs.buffs[PlayerBuffs.ICE_SLOW_LEVEL_1] += 1),
	Reward.new("惊雷", "雷元素：*1.1连锁雷伤害", 100, func(player): player.buffs.buffs[PlayerBuffs.LIGHTNING_LEVEL_1] += 1),
	Reward.new("爆燃", "火元素：灼烧层数>3时引爆敌人，造成范围伤害，每层*1.1爆炸伤害", 20, func(player): player.buffs.buffs[PlayerBuffs.FIRE_EXPLODE] += 1),
	Reward.new("转换", "木元素：血量全满时溢出治疗转换为增益效果，持续时间3s，每层小幅提高攻击伤害、速度、跳跃高度、减伤率", 20, func(player): player.buffs.buffs[PlayerBuffs.WOOD_CONVERT] += 1),
	Reward.new("眩晕", "石元素：攻击时有20%造成0.5s眩晕，每层+0.2s眩晕", 20, func(player): player.buffs.buffs[PlayerBuffs.STONE_STUN] += 1),
	Reward.new("冻结", "冰元素：寒冷层数>5时引爆，冻结敌人2s，每层+0.5s持续时间", 20, func(player): player.buffs.buffs[PlayerBuffs.ICE_FREEZE] += 1),
	Reward.new("连锁", "雷元素：穿透敌人时生成额外的追踪雷，每层+1生成数", 20, func(player): player.buffs.buffs[PlayerBuffs.LIGHTNING_CHAIN] += 1),
]

# 稀有池
var rare_pool: Array[Reward] = [
	Reward.new("固本", "*1.3角色最大生命值上限", 150, func(player): player.buffs.add_hp_buff(2, player.stats)),
	Reward.new("行风", "+25移动速度 +50跳跃高度", 150, func(player): player.buffs.buffs[PlayerBuffs.SPEED_LEVEL_2] += 1),
	Reward.new("铁骨", "+0.025减伤", 150, func(player): player.buffs.buffs[PlayerBuffs.DR_LEVEL_2] += 1),
	Reward.new("会心", "+0.05暴击率", 150, func(player): player.buffs.buffs[PlayerBuffs.CRIT_LEVEL_2] += 1),
	Reward.new("辉阳", "*1.30远程伤害", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_DMG_LEVEL_2] += 1),
	Reward.new("游龙", "+0.3施法速度", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_SPD_LEVEL_2] += 1),
	Reward.new("追月", "+0.35攻击距离", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_RANGE_LEVEL_2] += 1),
	Reward.new("洞石", "+1穿透次数", 50, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_PIERCE] += 1),
	Reward.new("业火", "火元素：+5灼烧伤害 +1s灼烧持续时间", 100, func(player): player.buffs.buffs[PlayerBuffs.FIRE_DOT_LEVEL_2] += 1),
	Reward.new("蕴木", "木元素：+0.2%生命上限恢复", 100, func(player): player.buffs.buffs[PlayerBuffs.WOOD_HEAL_LEVEL_2] += 1),
	Reward.new("碎岩", "石元素：+70击退", 100, func(player): player.buffs.buffs[PlayerBuffs.STONE_KB_LEVEL_2] += 1),
	Reward.new("凝冰", "冰元素：+1.5s寒冷持续时间", 100, func(player): player.buffs.buffs[PlayerBuffs.ICE_SLOW_LEVEL_2] += 1),
	Reward.new("奔雷", "雷元素：+0.1连锁雷半径 *1.1连锁雷伤害", 100, func(player): player.buffs.buffs[PlayerBuffs.LIGHTNING_LEVEL_2] += 1),
	Reward.new("爆燃", "火元素：灼烧层数>3时引爆敌人，造成范围伤害，每层*1.1爆炸伤害", 80, func(player): player.buffs.buffs[PlayerBuffs.FIRE_EXPLODE] += 1),
	Reward.new("转换", "木元素：血量全满时溢出治疗转换为增益效果，持续时间3s，每层小幅提高攻击伤害、速度、跳跃高度、减伤率", 80, func(player): player.buffs.buffs[PlayerBuffs.WOOD_CONVERT] += 1),
	Reward.new("眩晕", "石元素：攻击时有20%造成0.5s眩晕，每层+0.2s眩晕", 80, func(player): player.buffs.buffs[PlayerBuffs.STONE_STUN] += 1),
	Reward.new("冻结", "冰元素：寒冷层数>5时引爆，冻结敌人2s，每层+0.5s持续时间", 80, func(player): player.buffs.buffs[PlayerBuffs.ICE_FREEZE] += 1),
	Reward.new("连锁", "雷元素：穿透敌人时生成额外的追踪雷，每层+1生成数", 80, func(player): player.buffs.buffs[PlayerBuffs.LIGHTNING_CHAIN] += 1),
]

# 罕见池
var epic_pool: Array[Reward] = [
	Reward.new("培元", "*1.5角色最大生命值上限", 150, func(player): player.buffs.add_hp_buff(3, player.stats)),
	Reward.new("登云", "+50移动速度 +50跳跃高度", 150, func(player): player.buffs.buffs[PlayerBuffs.SPEED_LEVEL_3] += 1),
	Reward.new("金身", "+0.05减伤", 150, func(player): player.buffs.buffs[PlayerBuffs.DR_LEVEL_3] += 1),
	Reward.new("惊天", "+0.075暴击率", 150, func(player): player.buffs.buffs[PlayerBuffs.CRIT_LEVEL_3] += 1),
	Reward.new("曜日", "*1.50远程伤害", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_DMG_LEVEL_3] += 1),
	Reward.new("瞬影", "+0.5施法速度", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_SPD_LEVEL_3] += 1),
	Reward.new("落日", "+0.5攻击距离", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_RANGE_LEVEL_3] += 1),
	Reward.new("洞石", "+1穿透次数", 120, func(player): player.buffs.buffs[PlayerBuffs.MAGIC_PIERCE] += 1),
	Reward.new("焚天", "火元素：+10灼烧伤害 +2s灼烧持续", 100, func(player): player.buffs.buffs[PlayerBuffs.FIRE_DOT_LEVEL_3] += 1),
	Reward.new("万物", "木元素：+0.5%生命上限恢复", 100, func(player): player.buffs.buffs[PlayerBuffs.WOOD_HEAL_LEVEL_3] += 1),
	Reward.new("镇渊", "石元素：+100击退", 100, func(player): player.buffs.buffs[PlayerBuffs.STONE_KB_LEVEL_3] += 1),
	Reward.new("绝寒", "冰元素：+2s寒冷持续时间 +2%每层寒冷减速增益", 100, func(player): player.buffs.buffs[PlayerBuffs.ICE_SLOW_LEVEL_3] += 1),
	Reward.new("闪雷", "雷元素：+0.2连锁雷半径 *1.2连锁雷伤害", 100, func(player): player.buffs.buffs[PlayerBuffs.LIGHTNING_LEVEL_3] += 1),
]

# 特殊池（仅能抽出一次）
var special_pool: Array[Reward] = [
	Reward.new("炎爆", "火元素：攻击时有15%几率释放炎爆术，造成范围伤害并施加3层灼伤", 100, func(player): player.buffs.buffs[PlayerBuffs.FIRE_ERUPTION] = 1, -1),
	Reward.new("傀儡", "木元素：击杀敌人时有20%几率生成生命之火，对范围内的玩家提供增益", 100, func(player): player.buffs.buffs[PlayerBuffs.WOOD_TREANT] = 1, -1),
	Reward.new("陨星", "石元素：攻击时有15%几率召唤陨星，造成范围伤害并施加眩晕", 100, func(player): player.buffs.buffs[PlayerBuffs.STONE_METEOR] = 1, -1),
	Reward.new("冰爆", "冰元素：对冰冻的敌人有25%几率释放冰爆，造成范围攻击并冻结周围的敌人", 100, func(player): player.buffs.buffs[PlayerBuffs.ICE_EXPLORE] = 1, -1),
	Reward.new("毁灭", "雷元素：攻击时有15%几率秒杀一名敌人", 100, func(player): player.buffs.buffs[PlayerBuffs.LIGHTNING_DISASTER] = 1, -1)
]


# 抽取奖励
func roll(pool: Array[Reward]) -> Reward:
	var total_weight: float = 0.0
	for res in pool: total_weight += res.get_dynamic_weight()
	
	var roll_value: float = randf() * total_weight
	var current_sum: float = 0.0
	for res in pool:
		current_sum += res.get_dynamic_weight()
		if roll_value <= current_sum:
			return res
	return pool.back()

# 特殊池是否还有奖励
func is_special_pool_available(pool: Array[Reward]) -> bool:
	for r in pool:
		if r.get_dynamic_weight() > 0: 
			return true
	return false

# 从混池中抽取奖励
func roll_with_probs(probs: Dictionary) -> Reward:
	var roll_val = randf()
	var cumulative_prob = 0.0
	for pool in probs:
		cumulative_prob += probs[pool]
		if roll_val <= cumulative_prob:
			return roll(pool)
	
	return roll(probs.keys()[0])



# 基础奖励：[100%基础, 75%基础/20%稀有/5%罕见, 50%基础/40%稀有/10%罕见]
func roll_basic_tier() -> Array[Reward]:
	return [
		roll(basic_pool),
		roll_with_probs({basic_pool: 0.75, rare_pool: 0.20, epic_pool: 0.05}),
		roll_with_probs({basic_pool: 0.50, rare_pool: 0.40, epic_pool: 0.10})
	]

# 高级奖励：[50%基础/50%稀有, 50%基础/35%稀有/15%罕见, 70%稀有/25%罕见/5%特殊]
func roll_advanced_tier() -> Array[Reward]:
	return [
		roll_with_probs({basic_pool: 0.50, rare_pool: 0.50}),
		roll_with_probs({basic_pool: 0.50, rare_pool: 0.35, epic_pool: 0.15}),
		roll_with_probs({rare_pool: 0.70, epic_pool: 0.25, special_pool: 0.05})
	]

# 顶级奖励：[100%稀有, 65%稀有/35%罕见, 100%特殊(若空则50%稀有/50%罕见)]
func roll_ultimate_tier() -> Array[Reward]:
	var r1 = roll(rare_pool)
	var r2 = roll_with_probs({rare_pool: 0.65, epic_pool: 0.35})
	var r3: Reward
	
	if is_special_pool_available(special_pool):
		r3 = roll(special_pool)
	else:
		r3 = roll_with_probs({rare_pool: 0.50, epic_pool: 0.50})
	
	return [r1, r2, r3]
