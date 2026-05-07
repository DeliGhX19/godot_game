extends Node2D

var player: CharacterBody2D = null


func _ready() -> void:
	$AnimatedSprite2D.play("lit")

func _notification(_what) -> void:
	if player != null:
		player.buffs.buffs[PlayerBuffs.BONFIRE] -= 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.buffs.buffs[PlayerBuffs.BONFIRE] += 1
	player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	body.buffs.buffs[PlayerBuffs.BONFIRE] -= 1
	player = null
