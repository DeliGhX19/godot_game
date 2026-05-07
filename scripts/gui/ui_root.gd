extends CanvasLayer

@onready var hp_bar: ProgressBar = $Control/ProgressBar
@onready var hp_label: Label = $Control/Label

var player

func initialize(p):
	player = p
	
	# 初始化
	update_hp_display()
	
	# 监听血量变化
	player.stats.hp_changed.connect(_on_hp_changed)


func _on_hp_changed():
	update_hp_display()


func update_hp_display():
	var hp = player.stats.hp
	var max_hp = player.stats.max_hp
	
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	
	# 显示为 xx / xx
	hp_label.text = str(int(hp)) + " / " + str(int(max_hp))
