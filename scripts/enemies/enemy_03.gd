extends BaseEnemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var sprite_base_x: float = sprite.position.x
@onready var attack_area_base_x: float = attack_area.position.x

var detection_range: float = 500.0
var attack_range: float = 100.0
var base_damage: float = 15.0

var is_attacking: bool = false


func initialize_stats() -> void:
	max_hp = 100.0
	move_speed = 80.0
	jump_height = 0.0
	crit_rate = 0.0
	damage_reduction = 0.2
	i_frame_duration = 0.1
	
	attack_shape.disabled = true


func handle_ai(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)
		return

	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)

	if dist <= attack_range:
		is_attacking = true
		velocity.x = 0
	elif dist <= detection_range:
		velocity.x = dir * stats.move_speed
		set_facing(dir > 0)
	else:
		velocity.x = move_toward(velocity.x, 0, stats.move_speed * delta)


func update_animation() -> void:
	if is_attacking:
		sprite.play("attack")
		attack_shape.disabled = false
	elif abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")


func on_death() -> void:
	set_physics_process(false)
	sprite.play("death")
	if sprite.is_playing():
		await sprite.animation_finished
	queue_free()


func on_hurt_started() -> void:
	super.on_hurt_started()
	is_attacking = false


func set_facing(mirror: bool) -> void:
	var pivot_x = body_shape.position.x
	sprite.flip_h = mirror
	sprite.position.x = (2.0 * pivot_x - sprite_base_x) if mirror else sprite_base_x
	attack_area.scale.x = -1 if mirror else 1
	attack_area.position.x = (2.0 * pivot_x - attack_area_base_x) if mirror else attack_area_base_x


func is_attack_blocked_by_wall(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(0, -20),
		target.global_position + Vector2(0, -20)
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
