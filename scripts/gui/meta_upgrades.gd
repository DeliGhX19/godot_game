extends CanvasLayer

const META_UPGRADES_SCRIPT = preload("res://scripts/meta/meta_upgrades.gd")

@onready var currency_label: Label = $Panel/VBoxContainer/CurrencyLabel
@onready var summary_label: Label = $Panel/VBoxContainer/SummaryLabel
@onready var hp_button: Button = $Panel/VBoxContainer/HPButton
@onready var move_speed_button: Button = $Panel/VBoxContainer/MoveSpeedButton
@onready var jump_button: Button = $Panel/VBoxContainer/JumpButton
@onready var crit_button: Button = $Panel/VBoxContainer/CritButton
@onready var dr_button: Button = $Panel/VBoxContainer/DRButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

var meta_upgrades = META_UPGRADES_SCRIPT.new()
var profile: PlayerProfile
var opened: bool = false


func _ready() -> void:
	visible = false


func initialize(target_profile: PlayerProfile) -> void:
	profile = target_profile
	refresh()


func open(target_profile: PlayerProfile) -> void:
	profile = target_profile
	opened = true
	visible = true
	refresh()


func close() -> void:
	opened = false
	visible = false


func is_open() -> bool:
	return opened


func _unhandled_input(event: InputEvent) -> void:
	if not opened:
		return
	if event.is_action_pressed("ui_cancel"):
		close()


func refresh() -> void:
	if profile == null:
		return

	profile.rebuild_stats_from_meta()
	currency_label.text = "Meta Currency: %d" % profile.meta_currency
	summary_label.text = "HP %.0f | Move %.0f | Jump %.0f | Crit %.2f | DR %.3f" % [
		profile.max_hp,
		profile.move_speed,
		profile.jump_height,
		profile.crit_rate,
		profile.damage_reduction
	]

	_update_button(hp_button, meta_upgrades.get_name(meta_upgrades.UPGRADE_HP), meta_upgrades.UPGRADE_HP)
	_update_button(move_speed_button, meta_upgrades.get_name(meta_upgrades.UPGRADE_MOVE_SPEED), meta_upgrades.UPGRADE_MOVE_SPEED)
	_update_button(jump_button, meta_upgrades.get_name(meta_upgrades.UPGRADE_JUMP), meta_upgrades.UPGRADE_JUMP)
	_update_button(crit_button, meta_upgrades.get_name(meta_upgrades.UPGRADE_CRIT), meta_upgrades.UPGRADE_CRIT)
	_update_button(dr_button, meta_upgrades.get_name(meta_upgrades.UPGRADE_DR), meta_upgrades.UPGRADE_DR)


func _update_button(button: Button, title: String, upgrade_id: String) -> void:
	var level = profile.get_upgrade_level(upgrade_id)
	var max_level = profile.get_upgrade_max_level(upgrade_id)
	if level >= max_level:
		button.text = "%s Lv.%d | %s | Max" % [
			title,
			level,
			profile.get_upgrade_display_text(upgrade_id)
		]
		button.disabled = true
		return

	var cost = profile.get_upgrade_cost(upgrade_id)
	button.text = "%s Lv.%d | %s | Cost %d" % [
		title,
		level,
		profile.get_upgrade_display_text(upgrade_id),
		cost
	]
	button.disabled = profile.meta_currency < cost


func _buy_upgrade(upgrade_id: String) -> void:
	if profile.purchase_upgrade(upgrade_id):
		refresh()


func _on_hp_button_pressed() -> void:
	_buy_upgrade(meta_upgrades.UPGRADE_HP)


func _on_move_speed_button_pressed() -> void:
	_buy_upgrade(meta_upgrades.UPGRADE_MOVE_SPEED)


func _on_jump_button_pressed() -> void:
	_buy_upgrade(meta_upgrades.UPGRADE_JUMP)


func _on_crit_button_pressed() -> void:
	_buy_upgrade(meta_upgrades.UPGRADE_CRIT)


func _on_dr_button_pressed() -> void:
	_buy_upgrade(meta_upgrades.UPGRADE_DR)


func _on_close_button_pressed() -> void:
	close()
