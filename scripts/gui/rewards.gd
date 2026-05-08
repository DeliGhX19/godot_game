extends CanvasLayer

@onready var label_containers = [
	$HBoxContainer/Reward1/VBoxContainer,
	$HBoxContainer/Reward2/VBoxContainer,
	$HBoxContainer/Reward3/VBoxContainer
]
@onready var name_labels: Array[Label] = [
	$HBoxContainer/Reward1/VBoxContainer/NameLabel,
	$HBoxContainer/Reward2/VBoxContainer/NameLabel,
	$HBoxContainer/Reward3/VBoxContainer/NameLabel
]
@onready var desc_labels: Array[Label] = [
	$HBoxContainer/Reward1/VBoxContainer/DescLabel,
	$HBoxContainer/Reward2/VBoxContainer/DescLabel,
	$HBoxContainer/Reward3/VBoxContainer/DescLabel
]

const RARITY_COLORS: Dictionary = {
	0: Color.GREEN,              # 普通 绿色
	1: Color.BLUE,               # 稀有 蓝色
	2: Color(1.0, 0.843, 0.0), # 罕见 金色
	3: Color.RED,                # 特殊 红色
}

var base_name_labels_size: float = 12.0
var base_desc_labels_size: float = 15.0
var base_separation: float = 18
var reference_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

var rewards: Array[Reward]


func _ready() -> void:
	visible = false
	get_viewport().size_changed.connect(_update_font_sizes)
	_update_font_sizes()


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
		name_labels[i].text = r.name
		name_labels[i].add_theme_color_override("font_color", RARITY_COLORS[r.rarity])
		desc_labels[i].text = r.desc
		desc_labels[i].add_theme_color_override("font_color", RARITY_COLORS[r.rarity])

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

func _update_font_sizes() -> void:
	var viewport_height = get_viewport().get_visible_rect().size.y
	var scale_factor = viewport_height / reference_height
	
	for label_container in label_containers:
		label_container.add_theme_constant_override("separation", int(base_separation * scale_factor))
	for label in name_labels:
		label.add_theme_font_size_override("font_size", base_name_labels_size * scale_factor)
	for label in desc_labels:
		label.add_theme_font_size_override("font_size", base_desc_labels_size * scale_factor)
