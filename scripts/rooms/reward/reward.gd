class_name Reward

var name: String       # 名字
var desc: String       # 描述
var effect: Callable   # 效果
var weight: int        # 权重
var rarity: int        # 稀有度（0-普通 1-稀有 2-罕见 3-特殊）
var count: int         # 获取数量(-1表示特殊奖励)



func _init(_name: String, _desc: String, _weight: int, _effect: Callable, _rarity: int, _count: int = 0):
	name = _name
	desc = _desc
	weight = _weight
	effect = _effect
	rarity = _rarity
	count = _count


# 动态权重
func get_dynamic_weight() -> float:
	if count == -2: return 0
	elif count == -1: return weight
	else: return weight * (5.0 / (count + 5.0))

# 执行该奖励
func execute(player: CharacterBody2D):
	effect.call(player)
	if count >= 0: count += 1
	elif count == -1: count = -2
