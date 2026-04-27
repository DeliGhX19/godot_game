extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var texture_closed: Texture2D
@export var texture_open: Texture2D

var insider_count := 0


func _ready() -> void:
	close()


# 开门状态
func open() -> void:
	sprite.texture = texture_open
	collision.set_deferred("disabled", true)

# 关门状态
func close() -> void:
	sprite.texture = texture_closed
	collision.set_deferred("disabled", false)


# 检测到玩家或敌人在附近时开门
func _on_area_2d_body_entered(_body: Node2D) -> void:
	insider_count += 1
	open()

# 检测到周围没有玩家或敌人时自动关门
func _on_area_2d_body_exited(_body: Node2D) -> void:
	insider_count -= 1
	if insider_count <= 0:
		close()
