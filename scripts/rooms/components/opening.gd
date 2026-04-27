extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var texture_closed: Texture2D
@export var texture_open: Texture2D


func _ready() -> void:
	close()


# 打开开口
func open() -> void:
	sprite.texture = texture_open
	collision.set_deferred("disabled", true)

# 关闭开口
func close() -> void:
	sprite.texture = texture_closed
	collision.set_deferred("disabled", false)
