extends BaseEnemy

@onready var main_collision: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var sprite_base_x: float = sprite.position.x
@onready var attack_area_base_x: float = attack_area.position.x

var detection_range: float = 500.0        # 检测范围
var attack_range: float = 100.0           # 攻击范围
var is_attacking: bool = false            # 是否攻击
var attack_start_frame: int = 4            # 攻击判定生效起始帧
var attack_end_frame: int = 6              # 攻击判定生效结束帧


# 初始化敌人数据
func initialize_stats() -> void:
	max_hp = 100.0
	move_speed = 80.0
	jump_height = 0.0
	crit_rate = 0.0
	base_damages = [15.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	damage_reduction = [0.2, 0.0, 0.0, 0.0, 0.0, 0.0]
	i_frame_duration = 0.0
	
	attack_shape.disabled = true

# 敌人AI
func handle_ai(delta: float) -> void:
	# 重力
	if not is_on_floor():
		velocity.y += GameManager.gravity * delta
	
	# 如果正在攻击，避免移动
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		# 以碰撞体为中心翻转sprite和attack_area
		var pdir = sign(GameManager.player.global_position.x - global_position.x) if GameManager.player else 1.0
		set_facing(pdir > 0)
		# 根据帧数控制攻击碰撞框
		if sprite.animation == "attack" and sprite.frame >= attack_start_frame and sprite.frame <= attack_end_frame:
			attack_shape.disabled = false
		else:
			attack_shape.disabled = true
		return

	var player = GameManager.player
	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)

	# 追击与攻击
	if dist <= attack_range:
		is_attacking = true
		velocity.x = 0
	elif dist <= detection_range:
		velocity.x = dir * stats.move_speed
		set_facing(dir > 0)
	else:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)

# 以碰撞体为中心翻转sprite和attack_area
func set_facing(mirror: bool) -> void:
	var pivot_x = main_collision.position.x
	sprite.flip_h = mirror
	sprite.position.x = (2.0 * pivot_x - sprite_base_x) if mirror else sprite_base_x
	attack_area.scale.x = -1 if mirror else 1
	attack_area.position.x = (2.0 * pivot_x - attack_area_base_x) if mirror else attack_area_base_x

# 更新攻击动画
func update_animation() -> void:
	if is_hurt:
		sprite.play("hurt")
		attack_shape.disabled = true
	elif is_attacking:
		sprite.play("attack")
		# 碰撞框由handle_ai根据帧数控制
	elif abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "hurt":
		is_hurt = false
	elif sprite.animation == "attack":
		is_attacking = false
		attack_shape.set_deferred("disabled", true)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if not GameManager.is_target_blocked_by_wall(self, body):
		stats.player = body.stats
