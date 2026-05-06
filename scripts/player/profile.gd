class_name PlayerProfile

const SAVE_PATH := "res://saves/"

const BASE_MAX_HP := 100.0
const BASE_MOVE_SPEED := 400.0
const BASE_JUMP_HEIGHT := 800.0
const BASE_CRIT_RATE := 0.0
const BASE_DAMAGE_REDUCTION := 0.0

const HP_UPGRADE_STEP := 10.0
const MOVE_SPEED_UPGRADE_STEP := 8.0
const JUMP_UPGRADE_STEP := 20.0
const CRIT_UPGRADE_STEP := 0.01
const DR_UPGRADE_STEP := 0.005

var meta_currency: int = 0

var hp_upgrade_level: int = 0
var move_speed_upgrade_level: int = 0
var jump_upgrade_level: int = 0
var crit_upgrade_level: int = 0
var dr_upgrade_level: int = 0

var max_hp: float = BASE_MAX_HP
var move_speed: float = BASE_MOVE_SPEED
var jump_height: float = BASE_JUMP_HEIGHT
var crit_rate: float = BASE_CRIT_RATE
var damage_reduction: float = BASE_DAMAGE_REDUCTION
var save_slot: int = 0


func _init() -> void:
	rebuild_stats_from_meta()


func rebuild_stats_from_meta() -> void:
	max_hp = BASE_MAX_HP + hp_upgrade_level * HP_UPGRADE_STEP
	move_speed = BASE_MOVE_SPEED + move_speed_upgrade_level * MOVE_SPEED_UPGRADE_STEP
	jump_height = BASE_JUMP_HEIGHT + jump_upgrade_level * JUMP_UPGRADE_STEP
	crit_rate = BASE_CRIT_RATE + crit_upgrade_level * CRIT_UPGRADE_STEP
	damage_reduction = BASE_DAMAGE_REDUCTION + dr_upgrade_level * DR_UPGRADE_STEP


func get_meta_data_dict() -> Dictionary:
	return {
		"meta_currency": meta_currency,
		"hp_upgrade_level": hp_upgrade_level,
		"move_speed_upgrade_level": move_speed_upgrade_level,
		"jump_upgrade_level": jump_upgrade_level,
		"crit_upgrade_level": crit_upgrade_level,
		"dr_upgrade_level": dr_upgrade_level,
		"save_slot": save_slot
	}


func apply_meta_data(data: Dictionary) -> void:
	meta_currency = int(data.get("meta_currency", meta_currency))
	hp_upgrade_level = int(data.get("hp_upgrade_level", hp_upgrade_level))
	move_speed_upgrade_level = int(data.get("move_speed_upgrade_level", move_speed_upgrade_level))
	jump_upgrade_level = int(data.get("jump_upgrade_level", jump_upgrade_level))
	crit_upgrade_level = int(data.get("crit_upgrade_level", crit_upgrade_level))
	dr_upgrade_level = int(data.get("dr_upgrade_level", dr_upgrade_level))
	save_slot = int(data.get("save_slot", save_slot))
	rebuild_stats_from_meta()


func get_save_file_path() -> String:
	return SAVE_PATH + "save%d" % save_slot


func save() -> void:
	if save_slot <= 0:
		return
	save_to_file(get_save_file_path())


func save_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(get_meta_data_dict()))
	file.close()


func load_from_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var raw_data = JSON.parse_string(file.get_as_text())
	file.close()

	if raw_data is Dictionary:
		if raw_data.has("meta_currency") or raw_data.has("hp_upgrade_level"):
			apply_meta_data(raw_data)
			return
		meta_currency = 0
		hp_upgrade_level = 0
		move_speed_upgrade_level = 0
		jump_upgrade_level = 0
		crit_upgrade_level = 0
		dr_upgrade_level = 0
		rebuild_stats_from_meta()
	else:
		rebuild_stats_from_meta()
