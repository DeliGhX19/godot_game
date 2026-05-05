extends BasePlayerMagic

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer


func initialize(belonging_player: CharacterBody2D) -> void:
	player = belonging_player
	
	base_damage = 20
	speed = 600
	flying_time = 2.0 + player.stats.magic_range_extra
	gravity = 0
	bounce_factor = 0.0
	max_pierce = 1 + player.stats.magic_pierce_extra

func _physics_process(delta: float) -> void:
	# 处理撞墙
	var collision = move_and_collide(velocity * delta)
	if collision:
		die()
		return
	
	# 处理方向
	if velocity.length() > 0: rotation = velocity.angle()


# 发射魔法
func launch(target_position: Vector2) -> bool:
	velocity = global_position.direction_to(target_position) * speed
	
	sprite.play("fly")
	timer.wait_time = flying_time
	timer.start()
	
	return true

# 魔法销毁
func die() -> void:
	if is_dying: return
	is_dying = true
	
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	area_shape.set_deferred("disabled", true)
	
	sprite.play("die")


func _on_timer_timeout() -> void:
	die()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dying: return
	
	player.stats.damages[PlayerStats.ICE_MAGIC].value = base_damage
	player.stats.damages[PlayerStats.ICE_MAGIC].type = GameManager.TYPE_ICE
	player.stats.enemies[PlayerStats.ICE_MAGIC].append(body)
	if randf() <= 0.5: body.buffs.add_ice()
	if player.buffs.buffs[PlayerBuffs.ICE_EXPLORE] > 0 and randf() <= 0.25:
		body.buffs.buffs[EnemyBuffs.ICE_EXPLOSION] = 1
	
	current_pierce += 1
	if current_pierce >= max_pierce:
		die()

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die":
		queue_free()
