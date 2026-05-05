extends ParallaxBackground

@export var scroll_speed: float = 50.0

func _process(delta):
	scroll_offset.x += scroll_speed * delta
