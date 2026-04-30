extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var base_damage: float = 60
var player: CharacterBody2D = GameManager.player

func _ready() -> void:
	sprite.play("explore")


func _on_body_entered(body: Node2D) -> void:
	player.stats.damages[PlayerStats.FIRE_EXPLOSION].value = base_damage
	player.stats.damages[PlayerStats.FIRE_EXPLOSION].type = GameManager.TYPE_FIRE
	player.stats.enemies[PlayerStats.FIRE_EXPLOSION].append(body)

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
