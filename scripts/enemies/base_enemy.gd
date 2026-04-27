extends CharacterBody2D
class_name BaseEnemy

var max_hp: float
var move_speed: float
var jump_height: float
var crit_rate: float
var damage_reduction: float
var i_frame_duration: float

var stats: EnemyStats
var buffs: EnemyBuffs

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_hp: float = 0.0
var is_hurt: bool = false
var hurt_timer: float = 0.0
var hurt_duration: float = 0.25
var hurt_knockback_speed: float = 180.0
var hurt_dir: float = 0.0


func _ready() -> void:
	initialize_stats()
	
	var data = get_data_dict()
	stats = EnemyStats.new()
	buffs = EnemyBuffs.new()
	
	stats.initialize(data)
	buffs.initialize()
	last_hp = stats.hp


func _physics_process(delta: float) -> void:
	buffs.apply(stats)
	var incoming_damage := get_total_receiving_damage()
	stats.settle(delta)
	
	if stats.hp <= 0:
		on_death()
		return
	
	if stats.hp < last_hp or incoming_damage > 0.0:
		trigger_hurt()
	
	if is_hurt:
		hurt_timer -= delta
		velocity.x = hurt_dir * hurt_knockback_speed
		if hurt_timer <= 0:
			is_hurt = false
	else:
		handle_ai(delta)
	
	move_and_slide()
	
	if is_hurt:
		play_hurt_animation()
	else:
		update_animation()
	
	last_hp = stats.hp
	stats.reset(get_data_dict())


func initialize_stats() -> void:
	push_error("initialize_stats()未实现！")


func get_data_dict() -> Dictionary:
	return {
		"max_hp": max_hp,
		"move_speed": move_speed,
		"jump_height": jump_height,
		"crit_rate": crit_rate,
		"damage_reduction": damage_reduction,
		"i_frame_duration": i_frame_duration
	}


func handle_ai(_delta: float) -> void:
	push_error("handle_ai()未实现！")


func update_animation() -> void:
	push_error("update_animation()未实现！")


func on_death() -> void:
	push_error("on_death()未实现！")


func trigger_hurt() -> void:
	if is_hurt:
		hurt_timer = hurt_duration
		return
	
	is_hurt = true
	hurt_timer = hurt_duration
	on_hurt_started()
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hurt_dir = sign(global_position.x - player.global_position.x)
	else:
		hurt_dir = -sign(velocity.x)
	
	if hurt_dir == 0:
		hurt_dir = 1.0


func on_hurt_started() -> void:
	var attack_shape = get_node_or_null("AttackArea/CollisionShape2D")
	if attack_shape:
		attack_shape.set_deferred("disabled", true)


func play_hurt_animation() -> void:
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("hurt"):
		if sprite.animation != "hurt" or not sprite.is_playing():
			sprite.play("hurt")
	else:
		update_animation()


func get_total_receiving_damage() -> float:
	var total := 0.0
	if stats == null:
		return total
	for damage in stats.receiving_damages:
		total += damage
	return total
