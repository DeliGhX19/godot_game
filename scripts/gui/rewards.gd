extends CanvasLayer

@onready var cards = [$HBoxContainer/Reward1, $HBoxContainer/Reward2, $HBoxContainer/Reward3]

var rewards: Array[Reward]


func _ready() -> void:
	visible = false


# 打开奖励页面
func open_reward_gui(tier_name: String):
	# 暂停游戏
	get_tree().paused = true
	visible = true
	
	# 生成奖励
	rewards.clear()
	match tier_name:
		"basic": rewards = GameManager.reward_manager.roll_basic_tier()
		"advanced": rewards = GameManager.reward_manager.roll_advanced_tier()
		"ultimate": rewards = GameManager.reward_manager.roll_ultimate_tier()
	
	# 展示GUI
	for i in range(3):
		var r = rewards[i]
		var btn = cards[i]
		btn.get_node("VBoxContainer/NameLabel").text = r.name
		btn.get_node("VBoxContainer/DescLabel").text = r.desc

# 选择奖励
func select_reward(index: int):
	if not visible: return
	
	var player = GameManager.player
	rewards[index].execute(player)
	
	visible = false
	get_tree().paused = false


func _on_reward_1_pressed() -> void:
	select_reward(0)

func _on_reward_2_pressed() -> void:
	select_reward(1)

func _on_reward_3_pressed() -> void:
	select_reward(2)
