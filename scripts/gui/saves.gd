extends Control

const SAVE_PATH = "res://saves/"

signal profile_selected(profile: PlayerProfile)


func _ready() -> void:
	DirAccess.make_dir_absolute(SAVE_PATH)


# 选择存档
func select_slot(slot: int) -> void:
	var path = SAVE_PATH + "save%d" % slot
	
	# 存在存档就载入，否侧创建
	var profile = PlayerProfile.new()
	profile.save_slot = slot
	if FileAccess.file_exists(path):
		profile.load_from_file(path)
	else:
		profile.save_to_file(path)

	profile.rebuild_stats_from_meta()
		
	profile_selected.emit(profile)


func _on_save_1_pressed() -> void:
	select_slot(1)

func _on_save_2_pressed() -> void:
	select_slot(2)

func _on_save_3_pressed() -> void:
	select_slot(3)


func _on_help_button_pressed():
	$HelpPanel.visible = true


func _on_close_button_pressed() -> void:
	$HelpPanel.visible = false
