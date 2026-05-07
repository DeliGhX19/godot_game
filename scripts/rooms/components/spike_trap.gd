extends Area2D


func _on_body_entered(body: Node2D) -> void:
	# 判断碰到的是不是玩家
	print("碰到了：", body.name)
	body.stats.settle_hp(0.1 * body.stats.max_hp)
