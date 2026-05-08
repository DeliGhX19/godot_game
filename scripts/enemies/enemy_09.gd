extends BaseEnemy

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var detection_range: float = 500.0
var attack_range: float = 100.0
var is_attacking: bool = false
var is_healing: bool = false
var is_reviving: bool = false
var is_revive_dead: bool = false
var has_used_heal: bool = false
var has_used_revive: bool = false
var revive_delay_timer: float = 0.0

var attack_start_frame: int = 7
var attack_end_frame: int = 10

const HEAL_RATIO := 0.35
const HEAL_TRIGGER_RATIO := 0.5
const REVIVE_DELAY := 2.5


func initialize_stats() -> void:
	max_hp = 110.0
	move_speed = 88.0
	jump_height = 0.0
	crit_rate = 0.1
	base_damages = [0.0, 18.0, 0.0, 0.0, 0.0, 8.0]
	damage_reduction = [0.1, 0.2, 0.0, 0.0, 0.1, 0.15]
	i_frame_duration = 0.0
	meta_currency_reward = 2

	attack_shape.disabled = true


func handle_ai(delta: float) -> void:
	var player = GameManager.player

	if is_revive_dead:
		velocity = Vector2.ZERO
		attack_shape.set_deferred("disabled", true)
		revive_delay_timer -= delta
		if revive_delay_timer <= 0.0 and not is_reviving:
			_start_revive()
		return

	if not is_on_floor():
		velocity.y += GameManager.gravity * delta

	if is_healing or is_reviving:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		attack_shape.set_deferred("disabled", true)
		return

	if not has_used_heal and stats.hp <= stats.max_hp * HEAL_TRIGGER_RATIO:
		_start_heal()
		return

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
	if is_revive_dead:
		sprite.play("death")
		sprite.pause()
		sprite.frame = sprite.sprite_frames.get_frame_count("death") - 1
	elif is_reviving:
		sprite.play("spawn")
	elif is_healing:
		sprite.play("heal")
	elif is_hurt:
		sprite.play("hurt")
		attack_shape.disabled = true
	elif is_attacking:
		sprite.play("attack")
	elif abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")


func on_death() -> void:
	if has_used_revive:
		super.on_death()
		return

	has_used_revive = true
	is_revive_dead = true
	is_attacking = false
	is_healing = false
	is_reviving = false
	is_hurt = false
	stats.hp = 1.0
	stats.player = null
	stats.i_frame_timer = REVIVE_DELAY + 0.5
	for i in range(GameManager.TYPE_COUNT):
		stats.receiving_damages[i] = 0.0
	velocity = Vector2.ZERO
	set_collision_layer_value(3, false)
	attack_shape.set_deferred("disabled", true)
	revive_delay_timer = REVIVE_DELAY


func _start_heal() -> void:
	has_used_heal = true
	is_healing = true
	is_attacking = false
	velocity.x = 0
	attack_shape.set_deferred("disabled", true)


func _start_revive() -> void:
	is_revive_dead = false
	is_reviving = true
	stats.hp = max(1.0, stats.max_hp * 0.6)
	velocity = Vector2.ZERO
	set_collision_layer_value(3, true)
	attack_shape.set_deferred("disabled", true)


func _finish_heal() -> void:
	is_healing = false
	stats.hp = min(stats.max_hp, stats.hp + stats.max_hp * HEAL_RATIO)


func _finish_revive() -> void:
	is_reviving = false
	is_hurt = false
	attack_shape.set_deferred("disabled", true)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "hurt":
		is_hurt = false
	elif sprite.animation == "attack":
		is_attacking = false
		attack_shape.set_deferred("disabled", true)
	elif sprite.animation == "heal":
		_finish_heal()
	elif sprite.animation == "spawn":
		_finish_revive()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not GameManager.is_target_blocked_by_wall(self, body):
		stats.player = body.stats
