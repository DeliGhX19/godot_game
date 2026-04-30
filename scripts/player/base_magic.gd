extends CharacterBody2D
class_name BasePlayerMagic

var base_damage: float          # 基础伤害
var speed: float                # 速度
var flying_time: float          # 飞行时间
var gravity: float              # 重力
var bounce_factor: float        # 反弹后保留的动量系数
var max_pierce: int             # 基础最大穿透次数

var player: CharacterBody2D
var is_dying: bool = false
var current_pierce: int = 0


func initialize(_belonging_player: CharacterBody2D) -> void:
	push_error("initialize()未实现")


# 发射魔法
func launch(_target_position: Vector2) -> bool:
	push_error("launch()未实现")
	return false

# 魔法销毁
func die() -> void:
	push_error("die()未实现")
