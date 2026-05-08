extends BaseEnemy

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var detection_range: float = 500.0
var attack_range: float = 100.0
var is_attacking: bool = false
var attack_start_frame: int = 7
var attack_end_frame: int = 10

var teleport_cooldown: float = 3.0
var teleport_cooldown_timer: float = 0.0
var teleport_offset_x: float = 72.0
var teleport_min_distance: float = 140.0


func initialize_stats() -> void:
	max_hp = 90.0
	move_speed = 98.0
	jump_height = 0.0
	crit_rate = 0.12
	base_damages = [0.0, 0.0, 0.0, 0.0, 0.0, 19.0]
	damage_reduction = [0.05, 0.0, 0.0, -0.15, 0.15, 0.3]
	i_frame_duration = 0.0
	meta_currency_reward = 1

	attack_shape.disabled = true


func handle_ai(delta: float) -> void:
	var player = GameManager.player

	if not is_on_floor():
		velocity.y += GameManager.gravity * delta
	if teleport_cooldown_timer > 0.0:
		teleport_cooldown_timer -= delta

	if is_attacking:
		var current_dist = global_position.distance_to(player.global_position)
		if current_dist > attack_range:
			is_attacking = false
			attack_shape.set_deferred("disabled", true)
			return
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		if sprite.animation == "attack" and sprite.frame >= attack_start_frame and sprite.frame <= attack_end_frame:
			attack_shape.disabled = false
		else:
			attack_shape.disabled = true
		return

	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)

	if dist <= detection_range and dist >= teleport_min_distance and teleport_cooldown_timer <= 0.0:
		_teleport_behind_player(player)
		dist = global_position.distance_to(player.global_position)
		dir = sign(player.global_position.x - global_position.x)

	if dist <= attack_range:
		is_attacking = true
		velocity.x = 0
	elif dist <= detection_range:
		velocity.x = dir * stats.move_speed
		sprite.flip_h = dir < 0
		attack_area.scale.x = -1 if dir < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)


func _teleport_behind_player(player: CharacterBody2D) -> void:
	var player_dir: float = player.facing_dir if player.facing_dir != 0 else 1.0
	var target_position: Vector2 = player.global_position - Vector2(player_dir * teleport_offset_x, 0.0)
	if target_position.distance_to(player.global_position) < attack_range * 0.5:
		target_position = player.global_position - Vector2(player_dir * attack_range, 0.0)

	global_position = target_position
	velocity = Vector2.ZERO
	teleport_cooldown_timer = teleport_cooldown

	var dir = sign(player.global_position.x - global_position.x)
	sprite.flip_h = dir < 0
	attack_area.scale.x = -1 if dir < 0 else 1


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
