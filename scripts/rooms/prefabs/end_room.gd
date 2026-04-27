extends BaseRoom

signal next_level


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 8
	data.height = 6
	data.left_opening = 3
	data.bottom_opening = 3
	data.top_opening = 3
	return data


func _on_target_reach_target() -> void:
	next_level.emit()
