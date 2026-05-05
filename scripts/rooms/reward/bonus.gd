extends Area2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var tier_index: int
var anim_names = ["basic", "advanced", "ultimate"]


func initialize(tier: int) -> void:
	tier_index = tier
	sprite.play(anim_names[tier_index])


func _on_body_entered(_body: Node2D) -> void:
	get_tree().get_first_node_in_group("rewards_gui").open_reward_gui(anim_names[tier_index])
	queue_free()
