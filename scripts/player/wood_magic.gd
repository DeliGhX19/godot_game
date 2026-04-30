extends BasePlayerMagic

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_shape: CollisionShape2D = $Area2D/CollisionShape2D

var max_range: float = 0.0         # 最大攻击距离 


func initialize(belonging_player: CharacterBody2D) -> void:
	player = belonging_player
	
	base_damage = 10
	speed = 400
	flying_time = 3 + player.stats.magic_range_extra
	gravity = 0
	bounce_factor = 0.0
	max_pierce = 1
	
	max_range = speed * flying_time

func _physics_process(_delta: float) -> void:
	# 向玩家位置移动
	var to_player = player.global_position - global_position
	velocity = to_player.normalized() * speed
	move_and_slide()
	
	# 更新方向
	rotation = velocity.angle() + PI/2


# 发射魔法
func launch(target_position: Vector2) -> bool:
	# 射线检测
	var space_state = get_world_2d().direct_space_state
	var ray_origin = player.global_position
	var ray_end = ray_origin + ray_origin.direction_to(target_position) * max_range
	var query = PhysicsRayQueryParameters2D.create(ray_origin, ray_end, 1 | 4)
	query.exclude = [player.get_rid()]
	var result = space_state.intersect_ray(query)
	
	# 处理检测结果
	if result and result.collider.get_collision_layer_value(3):
		global_position = result.position
		sprite.play("fly")
		return true
	else:
		queue_free()
		return false

# 魔法销毁
func die() -> void:
	if is_dying: return
	is_dying = true
	
	global_position = player.global_position
	rotation = 0
	call_deferred("reparent", player)
	
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	area_shape.set_deferred("disabled", true)
	
	if player.stats.hp == player.stats.max_hp and player.buffs.buffs[PlayerBuffs.WOOD_CONVERT] > 0:
		sprite.play("die2")
	else:
		sprite.play("die1")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dying: return
	
	# 攻击敌人
	if body.get_collision_layer_value(3):
		if current_pierce < max_pierce:
			current_pierce += 1
			player.stats.damages[PlayerStats.WOOD_MAGIC].value = base_damage
			player.stats.damages[PlayerStats.WOOD_MAGIC].type = GameManager.TYPE_WOOD
			player.stats.enemies[PlayerStats.WOOD_MAGIC].append(body)
	# 触碰玩家
	elif body.get_collision_layer_value(2):
		player.buffs.buffs[PlayerBuffs.WOOD_HEAL] = 1
		die()

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die1" or sprite.animation == "die2":
		queue_free()
