extends BasePlayerMagic

var chain_lightning_scene = preload("res://scenes/player/chain_lightning.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var fly_area_shape: CollisionShape2D = $FlyArea2D/CollisionShape2D
@onready var die_area_shape: CollisionShape2D = $DieArea2D/CollisionShape2D
@onready var timer: Timer = $Timer

var is_disaster: bool = false          # 是否秒杀


func initialize(belonging_player: CharacterBody2D) -> void:
	player = belonging_player
	
	base_damage = 15
	speed = 800
	flying_time = 0.6 + player.stats.magic_range_extra
	gravity = 0
	bounce_factor = 0.0
	max_pierce = 3 + player.stats.magic_pierce_extra
	
	if player.buffs.buffs[PlayerBuffs.LIGHTNING_DISASTER] > 0:
		if randf() <= 0.15: is_disaster = true
	
	die_area_shape.disabled = true

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	
	# 处理方向
	rotation = velocity.angle() + PI/2


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
	fly_area_shape.set_deferred("disabled", true)
	
	if is_disaster:
		rotation = 0
		sprite.play("kill")
	else:
		scale *= 1.0 + 0.1 * player.buffs.buffs[PlayerBuffs.LIGHTNING_LEVEL_2] + 0.2 * player.buffs.buffs[PlayerBuffs.LIGHTNING_LEVEL_3]
		die_area_shape.set_deferred("disabled", false)
		sprite.play("die")

# 生成连锁雷
func generate_chain_lightning(body: Node2D):
	for i in range(player.buffs.buffs[PlayerBuffs.LIGHTNING_CHAIN]):
		var chain = chain_lightning_scene.instantiate()
		get_parent().add_child(chain)
		chain.global_position = body.global_position
		chain.initialize(player, body)


func _on_timer_timeout() -> void:
	die()

func _on_fly_area_2d_body_entered(body: Node2D) -> void:
	if is_dying: return
	
	if is_disaster:
		body.buffs.buffs[EnemyBuffs.EXECUTE] = 1
		die()
		return
	
	player.stats.damages[PlayerStats.LIGHTNING_MAGIC].value = base_damage
	player.stats.damages[PlayerStats.LIGHTNING_MAGIC].type = GameManager.TYPE_LIGHTNING
	player.stats.enemies[PlayerStats.LIGHTNING_MAGIC].append(body)
	call_deferred("generate_chain_lightning", body)
	
	current_pierce += 1
	if current_pierce >= max_pierce:
		die()

func _on_die_area_2d_body_entered(body: Node2D) -> void:
	player.stats.damages[PlayerStats.LIGHTNING_SPLASH].value = base_damage * 0.5
	player.stats.damages[PlayerStats.LIGHTNING_SPLASH].type = GameManager.TYPE_LIGHTNING
	player.stats.enemies[PlayerStats.LIGHTNING_SPLASH].append(body)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die" or sprite.animation == "kill":
		queue_free()
