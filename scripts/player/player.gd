extends CharacterBody2D

var fire_magic_scene: PackedScene = preload("res://scenes/player/fire_magic.tscn")
var wood_magic_scene: PackedScene = preload("res://scenes/player/wood_magic.tscn")
var stone_magic_scene: PackedScene = preload("res://scenes/player/stone_magic.tscn")
var ice_magic_scene: PackedScene = preload("res://scenes/player/ice_magic.tscn")
var lightning_magic_scene: PackedScene = preload("res://scenes/player/lightning_magic.tscn")
var floating_number_scene: PackedScene = preload("res://scenes/gui/floating_damage.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var profile: PlayerProfile
var stats: PlayerStats
var buffs: PlayerBuffs

var current_magic_index: int = 0
var shoot_cooldown_timer: float = 0.0
var magic_scenes: Array = [fire_magic_scene, wood_magic_scene, stone_magic_scene, ice_magic_scene, lightning_magic_scene]


signal die


func initialize(selected_profile: PlayerProfile):
	profile = selected_profile
	GameManager.player = self
	
	stats = PlayerStats.new()
	stats.initialize(profile)
	stats.hp_changed.connect(_on_hp_changed)
	
	buffs = PlayerBuffs.new()
	buffs.initialize()

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
	
	# 检测是否死亡
	if stats.hp <= 0:
		die.emit()
	
	# 远程攻击
	if shoot_cooldown_timer > 0: shoot_cooldown_timer -= delta
	if Input.is_action_pressed("projectile") and shoot_cooldown_timer <= 0:
		if magic_attack():
			shoot_cooldown_timer = 1.0 / stats.magic_attack_speed
	
	# 左右移动
	var input_dir := Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * stats.move_speed
	if not is_on_floor(): velocity.y += GameManager.gravity * delta
	# 跳跃
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = -stats.jump_height
	# 移动动画
	move_and_slide()
	update_animation(input_dir)
	
	# 无敌帧闪烁
	if stats.i_frame_timer > 0:
		modulate.a = 0.5 if Engine.get_frames_drawn() % 10 < 5 else 1.0
	else:
		modulate.a = 1.0
	
	stats.reset(profile)


# 远程攻击
func magic_attack() -> bool:
	var magic = magic_scenes[current_magic_index].instantiate()
	get_parent().add_child(magic)
	
	magic.initialize(self)
	magic.global_position = global_position
	return magic.launch(get_global_mouse_position())

# 更新动画
func update_animation(input_dir: float) -> void:
	# 选择动画
	if not is_on_floor(): sprite.play("jump")
	elif input_dir != 0: sprite.play("run")
	else: sprite.play("idle")
	
	# 朝向修正
	if input_dir != 0: 
		sprite.flip_h = input_dir < 0


func _on_hp_changed(damage: float, color: Color, is_heavy_hit: bool) -> void:
	var floating_number = floating_number_scene.instantiate()
	add_child(floating_number)
	
	floating_number.global_position = global_position + Vector2(0, -40)
	floating_number.display(damage, color, is_heavy_hit)
