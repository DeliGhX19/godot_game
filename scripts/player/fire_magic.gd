extends BasePlayerMagic

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var eruption_area_shape: CollisionShape2D = $EruptionArea2D/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var light: PointLight2D = $PointLight2D

var is_eruption: bool = false        # 是否触发炎爆


func initialize(belonging_player: CharacterBody2D) -> void:
	player = belonging_player
	
	base_damage = 20
	speed = 800
	flying_time = 0.8 + player.stats.magic_range_extra
	gravity = 0
	bounce_factor = 1.0
	max_pierce = 1 + player.stats.magic_pierce_extra
	
	if player.buffs.buffs[PlayerBuffs.FIRE_ERUPTION] > 0:
		if randf() <= 0.15: is_eruption = true
	eruption_area_shape.set_deferred("disabled", true)
	
	if player.buffs.buffs[PlayerBuffs.ENVIRONMENT_DARK] > 0:
		light.visible = true

func _physics_process(delta: float) -> void:
	# 处理风向
	if player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WIND] > 0:
		var wind_dir = Vector2(cos(GameManager.wind_angle), sin(GameManager.wind_angle))
		velocity += wind_dir * 1200 * delta
	
	# 处理重力
	if player.buffs.buffs[PlayerBuffs.ENVIRONMENT_GRAVITY] > 0:
		velocity.y += GameManager.gravity * 0.5 * delta
	
	# 处理反弹
	var collision = move_and_collide(velocity * delta)
	if collision: velocity = velocity.bounce(collision.get_normal()) * bounce_factor
	
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
	eruption_area_shape.set_deferred("disabled", not is_eruption)
	
	if is_eruption:
		rotation = 0
		scale *= 3 
		sprite.play("eruption")
	else: sprite.play("die")


func _on_timer_timeout() -> void:
	die()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dying: return
	
	if is_eruption:
		die()
		return
	
	player.stats.damages[PlayerStats.FIRE_MAGIC].value = base_damage
	player.stats.damages[PlayerStats.FIRE_MAGIC].type = GameManager.TYPE_FIRE
	player.stats.enemies[PlayerStats.FIRE_MAGIC].append(body)
	
	var rand_val = 0.0
	if player.buffs.buffs[PlayerBuffs.ENVIRONMENT_FIRE] > 0: rand_val = 0.4
	elif player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WATER] > 0: rand_val = -1.0
	elif player.buffs.buffs[PlayerBuffs.ENVIRONMENT_WINTER] > 0: rand_val = 0.1
	else: rand_val = 0.25
	if randf() <= rand_val: body.buffs.add_burn()
	
	current_pierce += 1
	if current_pierce >= max_pierce:
		die()

func _on_eruption_area_2d_body_entered(body: Node2D) -> void:
	player.stats.damages[PlayerStats.FIRE_ERUPTION].value = base_damage * 3
	player.stats.damages[PlayerStats.FIRE_ERUPTION].type = GameManager.TYPE_FIRE
	player.stats.enemies[PlayerStats.FIRE_ERUPTION].append(body)
	for i in range(2): body.buffs.add_burn()

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die" or sprite.animation == "eruption":
		queue_free()
