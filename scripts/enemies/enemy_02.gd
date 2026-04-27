extends BaseEnemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var detection_range: float = 500.0        # 检测范围
var attack_range: float = 100.0           # 攻击范围
var base_damage: float = 15.0             # 基础伤害

var is_attacking: bool = false            # 是否攻击


# 初始化敌人数据
func initialize_stats() -> void:
	max_hp = 100.0
	move_speed = 80.0
	jump_height = 0.0
	crit_rate = 0.0
	damage_reduction = 0.2
	i_frame_duration = 0.1
	
	attack_shape.disabled = true

# 敌人AI
func handle_ai(delta: float) -> void:
	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 如果正在攻击，避免移动
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		return
	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)

	# 追击与攻击
	if dist <= attack_range:
		is_attacking = true
		velocity.x = 0
	elif dist <= detection_range:
		velocity.x = dir * stats.move_speed
		sprite.flip_h = dir < 0
		attack_area.scale.x = -1 if dir < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)

# 更新动画
func update_animation() -> void:
	if is_attacking: 
		sprite.play("attack")
		attack_shape.disabled = false
	elif abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")

# 死亡
func on_death() -> void:
	set_physics_process(false)
	sprite.play("death")
	if sprite.is_playing():
		await sprite.animation_finished
	queue_free()


func on_hurt_started() -> void:
	super.on_hurt_started()
	is_attacking = false


# 射线检测
func is_attack_blocked_by_wall(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position+ Vector2(0, -20),          # 敌人位置
		target.global_position+ Vector2(0, -20)    # 玩家位置
	)
	query.collision_mask = 1 
	query.exclude = [get_rid()] 
	
	var result = space_state.intersect_ray(query)
	return result.size() > 0


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
	attack_shape.set_deferred("disabled", true)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not is_attack_blocked_by_wall(body):
			stats.player = body.stats
			stats.damages[0] = base_damage
