extends Node2D

@onready var bar: ProgressBar = $ProgressBar

var enemy

func initialize(e):
	enemy = e
	
	update_bar()
	enemy.stats.hp_changed.connect(_on_hp_changed)

func _on_hp_changed(damage: float, color: Color, is_heavy_hit: bool):
	update_bar()

func update_bar():
	bar.max_value = enemy.stats.max_hp
	bar.value = enemy.stats.hp
