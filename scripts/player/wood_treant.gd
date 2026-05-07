extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

var effect_range: float = 450         # 有效范围
var lifetime: float = 30              # 有效时间
var player: Node2D = null             # 进入区域的玩家


func _ready() -> void:
	area_shape.shape.radius = effect_range
	sprite.play("idle")
	
	timer.wait_time = lifetime
	timer.start()


func _on_body_entered(body: Node2D) -> void:
	body.buffs.buffs[PlayerBuffs.WOOD_TREANT_AURA] += 1
	player = body

func _on_body_exited(body: Node2D) -> void:
	body.buffs.buffs[PlayerBuffs.WOOD_TREANT_AURA] -= 1
	player = null

func _on_timer_timeout() -> void:
	if player != null: player.buffs.buffs[PlayerBuffs.WOOD_TREANT_AURA] -= 1
	queue_free()
