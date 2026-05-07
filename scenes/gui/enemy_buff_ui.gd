extends Control

var enemy

var buff_icon_scene = preload("res://scenes/gui/buff_icon.tscn")

var burn_texture = preload("res://assets/ui/fire_buff.png")
var ice_texture = preload("res://assets/ui/ice_buff.png"
)

@onready var burn_row = $VBoxContainer/BurnRow
@onready var ice_row = $VBoxContainer/IceRow


func initialize(target_enemy):
	enemy = target_enemy


func _process(_delta):
	if enemy == null:
		return
	
	update_buffs()


func update_buffs():
	clear_row(burn_row)
	clear_row(ice_row)

	# 灼烧层数
	var burn_count = enemy.buffs.buffs[EnemyBuffs.BURN]

	for i in range(burn_count):
		var icon = buff_icon_scene.instantiate()
		icon.texture = burn_texture
		burn_row.add_child(icon)

	# 寒冷层数
	var ice_count = enemy.buffs.buffs[EnemyBuffs.ICE]

	for i in range(ice_count):
		var icon = buff_icon_scene.instantiate()
		icon.texture = ice_texture
		ice_row.add_child(icon)


func clear_row(row):
	for child in row.get_children():
		child.queue_free()
