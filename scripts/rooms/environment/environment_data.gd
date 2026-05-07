class_name EnvironmentData

var name: String                         # 环境名字
var shader_path: String                  # 着色器
var weight: float                        # 权重
var on_load: Callable                    # 加载时处理buff
var on_unload: Callable                  # 卸载时处理buff


func _init(_name: String, _shader: String, _weight: float, _on_load: Callable, _on_unload: Callable) -> void:
	name = _name
	shader_path = _shader
	weight = _weight
	on_load = _on_load
	on_unload = _on_unload
