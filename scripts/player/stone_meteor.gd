extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var player: CharacterBody2D          # 所属玩家
var effect_range: float = 600.0      # 搜索范围
var target_pos: Vector2              # 目标位置
var direction: Vector2               # 方向
var speed: float = 1500.0            # 速度
var base_damage: float = 80.0        # 基础伤害


func initialize(belonging_player: CharacterBody2D) -> bool:
	player = belonging_player
	
	# 创建检索区域
	var space_state = get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = effect_range
	
	# 查找敌人
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, player.global_position)
	query.collision_mask = 1 << 2
	
	# 没找到敌人就不释放
	var result = space_state.intersect_shape(query)
	if result.is_empty(): return false
	
	# 找到敌人在屏幕外随机位置释放
	target_pos = result.pick_random().collider.global_position
	var camera = player.get_viewport().get_camera_2d()
	var screen_size = player.get_viewport_rect().size
	var top_left = camera.global_position - screen_size * 0.5
	var top_right = camera.global_position + Vector2(screen_size.x * 0.5, -screen_size.y * 0.5)
	var spawn_x = randf_range(top_left.x, top_right.x)
	var spawn_y = top_left.y - randf_range(150.0, 300.0)
	global_position = Vector2(spawn_x, spawn_y)
	
	direction = (target_pos - global_position).normalized()
	sprite.play("fly")
	return true

func _physics_process(delta: float) -> void:
	if global_position.distance_to(target_pos) < 20.0:
		rotation = 0
		sprite.play("die")
	else:
		global_position += direction * speed * delta
		rotation += 10.0 * delta


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "die":
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	player.stats.damages[PlayerStats.STONE_METEOR].value = base_damage
	player.stats.damages[PlayerStats.STONE_METEOR].type = GameManager.TYPE_STONE
	player.stats.enemies[PlayerStats.STONE_METEOR].append(body)
	body.buffs.buffs[EnemyBuffs.STUN] = 1
