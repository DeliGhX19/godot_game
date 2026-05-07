extends BaseEnemy

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var detection_range: float = 500.0
var attack_range: float = 100.0
var is_attacking: bool = false
var attack_start_frame: int = 5
var attack_end_frame: int = 7

func initialize_stats() -> void:
	max_hp = 100.0
	move_speed = 80.0
	jump_height = 0.0
	crit_rate = 0.0
	base_damages = [15.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	damage_reduction = [0.2, 0.0, 0.0, 0.0, 0.0, 0.0]
	i_frame_duration = 0.0
	meta_currency_reward = 1
	
	attack_shape.disabled = true

func handle_ai(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GameManager.gravity * delta
	
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		if sprite.animation == "attack" and sprite.frame >= attack_start_frame and sprite.frame <= attack_end_frame:
			attack_shape.disabled = false
		else:
			attack_shape.disabled = true
		return

	var player = GameManager.player
	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)

	if dist <= attack_range:
		is_attacking = true
		velocity.x = 0
	elif dist <= detection_range:
		velocity.x = dir * stats.move_speed
		sprite.flip_h = dir < 0
		attack_area.scale.x = -1 if dir < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)

func update_animation() -> void:
	if is_hurt:
		sprite.play("hurt")
		attack_shape.disabled = true
	elif is_attacking:
		sprite.play("attack")
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
