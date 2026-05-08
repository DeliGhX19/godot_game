extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var base_damage: float = 45
var player: CharacterBody2D = GameManager.player
var trigger: CharacterBody2D


func _ready() -> void:
	sprite.play("explore")

func initialize(enemy: CharacterBody2D) -> void:
	trigger = enemy


func _on_body_entered(body: Node2D) -> void:
	player.stats.damages[PlayerStats.ICE_EXPLOSION].value = base_damage
	player.stats.damages[PlayerStats.ICE_EXPLOSION].type = GameManager.TYPE_ICE
	player.stats.enemies[PlayerStats.ICE_EXPLOSION].append(body)
	if body != trigger: body.buffs.buffs[EnemyBuffs.FREEZE] = 1

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
