extends CanvasLayer

@onready var hp_bar: ProgressBar = $Control/ProgressBar
@onready var hp_label: Label = $Control/Label
@onready var scene_title_ui = $SceneTitleUI


func initialize(player: CharacterBody2D) -> void:
	player.display_hp.connect(_on_display_hp)


func _on_display_hp(hp: float, max_hp: float):
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = str(int(hp)) + " / " + str(int(max_hp))
