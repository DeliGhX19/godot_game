extends Node2D
class_name BaseRoom

@onready var left_opening = get_node_or_null("LeftOpening")
@onready var right_opening = get_node_or_null("RightOpening")
@onready var top_opening = get_node_or_null("TopOpening")
@onready var bottom_opening = get_node_or_null("BottomOpening")


func _ready() -> void:
	for node in [left_opening, right_opening, top_opening, bottom_opening]:
		if node: node.close()


# 获取房间数据结构体（子类实现！）
func get_room_data() -> RoomData:
	push_error("get_room_data()未在子类中实现")
	return null

# 拼接后处理开口
func apply_room_data(data: RoomData) -> void:
	if data.left_connected and left_opening: left_opening.open()
	if data.right_connected and right_opening: right_opening.open()
	if data.top_connected and top_opening: top_opening.open()
	if data.bottom_connected and bottom_opening: bottom_opening.open()

# 获取敌人生成点
func get_enemy_points() -> Array[Marker2D]:
	var result: Array[Marker2D] = []
	for child in find_children("*", "Marker2D"):
		if child.has_method("is_enemy_point"):
			result.append(child)
	return result
