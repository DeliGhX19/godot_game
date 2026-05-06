extends Node2D

enum SwordState {
	ORBIT,
	CHASE,
	ATTACK,
	RETURN
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea
@onready var detect_shape: CollisionShape2D = $DetectArea/CollisionShape2D
@onready var hit_area: Area2D = $HitArea
@onready var hit_shape: CollisionShape2D = $HitArea/CollisionShape2D

var controller: Node = null
var player: CharacterBody2D = null
var sword_index: int = 0
var orbit_angle: float = 0.0
var current_state: int = SwordState.ORBIT
var target: Node2D = null
var tracked_enemies: Array[Node2D] = []
var attack_cooldown_timer: float = 0.0
var hit_enemies: Array[Node2D] = []


func initialize(belonging_controller: Node, belonging_player: CharacterBody2D, index: int) -> void:
	controller = belonging_controller
	player = belonging_player
	sword_index = index
	orbit_angle = TAU * float(index) / max(1.0, float(controller.desired_count))
	current_state = SwordState.ORBIT
	target = null
	global_position = player.global_position


func _ready() -> void:
	hit_area.monitoring = false
	hit_shape.disabled = true
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	detect_shape.shape.radius = controller.detect_radius
	hit_shape.shape.radius = controller.attack_radius

	_cleanup_tracked_enemies()

	match current_state:
		SwordState.ORBIT:
			_update_orbit(delta)
			_try_lock_target()
		SwordState.CHASE:
			_update_chase(delta)
		SwordState.ATTACK:
			_update_attack()
		SwordState.RETURN:
			_update_return(delta)


func _update_orbit(delta: float) -> void:
	sprite.play("idle")
	orbit_angle += delta * controller.orbit_speed
	var desired_position = player.global_position + Vector2.RIGHT.rotated(orbit_angle) * controller.orbit_radius
	global_position = global_position.lerp(desired_position, min(1.0, delta * 8.0))
	rotation = (desired_position - player.global_position).angle() + PI * 0.5


func _try_lock_target() -> void:
	if attack_cooldown_timer > 0:
		return
	target = _find_best_target()
	if target != null:
		current_state = SwordState.CHASE
		sprite.play("fly")


func _update_chase(delta: float) -> void:
	if not _is_target_valid(target):
		_enter_return_state()
		return

	var to_target = target.global_position - global_position
	var distance = to_target.length()
	if distance <= controller.attack_radius:
		current_state = SwordState.ATTACK
		hit_enemies.clear()
		_set_hitbox_enabled(true)
		sprite.play("attack")
		return

	var velocity = to_target.normalized() * controller.move_speed
	global_position += velocity * delta
	rotation = to_target.angle() + PI * 0.5


func _update_attack() -> void:
	if not _is_target_valid(target):
		_set_hitbox_enabled(false)
		_enter_return_state()
		return

	var to_target = target.global_position - global_position
	if to_target.length() > 0.001:
		rotation = to_target.angle() + PI * 0.5


func _update_return(delta: float) -> void:
	sprite.play("return")
	var desired_position = player.global_position + Vector2.RIGHT.rotated(orbit_angle) * controller.orbit_radius
	var to_home = desired_position - global_position
	if to_home.length() <= 8.0:
		current_state = SwordState.ORBIT
		sprite.play("idle")
		return

	global_position += to_home.normalized() * controller.move_speed * delta
	rotation = to_home.angle() + PI * 0.5


func _find_best_target() -> Node2D:
	var best_target: Node2D = null
	var best_distance := INF
	for enemy in tracked_enemies:
		if not _is_target_valid(enemy):
			continue
		if GameManager.is_target_blocked_by_wall(self, enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < best_distance:
			best_distance = dist
			best_target = enemy
	return best_target


func _is_target_valid(candidate: Node2D) -> bool:
	if candidate == null or not is_instance_valid(candidate):
		return false
	if not candidate.has_method("get"):
		return true
	if candidate.get("stats") == null:
		return false
	return candidate.stats.hp > 0


func _cleanup_tracked_enemies() -> void:
	var valid_enemies: Array[Node2D] = []
	for enemy in tracked_enemies:
		if _is_target_valid(enemy):
			valid_enemies.append(enemy)
	tracked_enemies = valid_enemies


func _enter_return_state() -> void:
	target = null
	current_state = SwordState.RETURN
	_set_hitbox_enabled(false)


func _set_hitbox_enabled(enabled: bool) -> void:
	hit_area.monitoring = enabled
	hit_shape.set_deferred("disabled", not enabled)


func _register_hit(body: Node2D) -> void:
	if hit_enemies.has(body):
		return
	hit_enemies.append(body)
	player.stats.damages[PlayerStats.FLYING_SWORD].value = controller.sword_damage
	player.stats.damages[PlayerStats.FLYING_SWORD].type = GameManager.TYPE_PHYSIC
	player.stats.enemies[PlayerStats.FLYING_SWORD].append(body)


func _on_detect_area_body_entered(body: Node2D) -> void:
	if not tracked_enemies.has(body):
		tracked_enemies.append(body)


func _on_detect_area_body_exited(body: Node2D) -> void:
	tracked_enemies.erase(body)
	if body == target and current_state != SwordState.ATTACK:
		_enter_return_state()


func _on_hit_area_body_entered(body: Node2D) -> void:
	if current_state != SwordState.ATTACK:
		return
	if GameManager.is_target_blocked_by_wall(self, body):
		return
	_register_hit(body)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		attack_cooldown_timer = controller.attack_cooldown
		_enter_return_state()
