extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.buffs.buffs[PlayerBuffs.SPIKE_TRAP] += 1
