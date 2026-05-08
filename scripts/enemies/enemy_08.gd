extends BaseEnemy

const SPLIT_SCENE: PackedScene = preload("res://scenes/enemies/enemy_08.tscn")

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var detection_range: float = 500.0
var attack_range: float = 100.0
var is_attacking: bool = false
var attack_start_frame: int = 4
var attack_end_frame: int = 6
var can_split_on_death: bool = true
var is_split_child: bool = false

const SPLIT_CHILD_HP_MULTIPLIER := 0.65
const SPLIT_CHILD_SCALE := 0.8
const SPLIT_POP_DURATION := 0.18


func initialize_stats() -> void:
	max_hp = 90.0
	move_speed = 98.0
	jump_height = 0.0
	crit_rate = 0.12
	base_damages = [0.0, 0.0, 0.0, 0.0, 0.0, 19.0]
	damage_reduction = [0.05, 0.0, 0.0, -0.15, 0.15, 0.3]
	i_frame_duration = 0.0
	meta_currency_reward = 1

	if is_split_child:
		max_hp *= SPLIT_CHILD_HP_MULTIPLIER
		meta_currency_reward = 0

	attack_shape.disabled = true

	if is_split_child:
		scale = Vector2.ONE * SPLIT_CHILD_SCALE


func handle_ai(delta: float) -> void:
	var player = GameManager.player

	if not is_on_floor():
		velocity.y += GameManager.gravity * delta

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
		sprite.flip_h = dir > 0
		attack_area.scale.x = -1 if dir > 0 else 1
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


func on_death() -> void:
	if can_split_on_death:
		_spawn_split_children()
		can_split_on_death = false

	super.on_death()


func _spawn_split_children() -> void:
	var parent_node = get_parent()
	if parent_node == null:
		return

	for offset_x in [-40.0, 40.0]:
		var child = SPLIT_SCENE.instantiate()
		child.can_split_on_death = false
		child.is_split_child = true
		parent_node.add_child(child)
		child.global_position = global_position + Vector2(offset_x, -12.0)
		child.velocity = Vector2(sign(offset_x) * 85.0, -60.0)
		child.modulate.a = 0.55

		var target_scale := Vector2.ONE * SPLIT_CHILD_SCALE
		child.scale = target_scale * 0.72
		var tween = child.create_tween()
		tween.set_parallel(true)
		tween.tween_property(child, "scale", target_scale, SPLIT_POP_DURATION)
		tween.tween_property(child, "modulate:a", 1.0, SPLIT_POP_DURATION)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "hurt":
		is_hurt = false
	elif sprite.animation == "attack":
		is_attacking = false
		attack_shape.set_deferred("disabled", true)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not GameManager.is_target_blocked_by_wall(self, body):
		stats.player = body.stats
