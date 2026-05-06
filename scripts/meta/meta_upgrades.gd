class_name MetaUpgrades

const UPGRADE_HP := "hp"
const UPGRADE_MOVE_SPEED := "move_speed"
const UPGRADE_JUMP := "jump"
const UPGRADE_CRIT := "crit"
const UPGRADE_DR := "dr"

const ORDER := [
	UPGRADE_HP,
	UPGRADE_MOVE_SPEED,
	UPGRADE_JUMP,
	UPGRADE_CRIT,
	UPGRADE_DR,
]

const CONFIG := {
	UPGRADE_HP: {
		"name": "HP",
		"base": 100.0,
		"step": 10.0,
		"max_level": 10,
		"cost_base": 5,
		"cost_step": 3,
		"decimals": 0,
	},
	UPGRADE_MOVE_SPEED: {
		"name": "Move Speed",
		"base": 400.0,
		"step": 8.0,
		"max_level": 10,
		"cost_base": 5,
		"cost_step": 3,
		"decimals": 0,
	},
	UPGRADE_JUMP: {
		"name": "Jump",
		"base": 800.0,
		"step": 20.0,
		"max_level": 10,
		"cost_base": 4,
		"cost_step": 3,
		"decimals": 0,
	},
	UPGRADE_CRIT: {
		"name": "Crit Rate",
		"base": 0.0,
		"step": 0.01,
		"max_level": 10,
		"cost_base": 8,
		"cost_step": 4,
		"decimals": 2,
	},
	UPGRADE_DR: {
		"name": "Damage Reduction",
		"base": 0.0,
		"step": 0.005,
		"max_level": 10,
		"cost_base": 10,
		"cost_step": 5,
		"decimals": 3,
	},
}


static func get_config(upgrade_id: String) -> Dictionary:
	return CONFIG.get(upgrade_id, {})


static func get_name(upgrade_id: String) -> String:
	return str(get_config(upgrade_id).get("name", upgrade_id))


static func get_base(upgrade_id: String) -> float:
	return float(get_config(upgrade_id).get("base", 0.0))


static func get_step(upgrade_id: String) -> float:
	return float(get_config(upgrade_id).get("step", 0.0))


static func get_max_level(upgrade_id: String) -> int:
	return int(get_config(upgrade_id).get("max_level", 0))


static func get_cost(upgrade_id: String, level: int) -> int:
	var cfg = get_config(upgrade_id)
	return int(cfg.get("cost_base", 999999)) + level * int(cfg.get("cost_step", 0))


static func get_value_at_level(upgrade_id: String, level: int) -> float:
	return get_base(upgrade_id) + level * get_step(upgrade_id)


static func format_value(upgrade_id: String, value: float) -> String:
	var decimals = int(get_config(upgrade_id).get("decimals", 0))
	return "%.*f" % [decimals, value]


static func get_display_text(upgrade_id: String, level: int) -> String:
	var current_value = get_value_at_level(upgrade_id, level)
	var next_value = get_value_at_level(upgrade_id, level + 1)
	return "%s %s -> %s" % [
		get_name(upgrade_id),
		format_value(upgrade_id, current_value),
		format_value(upgrade_id, next_value)
	]
