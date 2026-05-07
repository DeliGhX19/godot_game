extends Area2D

signal interact_requested

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $PromptLabel

var player_in_range: bool = false


func _ready() -> void:
	sprite.play("idle")
	prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range:
		return
	if event.is_action_pressed("interact"):
		interact_requested.emit()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false
