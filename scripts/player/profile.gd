class_name PlayerProfile

var max_hp: float = 100.0           # 生命上限
var move_speed: float = 400.0       # 移动速度
var jump_height: float = 800.0      # 跳跃高度
var crit_rate: float = 0.0          # 暴击率
var damage_reduction: float = 0.0   # 减伤率


# 创建存档或保存存档
func save_to_file(path: String) -> void:
	var data = {
		"max_hp": max_hp,
		"move_speed": move_speed,
		"jump_height": jump_height,
		"crit_rate": crit_rate,
		"damage_reduction": damage_reduction
	}
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

# 读取存档
func load_from_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	max_hp = data.get("max_hp", max_hp)
	move_speed = data.get("move_speed", move_speed)
	jump_height = data.get("jump_height", jump_height)
	crit_rate = data.get("crit_rate", crit_rate)
	damage_reduction = data.get("damage_reduction", damage_reduction)
