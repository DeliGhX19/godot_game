extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var profile: PlayerProfile
var stats: PlayerStats
var buffs: PlayerBuffs

# TODO:调试用，后续改
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

signal die


func _physics_process(delta: float) -> void:
	buffs.apply(stats)
	stats.settle(delta)
	
	# 检测是否死亡
	if stats.hp <= 0:
		#die.emit()
		pass
	
	# 左右移动
	var input_dir := Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * stats.move_speed
	if not is_on_floor(): velocity.y += gravity * delta
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
	
	# TODO:调试，待删
	# print(stats.hp)
	
	stats.reset(profile)


# 更新动画
func update_animation(input_dir: float) -> void:
	# 选择动画
	if not is_on_floor(): sprite.play("jump")
	elif input_dir != 0: sprite.play("run")
	else: sprite.play("idle")
	
	# 朝向修正
	if input_dir != 0: 
		sprite.flip_h = input_dir < 0
