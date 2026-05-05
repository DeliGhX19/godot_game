class_name RewardManager

# 基础池
var basic_pool: Array[Reward] = [
	Reward.new("纳气", "*0.2角色最大生命值上限", 100, func(player): player.buffs.buffs[PlayerBuffs.HP_LEVEL_1] += 1)
]

# 稀有池
var rare_pool: Array[Reward] = [
	Reward.new("固本", "*0.2角色最大生命值上限", 100, func(player): player.buffs.buffs[PlayerBuffs.HP_LEVEL_1] += 1)
]

# 罕见池
var epic_pool: Array[Reward] = [
	Reward.new("培元", "*0.5角色最大生命值上限", 100, func(player): player.buffs.buffs[PlayerBuffs.HP_LEVEL_3] += 1)
]

# 特殊池（仅能抽出一次）
var special_pool: Array[Reward] = [
	Reward.new("炎爆", "火元素：攻击时有15%几率释放炎爆术，造成范围伤害并施加3层灼伤", 100, func(player): player.buffs.buffs[PlayerBuffs.FIRE_ERUPTION] = 1, -1),
	Reward.new("傀儡", "木元素：击杀敌人时有20%基类生成生命之火，对范围内的玩家提供增益", 100, func(player): player.buffs.buffs[PlayerBuffs.WOOD_TREANT] = 1, -1),
	Reward.new("陨星", "石元素：攻击时有15%几率召唤陨星，造成范围伤害并施加眩晕", 100, func(player): player.buffs.buffs[PlayerBuffs.STONE_METEOR] = 1, -1),
	Reward.new("冰爆", "冰元素：对冰冻的敌人有25%释放冰爆，造成范围攻击并冻结周围的敌人", 100, func(player): player.buffs.buffs[PlayerBuffs.ICE_EXPLORE] = 1, -1),
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
