class_name PlayerProfile

const SAVE_PATH := "res://saves/"
const META_UPGRADES_SCRIPT := preload("res://scripts/meta/meta_upgrades.gd")

var meta_upgrades = META_UPGRADES_SCRIPT.new()
var meta_currency: int = 0

var hp_upgrade_level: int = 0
var move_speed_upgrade_level: int = 0
var jump_upgrade_level: int = 0
var crit_upgrade_level: int = 0
var dr_upgrade_level: int = 0

var max_hp: float = 100.0
var move_speed: float = 400.0
var jump_height: float = 800.0
var crit_rate: float = 0.0
var damage_reduction: float = 0.0
var save_slot: int = 0


func _init() -> void:
	max_hp = meta_upgrades.get_base(meta_upgrades.UPGRADE_HP)
	move_speed = meta_upgrades.get_base(meta_upgrades.UPGRADE_MOVE_SPEED)
	jump_height = meta_upgrades.get_base(meta_upgrades.UPGRADE_JUMP)
	crit_rate = meta_upgrades.get_base(meta_upgrades.UPGRADE_CRIT)
	damage_reduction = meta_upgrades.get_base(meta_upgrades.UPGRADE_DR)
	rebuild_stats_from_meta()


func rebuild_stats_from_meta() -> void:
	max_hp = meta_upgrades.get_value_at_level(meta_upgrades.UPGRADE_HP, hp_upgrade_level)
	move_speed = meta_upgrades.get_value_at_level(meta_upgrades.UPGRADE_MOVE_SPEED, move_speed_upgrade_level)
	jump_height = meta_upgrades.get_value_at_level(meta_upgrades.UPGRADE_JUMP, jump_upgrade_level)
	crit_rate = meta_upgrades.get_value_at_level(meta_upgrades.UPGRADE_CRIT, crit_upgrade_level)
	damage_reduction = meta_upgrades.get_value_at_level(meta_upgrades.UPGRADE_DR, dr_upgrade_level)


func get_upgrade_level(upgrade_id: String) -> int:
	match upgrade_id:
		meta_upgrades.UPGRADE_HP:
			return hp_upgrade_level
		meta_upgrades.UPGRADE_MOVE_SPEED:
			return move_speed_upgrade_level
		meta_upgrades.UPGRADE_JUMP:
			return jump_upgrade_level
		meta_upgrades.UPGRADE_CRIT:
			return crit_upgrade_level
		meta_upgrades.UPGRADE_DR:
			return dr_upgrade_level
		_:
			return 0


func set_upgrade_level(upgrade_id: String, value: int) -> void:
	match upgrade_id:
		meta_upgrades.UPGRADE_HP:
			hp_upgrade_level = value
		meta_upgrades.UPGRADE_MOVE_SPEED:
			move_speed_upgrade_level = value
		meta_upgrades.UPGRADE_JUMP:
			jump_upgrade_level = value
		meta_upgrades.UPGRADE_CRIT:
			crit_upgrade_level = value
		meta_upgrades.UPGRADE_DR:
			dr_upgrade_level = value


func get_upgrade_max_level(upgrade_id: String) -> int:
	return meta_upgrades.get_max_level(upgrade_id)


func get_upgrade_cost(upgrade_id: String) -> int:
	return meta_upgrades.get_cost(upgrade_id, get_upgrade_level(upgrade_id))


func can_purchase_upgrade(upgrade_id: String) -> bool:
	var level := get_upgrade_level(upgrade_id)
	if level >= get_upgrade_max_level(upgrade_id):
		return false
	return meta_currency >= get_upgrade_cost(upgrade_id)


func purchase_upgrade(upgrade_id: String) -> bool:
	if not can_purchase_upgrade(upgrade_id):
		return false

	meta_currency -= get_upgrade_cost(upgrade_id)
	set_upgrade_level(upgrade_id, get_upgrade_level(upgrade_id) + 1)
	rebuild_stats_from_meta()
	save()
	return true


func get_upgrade_display_text(upgrade_id: String) -> String:
	return meta_upgrades.get_display_text(upgrade_id, get_upgrade_level(upgrade_id))


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
