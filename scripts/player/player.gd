extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_hitbox: Area2D = $AttackPivot/AttackHitbox
@onready var attack_collision: CollisionShape2D = $AttackPivot/AttackHitbox/CollisionShape2D
@onready var standing_collision: CollisionShape2D = $StandingCollisionShape2D
@onready var slide_collision: CollisionShape2D = $SlideCollisionShape2D

var profile: PlayerProfile
var stats: PlayerStats
var buffs: PlayerBuffs

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_dir: float = 1.0
@export var attack_damage: float = 100.0
@export var slide_speed: float = 520.0
@export var slide_duration: float = 0.22
var is_attacking: bool = false
var is_sliding: bool = false
var slide_timer: float = 0.0
var attack_hit_ids: Dictionary = {}

signal die


func _ready() -> void:
	if not sprite.animation_finished.is_connected(_on_sprite_animation_finished):
		sprite.animation_finished.connect(_on_sprite_animation_finished)
	update_facing_visuals()
	set_slide_collision_enabled(false)
	set_attack_hitbox_enabled(false)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		facing_dir = sign(input_dir)
		update_facing_visuals()
	
	buffs.apply(stats)
	handle_slide_input()
	handle_attack_input()
	if is_attacking:
		stats.damages[0] = attack_damage
	stats.settle(delta)
	
	if stats.hp <= 0:
		die.emit()
	
	if is_sliding:
		slide_timer -= delta
		velocity.x = facing_dir * slide_speed
		if slide_timer <= 0.0:
			is_sliding = false
			set_slide_collision_enabled(false)
	else:
		velocity.x = input_dir * stats.move_speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_sliding and Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = -stats.jump_height
	
	move_and_slide()
	update_animation(input_dir)
	
	if stats.i_frame_timer > 0:
		modulate.a = 0.5 if Engine.get_frames_drawn() % 10 < 5 else 1.0
	else:
		modulate.a = 1.0
	
	stats.reset(profile)


func update_animation(input_dir: float) -> void:
	if is_sliding:
		if sprite.animation != "slide":
			sprite.play("slide")
	elif is_attacking:
		if sprite.animation != "attack":
			sprite.play("attack")
	elif not is_on_floor():
		sprite.play("jump")
		sprite.pause()
		sprite.frame = 0 if velocity.y < 0 else 1
	elif input_dir != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
	
	if input_dir != 0:
		sprite.flip_h = input_dir < 0


func handle_attack_input() -> void:
	if is_sliding or is_attacking:
		return
	if not Input.is_action_just_pressed("attack"):
		return
	
	is_attacking = true
	attack_hit_ids.clear()
	stats.damages[0] = attack_damage
	sprite.play("attack")
	set_attack_hitbox_enabled(true)
	call_deferred("_register_current_attack_overlaps")


func handle_slide_input() -> void:
	if is_attacking or is_sliding:
		return
	if not is_on_floor():
		return
	if not Input.is_action_just_pressed("slide"):
		return
	
	is_sliding = true
	slide_timer = slide_duration
	sprite.play("slide")
	set_slide_collision_enabled(true)


func update_facing_visuals() -> void:
	if attack_pivot:
		attack_pivot.scale.x = facing_dir


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
		set_attack_hitbox_enabled(false)
	elif sprite.animation == "slide":
		is_sliding = false
		set_slide_collision_enabled(false)


func set_slide_collision_enabled(enabled: bool) -> void:
	if standing_collision:
		standing_collision.set_deferred("disabled", enabled)
	if slide_collision:
		slide_collision.set_deferred("disabled", not enabled)


func set_attack_hitbox_enabled(enabled: bool) -> void:
	if attack_collision:
		attack_collision.set_deferred("disabled", not enabled)
	if attack_hitbox:
		attack_hitbox.monitoring = enabled


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return
	if not (body is BaseEnemy):
		return
	if body.stats == null:
		return
	
	var id = body.get_instance_id()
	if attack_hit_ids.has(id):
		return
	
	attack_hit_ids[id] = true
	stats.enemies[0].append(body.stats)


func _register_current_attack_overlaps() -> void:
	if not is_attacking or attack_hitbox == null:
		return
	
	for body in attack_hitbox.get_overlapping_bodies():
		_on_attack_hitbox_body_entered(body)
