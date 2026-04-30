extends Label


func _ready() -> void:
	top_level = true
	var tween = create_tween().set_parallel(true)
	
	# 向上移动
	tween.tween_property(self, "position:y", -60, 1.0)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)\
		 .as_relative()
	# 逐渐淡出
	tween.tween_property(self, "modulate:a", 0.0, 1.0)\
		.set_ease(Tween.EASE_IN)
	
	tween.chain().finished.connect(queue_free)


# 展示伤害数据
func display(value: float, color: Color, is_heavy_hit: bool = false) -> void:
	text = str(snapped(value, 0.1))
	
	# 高伤特效
	if is_heavy_hit:
		scale = Vector2(1.5, 1.5)
		rotation = randf_range(-0.2, 0.2)
		modulate = color.lightened(0.3)
	else:
		scale = Vector2(1.0, 1.0)
		rotation = 0
		modulate = color
