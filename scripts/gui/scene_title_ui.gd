extends CanvasLayer

@onready var title_image: TextureRect = $Control/TitleImage

var texture_map = {
	"炽热荒庭": preload("res://assets/title/fire_title.png"),
	"沉水渊狱": preload("res://assets/title/water_title.png"),
	"风动高台": preload("res://assets/title/wind_title.png"),
	"重压深室": preload("res://assets/title/gravity_title.png"),
	"幽暗秘阁": preload("res://assets/title/dark_title.png"),
	"极寒雪冢": preload("res://assets/title/ice_title.png"),
	"迷雾遗墟": preload("res://assets/title/fog_title.png"),
	"灵泽福地": preload("res://assets/title/grace_title.png"),
	"血狱修罗": preload("res://assets/title/hell_title.png"),
}

func _ready():
	title_image.modulate.a = 0.0

func show_title(env_name: String):
	if not texture_map.has(env_name):
		return
	
	title_image.texture = texture_map[env_name]
	
	# 初始状态
	title_image.modulate.a = 0.0
	title_image.position.y = 0
	
	var tw = create_tween()
	
	# 淡入
	tw.tween_property(title_image, "modulate:a", 1.0, 0.6)
	tw.parallel().tween_property(title_image, "position:y", 20, 0.6)
	
	# 停留
	tw.tween_interval(1.5)
	
	# 淡出
	tw.tween_property(title_image, "modulate:a", 0.0, 0.8)
	tw.parallel().tween_property(title_image, "position:y", -10, 0.8)
