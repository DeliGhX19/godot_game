extends CharacterBody2D

var fire_magic_scene: PackedScene = preload("res://scenes/player/fire_magic.tscn")
var wood_magic_scene: PackedScene = preload("res://scenes/player/wood_magic.tscn")
var stone_magic_scene: PackedScene = preload("res://scenes/player/stone_magic.tscn")
var stone_meteor_scene: PackedScene = preload("res://scenes/player/stone_meteor.tscn")
var ice_magic_scene: PackedScene = preload("res://scenes/player/ice_magic.tscn")
var lightning_magic_scene: PackedScene = preload("res://scenes/player/lightning_magic.tscn")
var flying_sword_controller_scene: PackedScene = preload("res://scenes/player/flying_sword_controller.tscn")
var floating_number_scene: PackedScene = preload("res://scenes/gui/floating_damage.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_hitbox: Area2D = $AttackPivot/AttackHitbox
@onready var attack_collision: CollisionShape2D = $AttackPivot/AttackHitbox/CollisionShape2D
@onready var standing_collision: CollisionShape2D = $StandingCollisionShape2D
@onready var slide_collision: CollisionShape2D = $SlideCollisionShape2D
@onready var initial_pivot_x = attack_pivot.position.x

var profile: PlayerProfile
var stats: PlayerStats
var buffs: PlayerBuffs
var flying_sword_controller: Node2D = null

# 近战攻击
var is_attacking: bool = false
var attack_damage: float = 25.0
var melee_cooldown_timer: float = 0.0

# 远程攻击
var current_magic_index: int = 0
var magic_cooldown_timer: float = 0.0
var magic_scenes: Array = [fire_magic_scene, wood_magic_scene, stone_magic_scene, ice_magic_scene, lightning_magic_scene]

# 闪避
var facing_dir: float = 1.0
var slide_speed: float = 520.0
var slide_duration: float = 0.22
var is_sliding: bool = false
var is_dead: bool = false
var is_turning: bool = false
var turn_target_dir: float = 1.0

signal die


func initialize(selected_profile: PlayerProfile):
	profile = selected_profile
	
	stats = PlayerStats.new()
	stats.initialize(profile)
	stats.hp_changed.connect(_on_hp_changed)
	
	buffs = PlayerBuffs.new()
	buffs.initialize()
	buffs.buffs[PlayerBuffs.FLYING_SWORD] = 1
	
	set_slide_collision_enabled(false)
	set_attack_hitbox_enabled(false)
	ensure_flying_sword_controller()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_magic"):
		current_magic_index = 0
	elif event.is_action_pressed("wood_magic"):
		current_magic_index = 1
	elif event.is_action_pressed("stone_magic"):
		current_magic_index = 2
	elif event.is_action_pressed("ice_magic"):
		current_magic_index = 3
	elif event.is_action_pressed("lightning_magic"):
		current_magic_index = 4


func _physics_process(delta: float) -> void:
	buffs.apply(stats, delta)
	stats.settle(delta)
	ensure_flying_sword_controller()
	flying_sword_controller.sync_from_player_stats()
	
	# 检测是否死亡
	if stats.hp <= 0:
		if not is_dead:
			_enter_death_state()
		move_and_slide()
		update_animation(0.0)
		return
	
	# 行动
	if magic_cooldown_timer > 0: magic_cooldown_timer -= delta
	if melee_cooldown_timer > 0: melee_cooldown_timer -= delta
	
	if not is_sliding and not is_attacking and not is_turning:
		# 近战攻击
		if Input.is_action_just_pressed("melee") and melee_cooldown_timer <= 0:
			is_attacking = true
			var cooldown = (1.0 / stats.melee_attack_speed) * (1.0 - stats.melee_kill_refresh)
			melee_cooldown_timer = cooldown
			attack_pivot.position.x = initial_pivot_x * facing_dir
			attack_pivot.scale.x = facing_dir
			set_attack_hitbox_enabled(true)
		# 远程攻击
		if Input.is_action_just_pressed("projectile") and magic_cooldown_timer <= 0:
			if magic_attack():
				magic_cooldown_timer = 1.0 / stats.magic_attack_speed
		# 闪避
		if Input.is_action_just_pressed("slide"):
			is_sliding = true
			stats.slide_timer = slide_duration
			sprite.play("slide")
			set_slide_collision_enabled(true)
	
	# 移动
	var input_dir := Input.get_axis("move_left", "move_right")
	if not is_turning and _should_start_turn(input_dir):
		_start_turn(sign(input_dir))
		input_dir = 0.0
	if input_dir != 0 and not is_turning:
		facing_dir = sign(input_dir)
	
	if is_sliding:
		#滑行
		stats.slide_timer -= delta
		velocity.x = input_dir * slide_speed
		if stats.slide_timer <= 0.0:
			is_sliding = false
			set_slide_collision_enabled(false)
	elif is_turning:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += GameManager.gravity * delta
	else:
		# 走动
		velocity.x = input_dir * stats.move_speed
		if not is_on_floor():
			velocity.y += GameManager.gravity * delta
	
	# 风力影响
	if input_dir != 0 and buffs.buffs[PlayerBuffs.ENVIRONMENT_WIND] > 0:
		velocity.x += cos(GameManager.wind_angle) * 5000 * delta
	
	# 跳跃
	if Input.is_action_just_pressed("move_up") and is_on_floor() and not is_turning:
		velocity.y = -stats.jump_height
	
	# 动画
	move_and_slide()
	update_animation(input_dir)
	
	# 无敌帧闪烁
	if stats.i_frame_timer > 0:
		modulate.a = 0.5 if Engine.get_frames_drawn() % 10 < 5 else 1.0
	else:
		modulate.a = 1.0
	
	stats.reset(profile)


func ensure_flying_sword_controller() -> void:
	if flying_sword_controller != null and is_instance_valid(flying_sword_controller):
		return

	flying_sword_controller = flying_sword_controller_scene.instantiate()
	add_child(flying_sword_controller)
	flying_sword_controller.initialize(self)


# 设置近战攻击相关碰撞箱
func set_attack_hitbox_enabled(enabled: bool) -> void:
	attack_collision.set_deferred("disabled", not enabled)
	attack_hitbox.monitoring = enabled

# 远程攻击
func magic_attack() -> bool:
	if current_magic_index == 2 and buffs.buffs[PlayerBuffs.STONE_METEOR] > 0:
		if randf() <= 0.15:
			var stone_meteor = stone_meteor_scene.instantiate()
			get_parent().add_child(stone_meteor)
			if stone_meteor.initialize(self):
				return true
			stone_meteor.queue_free()
	
	var magic = magic_scenes[current_magic_index].instantiate()
	get_parent().add_child(magic)
	magic.initialize(self)
	magic.global_position = global_position
	return magic.launch(get_global_mouse_position())

# 设置闪避相关碰撞箱
func set_slide_collision_enabled(enabled: bool) -> void:
	standing_collision.set_deferred("disabled", enabled)
	slide_collision.set_deferred("disabled", not enabled)
	set_collision_layer_value(2, not enabled)

# 更新动画
func update_animation(input_dir: float) -> void:
	# 选择动画
	if is_dead:
		sprite.play("death")
	elif is_turning:
		sprite.play("turn")
	elif is_sliding:
		sprite.play("slide")
	elif is_attacking:
		sprite.play("attack")
	elif not is_on_floor():
		sprite.play("jump")
		sprite.pause()
		sprite.frame = 0 if velocity.y < 0 else 1
	elif input_dir != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
	
	# 朝向修正
	if not is_dead and not is_turning and input_dir != 0:
		sprite.flip_h = input_dir < 0


func _should_start_turn(input_dir: float) -> bool:
	return input_dir != 0 and is_on_floor() and sign(input_dir) != facing_dir


func _start_turn(new_dir: float) -> void:
	is_turning = true
	turn_target_dir = new_dir
	velocity.x = 0
	set_attack_hitbox_enabled(false)


func _enter_death_state() -> void:
	is_dead = true
	is_attacking = false
	is_sliding = false
	is_turning = false
	velocity = Vector2.ZERO
	set_attack_hitbox_enabled(false)
	set_slide_collision_enabled(false)


func _on_hp_changed(damage: float, color: Color, is_heavy_hit: bool) -> void:
	var floating_number = floating_number_scene.instantiate()
	add_child(floating_number)
	
	floating_number.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, -20))
	floating_number.display(damage, color, is_heavy_hit)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
		set_attack_hitbox_enabled(false)
	elif sprite.animation == "turn":
		is_turning = false
		facing_dir = turn_target_dir
		sprite.flip_h = facing_dir < 0
	elif sprite.animation == "death":
		die.emit()


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if not GameManager.is_target_blocked_by_wall(self, body):
		stats.damages[PlayerStats.PHYSIC_ATTACK].value = attack_damage
		stats.damages[PlayerStats.PHYSIC_ATTACK].type = GameManager.TYPE_PHYSIC
		stats.enemies[PlayerStats.PHYSIC_ATTACK].append(body)
		
