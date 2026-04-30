extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_shape: CollisionShape2D = $CollisionShape2D
@onready var search_area: Area2D = $SearchArea
@onready var search_area_shape: CollisionShape2D = $SearchArea/CollisionShape2D
@onready var timer: Timer = $Timer

var base_damage: float
var speed: float
var search_radius: float
var flying_time: float
var rotate_dir: int
var exclude_target: CharacterBody2D
var target: CharacterBody2D
var player: CharacterBody2D


func initialize(belonging_player: CharacterBody2D, body: CharacterBody2D) -> void:
	player = belonging_player
	exclude_target = body
	rotate_dir = 1 if randf() < 0.5 else -1
	
	base_damage = 10
	speed = 600
	flying_time = 1.0 + player.stats.magic_range_extra
	search_radius = 300
	
	search_area_shape.shape.radius = search_radius
	timer.wait_time = flying_time
	timer.start()
	
	target = find_target()
	if target == null: velocity = Vector2.RIGHT.rotated(randf() * TAU) * speed

func _physics_process(_delta: float):
	# 没找到目标就一直尝试
	if target == null or not is_instance_valid(target):
		target = find_target()
	
	# 找到目标就向目标飞行
	if target and is_instance_valid(target):
		var to_target = (target.global_position - global_position).normalized()
		var tangent = Vector2(-to_target.y, to_target.x) * rotate_dir
		var final_dir = (to_target + tangent * 1.2).normalized()
		velocity = final_dir * speed
	
	move_and_slide()
	rotation = velocity.angle() + PI/2


# 寻找目标
func find_target() -> CharacterBody2D:
	var bodies = search_area.get_overlapping_bodies()
	var valid_targets: Array = []
	for b in bodies:
		if b != exclude_target:
			valid_targets.append(b)
	if valid_targets.is_empty(): return null
	return valid_targets[randi() % valid_targets.size()]


func _on_timer_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != exclude_target:
		player.stats.damages[PlayerStats.CHAIN_LIGHTNING].value = base_damage
		player.stats.damages[PlayerStats.CHAIN_LIGHTNING].type = GameManager.TYPE_LIGHTNING
		player.stats.enemies[PlayerStats.CHAIN_LIGHTNING].append(body)
		queue_free()
